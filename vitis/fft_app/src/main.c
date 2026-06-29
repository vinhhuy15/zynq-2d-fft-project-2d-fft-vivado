#include "xil_cache.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "xiltimer.h"
#include "xparameters.h"
#include <stdint.h>

#include "checker_64x64_fft_reference.h"
#include "checker_64x64_input.h"

#define FFT2D_SIZE 64U
#define FFT2D_NUM_SAMPLES (FFT2D_SIZE * FFT2D_SIZE)

#define FFT2D_BASEADDR XPAR_FFT2D_FIXED_TOP_0_BASEADDR

#define AP_CTRL_REG 0x00U
#define INPUT_PTR_REG 0x10U
#define OUTPUT_REAL_PTR_REG 0x18U
#define OUTPUT_IMAG_PTR_REG 0x20U

#define AP_START 0x01U
#define AP_DONE 0x02U
#define AP_IDLE 0x04U

/*
 * The exported HLS IP uses ap_fixed<32,20>, so there are 12 fractional bits.
 * Values in DDR are raw signed two's-complement fixed-point words.
 */
#define FIXED_FRAC_BITS 12
#define FIXED_SCALE (1 << FIXED_FRAC_BITS)

#define POLL_TIMEOUT 100000000U
#define VERIFY_TOL_RAW (1024 * FIXED_SCALE)
#define MAX_MISMATCH_PRINTS 8U

static uint32_t input_buffer[FFT2D_NUM_SAMPLES] __attribute__((aligned(64)));
static uint32_t output_real_buffer[FFT2D_NUM_SAMPLES] __attribute__((aligned(64)));
static uint32_t output_imag_buffer[FFT2D_NUM_SAMPLES] __attribute__((aligned(64)));

static uint32_t encode_fixed_int(int32_t value)
{
    return (uint32_t)(value << FIXED_FRAC_BITS);
}

static int32_t signed_raw(uint32_t value)
{
    return (int32_t)value;
}

static int32_t abs_i32(int32_t value)
{
    return (value < 0) ? -value : value;
}

static int fixed_raw_close(uint32_t got, int32_t expected_raw)
{
    const int64_t diff = (int64_t)signed_raw(got) - (int64_t)expected_raw;
    const int64_t abs_diff = (diff < 0) ? -diff : diff;

    return abs_diff <= (int64_t)VERIFY_TOL_RAW;
}

static void clear_outputs(void)
{
    for (uint32_t i = 0; i < FFT2D_NUM_SAMPLES; ++i) {
        output_real_buffer[i] = 0xDEADBEEFU;
        output_imag_buffer[i] = 0xA5A5A5A5U;
    }
}

static void fill_checker_input(void)
{
    for (uint32_t i = 0; i < FFT2D_NUM_SAMPLES; ++i) {
        input_buffer[i] = encode_fixed_int((int32_t)checker_64x64_input[i]);
    }
}

static void print_fixed(const char *label, uint32_t raw)
{
    const int32_t signed_value = signed_raw(raw);
    const int32_t integer = signed_value / FIXED_SCALE;
    const int32_t frac = abs_i32(signed_value % FIXED_SCALE);

    xil_printf("%s%d.%03d", label, integer, (frac * 1000) / FIXED_SCALE);
}

static void print_unsigned_fixed(const char *label, uint32_t raw)
{
    xil_printf("%s%u.%03u",
               label,
               (unsigned int)(raw / FIXED_SCALE),
               (unsigned int)(((raw % FIXED_SCALE) * 1000U) / FIXED_SCALE));
}

static int run_fft_ip(uint32_t *cycles)
{
    XTime start_time;
    XTime end_time;
    uint32_t poll_count = 0U;

    Xil_DCacheFlushRange((UINTPTR)input_buffer, sizeof(input_buffer));
    Xil_DCacheFlushRange((UINTPTR)output_real_buffer, sizeof(output_real_buffer));
    Xil_DCacheFlushRange((UINTPTR)output_imag_buffer, sizeof(output_imag_buffer));

    Xil_Out32(FFT2D_BASEADDR + INPUT_PTR_REG, (uint32_t)(UINTPTR)input_buffer);
    Xil_Out32(FFT2D_BASEADDR + OUTPUT_REAL_PTR_REG, (uint32_t)(UINTPTR)output_real_buffer);
    Xil_Out32(FFT2D_BASEADDR + OUTPUT_IMAG_PTR_REG, (uint32_t)(UINTPTR)output_imag_buffer);

    XTime_GetTime(&start_time);
    Xil_Out32(FFT2D_BASEADDR + AP_CTRL_REG, AP_START);

    while ((Xil_In32(FFT2D_BASEADDR + AP_CTRL_REG) & AP_DONE) == 0U) {
        ++poll_count;
        if (poll_count >= POLL_TIMEOUT) {
            xil_printf("ERROR: timeout waiting for FFT IP, AP_CTRL=0x%08x\r\n",
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

/*
 * Full reference generated from:
 * software/cpp_reference/zynq_2d_fft_step2_cpp_reference/data/reference/checker_64x64_fft_*_2d.txt
 * Values are stored in raw ap_fixed<32,20> format, scaled by 2^12.
 */
static uint32_t abs_raw_diff(uint32_t got, int32_t expected_raw)
{
    const int64_t diff = (int64_t)signed_raw(got) - (int64_t)expected_raw;
    const int64_t abs_diff = (diff < 0) ? -diff : diff;

    return (abs_diff > 0xFFFFFFFFLL) ? 0xFFFFFFFFU : (uint32_t)abs_diff;
}

static int verify_checker_output_all(void)
{
    uint32_t errors = 0U;
    uint32_t printed_errors = 0U;
    uint32_t max_real_error = 0U;
    uint32_t max_imag_error = 0U;
    uint32_t max_real_index = 0U;
    uint32_t max_imag_index = 0U;

    for (uint32_t index = 0; index < FFT2D_NUM_SAMPLES; ++index) {
        const int32_t expected_real = checker_64x64_fft_real_ref_raw[index];
        const int32_t expected_imag = checker_64x64_fft_imag_ref_raw[index];
        const uint32_t real_error = abs_raw_diff(output_real_buffer[index], expected_real);
        const uint32_t imag_error = abs_raw_diff(output_imag_buffer[index], expected_imag);

        if (real_error > max_real_error) {
            max_real_error = real_error;
            max_real_index = index;
        }
        if (imag_error > max_imag_error) {
            max_imag_error = imag_error;
            max_imag_index = index;
        }

        if (!fixed_raw_close(output_real_buffer[index], expected_real) ||
            !fixed_raw_close(output_imag_buffer[index], expected_imag)) {
            if (printed_errors < MAX_MISMATCH_PRINTS) {
                xil_printf("  mismatch bin[%u] (row=%u,col=%u)\r\n",
                           (unsigned int)index,
                           (unsigned int)(index / FFT2D_SIZE),
                           (unsigned int)(index % FFT2D_SIZE));
                xil_printf("    got      real_raw=0x%08x imag_raw=0x%08x\r\n",
                           (unsigned int)output_real_buffer[index],
                           (unsigned int)output_imag_buffer[index]);
                xil_printf("    expected real_raw=0x%08x imag_raw=0x%08x\r\n",
                           (unsigned int)(uint32_t)expected_real,
                           (unsigned int)(uint32_t)expected_imag);
                ++printed_errors;
            }
            ++errors;
        }
    }

    xil_printf("  full reference check: %u / %u bins checked\r\n",
               (unsigned int)FFT2D_NUM_SAMPLES,
               (unsigned int)FFT2D_NUM_SAMPLES);
    print_unsigned_fixed("  max real error = ", max_real_error);
    xil_printf(" at bin[%u]\r\n", (unsigned int)max_real_index);
    print_unsigned_fixed("  max imag error = ", max_imag_error);
    xil_printf(" at bin[%u]\r\n", (unsigned int)max_imag_index);

    if (errors != 0U) {
        xil_printf("  checker errors: %u / %u checked bins\r\n",
                   (unsigned int)errors, (unsigned int)FFT2D_NUM_SAMPLES);
        return -1;
    }

    return 0;
}

static void print_checker_bin(uint32_t index)
{
    xil_printf("  bin[%u] (row=%u,col=%u): ",
               (unsigned int)index,
               (unsigned int)(index / FFT2D_SIZE),
               (unsigned int)(index % FFT2D_SIZE));
    print_fixed("real = ", output_real_buffer[index]);
    print_fixed(", imag = ", output_imag_buffer[index]);
    xil_printf("\r\n");
}

static int run_checker_test(void)
{
    uint32_t cycles = 0U;

    xil_printf("\r\nTest: checker_64x64 image from cpp_reference/data/input\r\n");
    fill_checker_input();
    clear_outputs();

    if (run_fft_ip(&cycles) != 0) {
        return -1;
    }

    xil_printf("  cycles: %u\r\n", (unsigned int)cycles);
    print_checker_bin(0U);
    print_checker_bin(260U);
    print_checker_bin(316U);
    print_checker_bin(3900U);

    if (verify_checker_output_all() != 0) {
        xil_printf("  FAIL\r\n");
        return -1;
    }

    xil_printf("  PASS\r\n");
    return 0;
}

int main(void)
{
    int status = 0;

    xil_printf("\r\nZynq 2D FFT accelerator bare-metal test\r\n");
    xil_printf("IP base address: 0x%08x\r\n", (unsigned int)FFT2D_BASEADDR);

    if ((Xil_In32(FFT2D_BASEADDR + AP_CTRL_REG) & AP_IDLE) == 0U) {
        xil_printf("WARNING: FFT IP is not idle before start, AP_CTRL=0x%08x\r\n",
                   (unsigned int)Xil_In32(FFT2D_BASEADDR + AP_CTRL_REG));
    }

    if (run_checker_test() != 0) {
        status = -1;
    }

    if (status == 0) {
        xil_printf("\r\nChecker FFT hardware test passed.\r\n");
    } else {
        xil_printf("\r\nFFT hardware test failed.\r\n");
    }

    return status;
}
