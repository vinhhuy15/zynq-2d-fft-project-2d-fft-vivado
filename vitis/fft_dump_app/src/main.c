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

#define AP_START 0x01U
#define AP_DONE 0x02U

#define OUTPUT_REAL_SENTINEL 0xdeadbeefU
#define OUTPUT_IMAG_SENTINEL 0xa5a5a5a5U

#define POLL_TIMEOUT 100000000U
#define IMAGE_VERIFY_TOL_RAW 8192U
#define MAX_MISMATCH_PRINTS 8U

/*
 * rgb_image_fft_tests.h currently contains:
 *   0: synthetic_checker
 *   1: cifar_real_image
 * The checker spectrum is visually clearer for demo screenshots.
 */
#define DUMP_TEST_INDEX 0U

static uint32_t input_buffer[FFT2D_TOTAL_SAMPLES] __attribute__((aligned(64)));
static uint32_t output_real_buffer[FFT2D_TOTAL_SAMPLES] __attribute__((aligned(64)));
static uint32_t output_imag_buffer[FFT2D_TOTAL_SAMPLES] __attribute__((aligned(64)));

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

static void prepare_rgb_image_test(const uint32_t *test_input)
{
    for (uint32_t i = 0; i < FFT2D_TOTAL_SAMPLES; ++i) {
        input_buffer[i] = test_input[i];
        output_real_buffer[i] = OUTPUT_REAL_SENTINEL;
        output_imag_buffer[i] = OUTPUT_IMAG_SENTINEL;
    }
}

static int run_fft_ip(uint32_t *cycles)
{
    XTime start_time;
    XTime end_time;
    uint32_t poll_count = 0U;

    Xil_DCacheFlushRange((UINTPTR)input_buffer, sizeof(input_buffer));
    Xil_DCacheFlushRange((UINTPTR)output_real_buffer, sizeof(output_real_buffer));
    Xil_DCacheFlushRange((UINTPTR)output_imag_buffer, sizeof(output_imag_buffer));

    write_ptr64(INPUT_PTR_REG, (uintptr_t)input_buffer);
    write_ptr64(OUTPUT_REAL_PTR_REG, (uintptr_t)output_real_buffer);
    write_ptr64(OUTPUT_IMAG_PTR_REG, (uintptr_t)output_imag_buffer);

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
    Xil_DCacheInvalidateRange((UINTPTR)output_real_buffer, sizeof(output_real_buffer));
    Xil_DCacheInvalidateRange((UINTPTR)output_imag_buffer, sizeof(output_imag_buffer));

    if (cycles != 0) {
        *cycles = (uint32_t)(end_time - start_time);
    }

    return 0;
}

static int output_buffers_still_sentinel(void)
{
    const uint32_t probe_bins[] = {0U, 1U, 64U, 4095U, 4096U, 8192U, 12287U};

    for (uint32_t i = 0; i < (sizeof(probe_bins) / sizeof(probe_bins[0])); ++i) {
        uint32_t idx = probe_bins[i];
        if (output_real_buffer[idx] != OUTPUT_REAL_SENTINEL ||
            output_imag_buffer[idx] != OUTPUT_IMAG_SENTINEL) {
            return 0;
        }
    }

    return 1;
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
            if (printed < MAX_MISMATCH_PRINTS) {
                xil_printf("  mismatch ch=%u bin=%u got=(0x%08x,0x%08x) expected=(0x%08x,0x%08x)\r\n",
                           (unsigned int)probes[i].channel,
                           (unsigned int)probes[i].bin,
                           (unsigned int)output_real_buffer[idx],
                           (unsigned int)output_imag_buffer[idx],
                           (unsigned int)(uint32_t)probes[i].expected_real_raw,
                           (unsigned int)(uint32_t)probes[i].expected_imag_raw);
                ++printed;
            }
            ++errors;
        }
    }

    xil_printf("Probe check: %u points, max real err raw=%u, max imag err raw=%u\r\n",
               (unsigned int)RGB_IMAGE_TEST_PROBE_COUNT,
               (unsigned int)max_real_error,
               (unsigned int)max_imag_error);

    return (errors == 0U) ? 0 : -1;
}

static void dump_full_fft_output_uart(const char *test_name)
{
    xil_printf("FFT_DUMP_BEGIN,%s,%u,%u,%u\r\n",
               test_name,
               (unsigned int)FFT2D_SIZE,
               (unsigned int)FFT2D_SIZE,
               (unsigned int)FFT2D_CHANNELS);

    for (uint32_t ch = 0; ch < FFT2D_CHANNELS; ++ch) {
        for (uint32_t bin = 0; bin < FFT2D_PIXELS; ++bin) {
            uint32_t idx = ch * FFT2D_PIXELS + bin;
            xil_printf("D,%u,%u,%08x,%08x\r\n",
                       (unsigned int)ch,
                       (unsigned int)bin,
                       (unsigned int)output_real_buffer[idx],
                       (unsigned int)output_imag_buffer[idx]);
        }
    }

    xil_printf("FFT_DUMP_END,%s\r\n", test_name);
}

int main(void)
{
    uint32_t cycles = 0U;
    const char *test_name = rgb_image_test_names[DUMP_TEST_INDEX];

    xil_printf("\r\nZynq RGB 2D FFT FPGA image dump app\r\n");
    xil_printf("IP base address: 0x%08x\r\n", (unsigned int)FFT2D_BASEADDR);
    xil_printf("Dump testcase: %s\r\n", test_name);
    xil_printf("Output format: FFT_DUMP_BEGIN / D,ch,bin,real_hex,imag_hex / FFT_DUMP_END\r\n");

    prepare_rgb_image_test(rgb_image_test_inputs[DUMP_TEST_INDEX]);

    if (run_fft_ip(&cycles) != 0) {
        xil_printf("RGB FFT dump app failed.\r\n");
        return -1;
    }

    xil_printf("FFT IP done, cycles=%u\r\n", (unsigned int)cycles);

    if (verify_rgb_image_fft(DUMP_TEST_INDEX) != 0) {
        xil_printf("RGB FFT dump app failed.\r\n");
        return -1;
    }

    xil_printf("Starting full FFT UART dump. Capture this log and run tools/render_fpga_fft_dump.py.\r\n");
    dump_full_fft_output_uart(test_name);
    xil_printf("RGB FFT dump app passed.\r\n");

    return 0;
}
