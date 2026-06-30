#include "xil_cache.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xiltimer.h"
#include <stdint.h>

#include "rgb_image_fft_tests.h"

#define FFT2D_SIZE 64U
#define FFT2D_CHANNELS 3U
#define FFT2D_PIXELS (FFT2D_SIZE * FFT2D_SIZE)
#define FFT2D_TOTAL_SAMPLES (FFT2D_CHANNELS * FFT2D_PIXELS)

#if defined(XPAR_XFFT2D_FIXED_TOP_0_BASEADDR)
#define FFT2D_BASEADDR XPAR_XFFT2D_FIXED_TOP_0_BASEADDR
#elif defined(XPAR_FFT2D_FIXED_TOP_1_BASEADDR)
#define FFT2D_BASEADDR XPAR_FFT2D_FIXED_TOP_1_BASEADDR
#else
#define FFT2D_BASEADDR 0x40000000U
#endif

#define AP_CTRL_REG 0x00U
#define INPUT_PTR_REG 0x10U
#define OUTPUT_REAL_PTR_REG 0x1cU
#define OUTPUT_IMAG_PTR_REG 0x28U
#define RGB_REG_LAST 0x2cU

#define OUTPUT_REAL_SENTINEL 0xdeadbeefU
#define OUTPUT_IMAG_SENTINEL 0xa5a5a5a5U

#define AP_START 0x01U
#define AP_DONE 0x02U
#define AP_IDLE 0x04U

#define FIXED_FRAC_BITS 12
#define FIXED_SCALE (1 << FIXED_FRAC_BITS)

#define POLL_TIMEOUT 100000000U
#define VERIFY_TOL_RAW (16 * FIXED_SCALE)
#define IMAGE_VERIFY_TOL_RAW 8192U
#define MAX_IMAGE_MISMATCH_PRINTS 8U

static uint32_t input_buffer[FFT2D_TOTAL_SAMPLES] __attribute__((aligned(64)));
static uint32_t output_real_buffer[FFT2D_TOTAL_SAMPLES] __attribute__((aligned(64)));
static uint32_t output_imag_buffer[FFT2D_TOTAL_SAMPLES] __attribute__((aligned(64)));

static uint32_t encode_fixed_int(int32_t value)
{
    return (uint32_t)(value << FIXED_FRAC_BITS);
}

static int32_t signed_raw(uint32_t value)
{
    return (int32_t)value;
}

static uint32_t abs_raw_diff(uint32_t got, int32_t expected)
{
    int64_t diff = (int64_t)signed_raw(got) - (int64_t)expected;
    if (diff < 0) {
        diff = -diff;
    }
    return (diff > 0xffffffffLL) ? 0xffffffffU : (uint32_t)diff;
}

static void write_ptr64(uint32_t offset, uintptr_t ptr)
{
    Xil_Out32(FFT2D_BASEADDR + offset, (uint32_t)ptr);
    Xil_Out32(FFT2D_BASEADDR + offset + 4U, 0U);
}

static void print_register_snapshot(const char *stage)
{
    xil_printf("%s register snapshot:\r\n", stage);
    xil_printf("  AP_CTRL=0x%08x\r\n", (unsigned int)Xil_In32(FFT2D_BASEADDR + AP_CTRL_REG));
    xil_printf("  0x10=0x%08x 0x14=0x%08x 0x18=0x%08x\r\n",
               (unsigned int)Xil_In32(FFT2D_BASEADDR + 0x10U),
               (unsigned int)Xil_In32(FFT2D_BASEADDR + 0x14U),
               (unsigned int)Xil_In32(FFT2D_BASEADDR + 0x18U));
    xil_printf("  0x1c=0x%08x 0x20=0x%08x 0x24=0x%08x\r\n",
               (unsigned int)Xil_In32(FFT2D_BASEADDR + 0x1cU),
               (unsigned int)Xil_In32(FFT2D_BASEADDR + 0x20U),
               (unsigned int)Xil_In32(FFT2D_BASEADDR + 0x24U));
    xil_printf("  0x28=0x%08x 0x2c=0x%08x\r\n",
               (unsigned int)Xil_In32(FFT2D_BASEADDR + 0x28U),
               (unsigned int)Xil_In32(FFT2D_BASEADDR + RGB_REG_LAST));
}

static uint32_t sample_index(uint32_t channel, uint32_t row, uint32_t col)
{
    return channel * FFT2D_PIXELS + row * FFT2D_SIZE + col;
}

static void prepare_constant_rgb_test(void)
{
    const uint32_t channel_values[FFT2D_CHANNELS] = {1U, 2U, 3U};

    for (uint32_t ch = 0; ch < FFT2D_CHANNELS; ++ch) {
        for (uint32_t i = 0; i < FFT2D_PIXELS; ++i) {
            uint32_t idx = ch * FFT2D_PIXELS + i;
            input_buffer[idx] = encode_fixed_int((int32_t)channel_values[ch]);
            output_real_buffer[idx] = OUTPUT_REAL_SENTINEL;
            output_imag_buffer[idx] = OUTPUT_IMAG_SENTINEL;
        }
    }
}

static void prepare_rgb_image_test(const uint32_t *test_input)
{
    for (uint32_t i = 0; i < FFT2D_TOTAL_SAMPLES; ++i) {
        input_buffer[i] = test_input[i];
        output_real_buffer[i] = OUTPUT_REAL_SENTINEL;
        output_imag_buffer[i] = OUTPUT_IMAG_SENTINEL;
    }
}

static void print_fixed_raw(const char *label, uint32_t raw)
{
    int32_t value = signed_raw(raw);
    int32_t integer = value / FIXED_SCALE;
    int32_t frac = value % FIXED_SCALE;
    if (frac < 0) {
        frac = -frac;
    }
    xil_printf("%s%d.%03d raw=0x%08x",
               label,
               integer,
               (frac * 1000) / FIXED_SCALE,
               (unsigned int)raw);
}

static int run_fft_ip(uint32_t *cycles)
{
    XTime start_time;
    XTime end_time;
    uint32_t poll_count = 0U;

    Xil_DCacheFlushRange((UINTPTR)input_buffer, sizeof(input_buffer));
    Xil_DCacheFlushRange((UINTPTR)output_real_buffer, sizeof(output_real_buffer));
    Xil_DCacheFlushRange((UINTPTR)output_imag_buffer, sizeof(output_imag_buffer));

    xil_printf("Input buffer:       0x%08x\r\n", (unsigned int)(uintptr_t)input_buffer);
    xil_printf("Output real buffer: 0x%08x\r\n", (unsigned int)(uintptr_t)output_real_buffer);
    xil_printf("Output imag buffer: 0x%08x\r\n", (unsigned int)(uintptr_t)output_imag_buffer);

    write_ptr64(INPUT_PTR_REG, (uintptr_t)input_buffer);
    write_ptr64(OUTPUT_REAL_PTR_REG, (uintptr_t)output_real_buffer);
    write_ptr64(OUTPUT_IMAG_PTR_REG, (uintptr_t)output_imag_buffer);
    print_register_snapshot("After pointer writes");

    XTime_GetTime(&start_time);
    Xil_Out32(FFT2D_BASEADDR + AP_CTRL_REG, AP_START);

    while ((Xil_In32(FFT2D_BASEADDR + AP_CTRL_REG) & AP_DONE) == 0U) {
        ++poll_count;
        if (poll_count >= POLL_TIMEOUT) {
            xil_printf("ERROR: FFT IP timeout, AP_CTRL=0x%08x\r\n",
                       (unsigned int)Xil_In32(FFT2D_BASEADDR + AP_CTRL_REG));
            return -1;
        }
    }

    XTime_GetTime(&end_time);
    print_register_snapshot("After IP done");
    Xil_DCacheInvalidateRange((UINTPTR)output_real_buffer, sizeof(output_real_buffer));
    Xil_DCacheInvalidateRange((UINTPTR)output_imag_buffer, sizeof(output_imag_buffer));

    if (cycles != 0) {
        *cycles = (uint32_t)(end_time - start_time);
    }

    return 0;
}

static int output_buffers_still_sentinel(void)
{
    const uint32_t probe_bins[] = {0U, 1U, 2U, 63U, 64U, 65U, 4095U, 4096U, 8192U, 12287U};

    for (uint32_t i = 0; i < (sizeof(probe_bins) / sizeof(probe_bins[0])); ++i) {
        uint32_t idx = probe_bins[i];
        if (output_real_buffer[idx] != OUTPUT_REAL_SENTINEL ||
            output_imag_buffer[idx] != OUTPUT_IMAG_SENTINEL) {
            return 0;
        }
    }

    return 1;
}

static int verify_constant_rgb_fft(void)
{
    const int32_t expected_dc[FFT2D_CHANNELS] = {
        (int32_t)(1U * FFT2D_PIXELS * FIXED_SCALE),
        (int32_t)(2U * FFT2D_PIXELS * FIXED_SCALE),
        (int32_t)(3U * FFT2D_PIXELS * FIXED_SCALE),
    };
    const uint32_t probe_bins[] = {1U, 2U, 63U, 64U, 65U, 4095U};
    uint32_t errors = 0U;

    if (output_buffers_still_sentinel() != 0) {
        xil_printf("ERROR: Output buffers are still sentinel values after AP_DONE.\r\n");
        xil_printf("       The IP did not write to DDR. Check that the loaded bitstream is the RGB FFT bitstream\r\n");
        xil_printf("       and that the Vitis app uses the RGB register map: input=0x10, real=0x1c, imag=0x28.\r\n");
        xil_printf("       A stale grayscale IP usually has real=0x18 and imag=0x20 instead.\r\n");
        return -1;
    }

    for (uint32_t ch = 0; ch < FFT2D_CHANNELS; ++ch) {
        uint32_t dc = sample_index(ch, 0U, 0U);
        uint32_t dc_real_error = abs_raw_diff(output_real_buffer[dc], expected_dc[ch]);
        uint32_t dc_imag_error = abs_raw_diff(output_imag_buffer[dc], 0);

        xil_printf("Channel %u DC: ", (unsigned int)ch);
        print_fixed_raw("real=", output_real_buffer[dc]);
        xil_printf(", ");
        print_fixed_raw("imag=", output_imag_buffer[dc]);
        xil_printf("\r\n");

        if (dc_real_error > VERIFY_TOL_RAW || dc_imag_error > VERIFY_TOL_RAW) {
            xil_printf("  ERROR: channel %u DC mismatch, expected real raw=0x%08x imag raw=0\r\n",
                       (unsigned int)ch,
                       (unsigned int)expected_dc[ch]);
            ++errors;
        }

        for (uint32_t i = 0; i < (sizeof(probe_bins) / sizeof(probe_bins[0])); ++i) {
            uint32_t idx = ch * FFT2D_PIXELS + probe_bins[i];
            uint32_t real_error = abs_raw_diff(output_real_buffer[idx], 0);
            uint32_t imag_error = abs_raw_diff(output_imag_buffer[idx], 0);
            if (real_error > VERIFY_TOL_RAW || imag_error > VERIFY_TOL_RAW) {
                xil_printf("  ERROR: channel %u non-DC bin %u is not near zero\r\n",
                           (unsigned int)ch,
                           (unsigned int)probe_bins[i]);
                xil_printf("    real raw=0x%08x imag raw=0x%08x\r\n",
                           (unsigned int)output_real_buffer[idx],
                           (unsigned int)output_imag_buffer[idx]);
                ++errors;
            }
        }
    }

    return (errors == 0U) ? 0 : -1;
}

static int verify_rgb_image_fft(uint32_t test_index)
{
    const rgb_fft_probe_t *probes = rgb_image_test_probes[test_index];
    uint32_t errors = 0U;
    uint32_t printed = 0U;
    uint32_t max_real_error = 0U;
    uint32_t max_imag_error = 0U;

    if (output_buffers_still_sentinel() != 0) {
        xil_printf("ERROR: Output buffers are still sentinel values after AP_DONE.\r\n");
        return -1;
    }

    for (uint32_t i = 0; i < RGB_IMAGE_TEST_PROBE_COUNT; ++i) {
        uint32_t idx = probes[i].channel * FFT2D_PIXELS + probes[i].bin;
        uint32_t real_error = abs_raw_diff(output_real_buffer[idx], probes[i].expected_real_raw);
        uint32_t imag_error = abs_raw_diff(output_imag_buffer[idx], probes[i].expected_imag_raw);

        if (real_error > max_real_error) {
            max_real_error = real_error;
        }
        if (imag_error > max_imag_error) {
            max_imag_error = imag_error;
        }

        if (real_error > IMAGE_VERIFY_TOL_RAW || imag_error > IMAGE_VERIFY_TOL_RAW) {
            if (printed < MAX_IMAGE_MISMATCH_PRINTS) {
                xil_printf("  mismatch ch=%u bin=%u\r\n",
                           (unsigned int)probes[i].channel,
                           (unsigned int)probes[i].bin);
                xil_printf("    got      real=0x%08x imag=0x%08x\r\n",
                           (unsigned int)output_real_buffer[idx],
                           (unsigned int)output_imag_buffer[idx]);
                xil_printf("    expected real=0x%08x imag=0x%08x\r\n",
                           (unsigned int)(uint32_t)probes[i].expected_real_raw,
                           (unsigned int)(uint32_t)probes[i].expected_imag_raw);
                ++printed;
            }
            ++errors;
        }
    }

    xil_printf("  probes checked: %u, max real err raw=%u, max imag err raw=%u\r\n",
               (unsigned int)RGB_IMAGE_TEST_PROBE_COUNT,
               (unsigned int)max_real_error,
               (unsigned int)max_imag_error);

    return (errors == 0U) ? 0 : -1;
}

static int run_rgb_image_test(uint32_t test_index)
{
    uint32_t cycles = 0U;

    xil_printf("\r\nImage FFT test: %s\r\n", rgb_image_test_names[test_index]);
    prepare_rgb_image_test(rgb_image_test_inputs[test_index]);

    if (run_fft_ip(&cycles) != 0) {
        return -1;
    }

    xil_printf("FFT IP done, cycles=%u\r\n", (unsigned int)cycles);

    if (verify_rgb_image_fft(test_index) != 0) {
        xil_printf("  FAIL\r\n");
        return -1;
    }

    xil_printf("  PASS\r\n");
    return 0;
}

int main(void)
{
    uint32_t cycles = 0U;

    xil_printf("\r\nZynq RGB 2D FFT accelerator bare-metal test\r\n");
    xil_printf("IP base address: 0x%08x\r\n", (unsigned int)FFT2D_BASEADDR);
    xil_printf("Image: 64x64 RGB constant test, R=1 G=2 B=3\r\n");

    if ((Xil_In32(FFT2D_BASEADDR + AP_CTRL_REG) & AP_IDLE) == 0U) {
        xil_printf("WARNING: FFT IP is not idle before start, AP_CTRL=0x%08x\r\n",
                   (unsigned int)Xil_In32(FFT2D_BASEADDR + AP_CTRL_REG));
    }

    prepare_constant_rgb_test();
    if (run_fft_ip(&cycles) != 0) {
        xil_printf("\r\nRGB FFT hardware test failed.\r\n");
        return -1;
    }

    xil_printf("FFT IP done, cycles=%u\r\n", (unsigned int)cycles);

    if (verify_constant_rgb_fft() != 0) {
        xil_printf("\r\nRGB FFT hardware test failed.\r\n");
        return -1;
    }

    for (uint32_t i = 0; i < RGB_IMAGE_TEST_COUNT; ++i) {
        if (run_rgb_image_test(i) != 0) {
            xil_printf("\r\nRGB FFT hardware test failed.\r\n");
            return -1;
        }
    }

    xil_printf("\r\nRGB FFT hardware test passed.\r\n");
    return 0;
}
