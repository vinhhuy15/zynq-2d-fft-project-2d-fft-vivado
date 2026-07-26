#include "xil_cache.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xiltimer.h"
#include <math.h>
#include <stdint.h>

#include "rgb_image_fft_tests.h"
#include "checker_python_reference.h"

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
#ifndef ENABLE_DOUBLE_RUNTIME_TRIG_BENCHMARK
#define ENABLE_DOUBLE_RUNTIME_TRIG_BENCHMARK 1U
#endif
#ifndef ENABLE_FULL_UART_DUMP
#define ENABLE_FULL_UART_DUMP 0U
#endif
#define BENCHMARK_RUN_COUNT 3U
#define FFT2D_PI 3.14159265358979323846

/*
 * rgb_image_fft_tests.h currently contains:
 *   0: synthetic_checker
 * The checker spectrum is visually clearer for demo screenshots.
 */
#define DUMP_TEST_INDEX 0U

static uint32_t input_buffer[FFT2D_TOTAL_SAMPLES] __attribute__((aligned(64)));
static uint32_t output_real_buffer[FFT2D_TOTAL_SAMPLES] __attribute__((aligned(64)));
static uint32_t output_imag_buffer[FFT2D_TOTAL_SAMPLES] __attribute__((aligned(64)));
static int32_t cpu_real_buffer[FFT2D_TOTAL_SAMPLES] __attribute__((aligned(64)));
static int32_t cpu_imag_buffer[FFT2D_TOTAL_SAMPLES] __attribute__((aligned(64)));
#if ENABLE_DOUBLE_RUNTIME_TRIG_BENCHMARK
static double ref_real_buffer[FFT2D_TOTAL_SAMPLES] __attribute__((aligned(64)));
static double ref_imag_buffer[FFT2D_TOTAL_SAMPLES] __attribute__((aligned(64)));
#endif
static volatile int32_t cpu_fft_checksum = 0;
static volatile double double_fft_checksum = 0.0;

static const int32_t twiddle_cos_q15[FFT2D_SIZE / 2U] = {
    32767, 32609, 32137, 31356, 30273, 28898, 27245, 25329,
    23170, 20787, 18204, 15446, 12539, 9512, 6393, 3212,
    0, -3212, -6393, -9512, -12539, -15446, -18204, -20787,
    -23170, -25329, -27245, -28898, -30273, -31356, -32137, -32609
};

static const int32_t twiddle_sin_q15[FFT2D_SIZE / 2U] = {
    0, -3212, -6393, -9512, -12539, -15446, -18204, -20787,
    -23170, -25329, -27245, -28898, -30273, -31356, -32137, -32609,
    -32767, -32609, -32137, -31356, -30273, -28898, -27245, -25329,
    -23170, -20787, -18204, -15446, -12539, -9512, -6393, -3212
};

static int32_t signed_raw(uint32_t value)
{
    return (int32_t)value;
}

static uint64_t xtime_to_us(uint64_t ticks)
{
    return (ticks * 1000000ULL) / (uint64_t)COUNTS_PER_SECOND;
}

static void xil_print_u64(uint64_t value)
{
    char buf[24];
    int pos = (int)sizeof(buf) - 1;

    buf[pos] = '\0';
    if (value == 0ULL) {
        xil_printf("0");
        return;
    }

    while (value > 0ULL && pos > 0) {
        --pos;
        buf[pos] = (char)('0' + (value % 10ULL));
        value /= 10ULL;
    }

    xil_printf("%s", &buf[pos]);
}

static void xil_print_fixed_x100(uint64_t value_x100)
{
    xil_print_u64(value_x100 / 100ULL);
    xil_printf(".%02u", (unsigned int)(value_x100 % 100ULL));
}

static void xil_print_fixed_x10000(uint64_t value_x10000)
{
    xil_print_u64(value_x10000 / 10000ULL);
    xil_printf(".%04u", (unsigned int)(value_x10000 % 10000ULL));
}

static int32_t q15_mul(int32_t a, int32_t b)
{
    return (int32_t)(((int64_t)a * (int64_t)b) >> 15);
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

static void cpu_fft1d_64(int32_t real[FFT2D_SIZE], int32_t imag[FFT2D_SIZE])
{
    for (uint32_t i = 1U, j = 0U; i < FFT2D_SIZE; ++i) {
        uint32_t bit = FFT2D_SIZE >> 1U;
        while ((j & bit) != 0U) {
            j ^= bit;
            bit >>= 1U;
        }
        j ^= bit;

        if (i < j) {
            int32_t tr = real[i];
            int32_t ti = imag[i];
            real[i] = real[j];
            imag[i] = imag[j];
            real[j] = tr;
            imag[j] = ti;
        }
    }

    for (uint32_t len = 2U; len <= FFT2D_SIZE; len <<= 1U) {
        uint32_t half = len >> 1U;
        uint32_t step = FFT2D_SIZE / len;

        for (uint32_t i = 0U; i < FFT2D_SIZE; i += len) {
            for (uint32_t j = 0U; j < half; ++j) {
                uint32_t tw = j * step;
                int32_t wr = twiddle_cos_q15[tw];
                int32_t wi = twiddle_sin_q15[tw];
                uint32_t even = i + j;
                uint32_t odd = even + half;
                int32_t tr = q15_mul(real[odd], wr) - q15_mul(imag[odd], wi);
                int32_t ti = q15_mul(real[odd], wi) + q15_mul(imag[odd], wr);
                int32_t ur = real[even];
                int32_t ui = imag[even];

                real[even] = ur + tr;
                imag[even] = ui + ti;
                real[odd] = ur - tr;
                imag[odd] = ui - ti;
            }
        }
    }
}

static void run_cpu_fft_reference(uint32_t test_index, uint64_t *ticks)
{
    XTime start_time;
    XTime end_time;
    int32_t line_real[FFT2D_SIZE];
    int32_t line_imag[FFT2D_SIZE];
    int32_t checksum = 0;
    const uint32_t *test_input = rgb_image_test_inputs[test_index];

    XTime_GetTime(&start_time);

    for (uint32_t ch = 0U; ch < FFT2D_CHANNELS; ++ch) {
        uint32_t base = ch * FFT2D_PIXELS;

        for (uint32_t y = 0U; y < FFT2D_SIZE; ++y) {
            for (uint32_t x = 0U; x < FFT2D_SIZE; ++x) {
                line_real[x] = signed_raw(test_input[base + y * FFT2D_SIZE + x]);
                line_imag[x] = 0;
            }
            cpu_fft1d_64(line_real, line_imag);
            for (uint32_t x = 0U; x < FFT2D_SIZE; ++x) {
                cpu_real_buffer[base + y * FFT2D_SIZE + x] = line_real[x];
                cpu_imag_buffer[base + y * FFT2D_SIZE + x] = line_imag[x];
            }
        }

        for (uint32_t x = 0U; x < FFT2D_SIZE; ++x) {
            for (uint32_t y = 0U; y < FFT2D_SIZE; ++y) {
                line_real[y] = cpu_real_buffer[base + y * FFT2D_SIZE + x];
                line_imag[y] = cpu_imag_buffer[base + y * FFT2D_SIZE + x];
            }
            cpu_fft1d_64(line_real, line_imag);
            for (uint32_t y = 0U; y < FFT2D_SIZE; ++y) {
                cpu_real_buffer[base + y * FFT2D_SIZE + x] = line_real[y];
                cpu_imag_buffer[base + y * FFT2D_SIZE + x] = line_imag[y];
            }
        }

        checksum ^= cpu_real_buffer[base];
        checksum ^= cpu_imag_buffer[base + FFT2D_PIXELS - 1U];
    }

    XTime_GetTime(&end_time);

    cpu_fft_checksum = checksum;
    if (ticks != 0) {
        *ticks = (uint64_t)(end_time - start_time);
    }
}

#if ENABLE_DOUBLE_RUNTIME_TRIG_BENCHMARK
static void double_fft1d_64(double real[FFT2D_SIZE], double imag[FFT2D_SIZE])
{
    for (uint32_t i = 1U, j = 0U; i < FFT2D_SIZE; ++i) {
        uint32_t bit = FFT2D_SIZE >> 1U;
        while ((j & bit) != 0U) {
            j ^= bit;
            bit >>= 1U;
        }
        j ^= bit;

        if (i < j) {
            double tr = real[i];
            double ti = imag[i];
            real[i] = real[j];
            imag[i] = imag[j];
            real[j] = tr;
            imag[j] = ti;
        }
    }

    for (uint32_t len = 2U; len <= FFT2D_SIZE; len <<= 1U) {
        uint32_t half = len >> 1U;

        for (uint32_t i = 0U; i < FFT2D_SIZE; i += len) {
            for (uint32_t j = 0U; j < half; ++j) {
                double angle = -2.0 * FFT2D_PI * (double)j / (double)len;
                double wr = cos(angle);
                double wi = sin(angle);
                uint32_t even = i + j;
                uint32_t odd = even + half;
                double tr = real[odd] * wr - imag[odd] * wi;
                double ti = real[odd] * wi + imag[odd] * wr;
                double ur = real[even];
                double ui = imag[even];

                real[even] = ur + tr;
                imag[even] = ui + ti;
                real[odd] = ur - tr;
                imag[odd] = ui - ti;
            }
        }
    }
}

static void run_double_runtime_trig_reference(uint32_t test_index, uint64_t *ticks)
{
    XTime start_time;
    XTime end_time;
    double line_real[FFT2D_SIZE];
    double line_imag[FFT2D_SIZE];
    double checksum = 0.0;
    const uint32_t *test_input = rgb_image_test_inputs[test_index];

    XTime_GetTime(&start_time);

    for (uint32_t ch = 0U; ch < FFT2D_CHANNELS; ++ch) {
        uint32_t base = ch * FFT2D_PIXELS;

        for (uint32_t y = 0U; y < FFT2D_SIZE; ++y) {
            for (uint32_t x = 0U; x < FFT2D_SIZE; ++x) {
                line_real[x] = (double)signed_raw(test_input[base + y * FFT2D_SIZE + x]) / 4096.0;
                line_imag[x] = 0.0;
            }
            double_fft1d_64(line_real, line_imag);
            for (uint32_t x = 0U; x < FFT2D_SIZE; ++x) {
                ref_real_buffer[base + y * FFT2D_SIZE + x] = line_real[x];
                ref_imag_buffer[base + y * FFT2D_SIZE + x] = line_imag[x];
            }
        }

        for (uint32_t x = 0U; x < FFT2D_SIZE; ++x) {
            for (uint32_t y = 0U; y < FFT2D_SIZE; ++y) {
                line_real[y] = ref_real_buffer[base + y * FFT2D_SIZE + x];
                line_imag[y] = ref_imag_buffer[base + y * FFT2D_SIZE + x];
            }
            double_fft1d_64(line_real, line_imag);
            for (uint32_t y = 0U; y < FFT2D_SIZE; ++y) {
                ref_real_buffer[base + y * FFT2D_SIZE + x] = line_real[y];
                ref_imag_buffer[base + y * FFT2D_SIZE + x] = line_imag[y];
            }
        }

        checksum += ref_real_buffer[base];
        checksum += ref_imag_buffer[base + FFT2D_PIXELS - 1U];
    }

    XTime_GetTime(&end_time);

    double_fft_checksum = checksum;
    if (ticks != 0) {
        *ticks = (uint64_t)(end_time - start_time);
    }
}
#endif

static int run_fft_ip(uint64_t *ticks)
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

    if (ticks != 0) {
        *ticks = (uint64_t)(end_time - start_time);
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

static int compare_checker_with_python_reference(void)
{
    static const char channel_names[FFT2D_CHANNELS] = {'R', 'G', 'B'};
    uint32_t status_ok = 1U;

    xil_printf("PYTHON_REFERENCE_COMPARE_BEGIN,%s\r\n", CHECKER_REF_NAME);
    xil_printf("Columns: sample,channel,real_mae_raw,real_maxabs_raw,imag_mae_raw,imag_maxabs_raw,status\r\n");

    for (uint32_t ch = 0U; ch < FFT2D_CHANNELS; ++ch) {
        uint64_t real_sum_abs = 0ULL;
        uint64_t imag_sum_abs = 0ULL;
        uint32_t real_max_abs = 0U;
        uint32_t imag_max_abs = 0U;
        uint32_t base = ch * FFT2D_PIXELS;

        for (uint32_t bin = 0U; bin < FFT2D_PIXELS; ++bin) {
            uint32_t idx = base + bin;
            uint32_t real_abs = abs_raw_diff(output_real_buffer[idx], checker_ref_real_raw[idx]);
            uint32_t imag_abs = abs_raw_diff(output_imag_buffer[idx], checker_ref_imag_raw[idx]);

            real_sum_abs += (uint64_t)real_abs;
            imag_sum_abs += (uint64_t)imag_abs;
            if (real_abs > real_max_abs) {
                real_max_abs = real_abs;
            }
            if (imag_abs > imag_max_abs) {
                imag_max_abs = imag_abs;
            }
        }

        uint64_t real_mae_x10000 = (real_sum_abs * 10000ULL + (FFT2D_PIXELS / 2U)) / FFT2D_PIXELS;
        uint64_t imag_mae_x10000 = (imag_sum_abs * 10000ULL + (FFT2D_PIXELS / 2U)) / FFT2D_PIXELS;
        const char *status = (real_max_abs <= IMAGE_VERIFY_TOL_RAW && imag_max_abs <= IMAGE_VERIFY_TOL_RAW) ? "PASS" : "FAIL";

        if (status[0] != 'P') {
            status_ok = 0U;
        }

        xil_printf("PYTHON_REFERENCE_RESULT,%s,%c,", CHECKER_REF_NAME, channel_names[ch]);
        xil_print_fixed_x10000(real_mae_x10000);
        xil_printf(",%u,", (unsigned int)real_max_abs);
        xil_print_fixed_x10000(imag_mae_x10000);
        xil_printf(",%u,%s\r\n", (unsigned int)imag_max_abs, status);
    }

    xil_printf("PYTHON_REFERENCE_COMPARE_END,%s\r\n", (status_ok != 0U) ? "PASS" : "FAIL");

    return (status_ok != 0U) ? 0 : -1;
}

#if ENABLE_FULL_UART_DUMP
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
#endif

int main(void)
{
#if ENABLE_FULL_UART_DUMP
    const char *test_name = rgb_image_test_names[DUMP_TEST_INDEX];
#endif

    xil_printf("\r\nZynq RGB 2D FFT board benchmark and FPGA image dump app\r\n");
    xil_printf("IP base address: 0x%08x\r\n", (unsigned int)FFT2D_BASEADDR);
    xil_printf("Size=%ux%u, channels=%u, testcases=%u\r\n",
               (unsigned int)FFT2D_SIZE,
               (unsigned int)FFT2D_SIZE,
               (unsigned int)FFT2D_CHANNELS,
               (unsigned int)RGB_IMAGE_TEST_COUNT);
    xil_printf("Timer frequency: %u counts/s\r\n", (unsigned int)COUNTS_PER_SECOND);

    xil_printf("\r\nBOARD_BENCHMARK_BEGIN\r\n");
    xil_printf("Summary table columns: run,sample,cpu_ticks,cpu_us,fpga_ticks,fpga_us,speedup,status\r\n");
#if ENABLE_DOUBLE_RUNTIME_TRIG_BENCHMARK
    xil_printf("Reference table columns: run,sample,cpu_double_runtime_trig_ticks,cpu_double_runtime_trig_us,fpga_us,fpga_vs_reference_speedup,status\r\n");
#endif

    for (uint32_t run_index = 0U; run_index < BENCHMARK_RUN_COUNT; ++run_index) {
        const uint32_t test_index = DUMP_TEST_INDEX;
        uint64_t cpu_ticks = 0ULL;
        uint64_t fpga_ticks = 0ULL;
        uint64_t cpu_us = 0ULL;
        uint64_t fpga_us = 0ULL;
        uint64_t speedup_x100 = 0ULL;
#if ENABLE_DOUBLE_RUNTIME_TRIG_BENCHMARK
        uint64_t ref_ticks = 0ULL;
        uint64_t ref_us = 0ULL;
        uint64_t ref_speedup_x100 = 0ULL;
#endif

        xil_printf("Running testcase: %s, run %u/%u\r\n",
                   rgb_image_test_names[test_index],
                   (unsigned int)(run_index + 1U),
                   (unsigned int)BENCHMARK_RUN_COUNT);
        prepare_rgb_image_test(rgb_image_test_inputs[test_index]);

        xil_printf("  CPU software 2D FFT baseline on PS...\r\n");
        run_cpu_fft_reference(test_index, &cpu_ticks);
        cpu_us = xtime_to_us(cpu_ticks);
        xil_printf("  CPU checksum: 0x%08x\r\n", (unsigned int)cpu_fft_checksum);

#if ENABLE_DOUBLE_RUNTIME_TRIG_BENCHMARK
        xil_printf("  CPU double runtime-trig reference on PS...\r\n");
        run_double_runtime_trig_reference(test_index, &ref_ticks);
        ref_us = xtime_to_us(ref_ticks);
#endif

        xil_printf("  FPGA FFT accelerator in PL...\r\n");
        if (run_fft_ip(&fpga_ticks) != 0) {
            xil_printf("RGB FFT benchmark app failed.\r\n");
            return -1;
        }

        fpga_us = xtime_to_us(fpga_ticks);
        if (fpga_us != 0ULL) {
            speedup_x100 = (cpu_us * 100ULL) / fpga_us;
        }

        if (verify_rgb_image_fft(test_index) != 0) {
            xil_printf("RGB FFT benchmark app failed.\r\n");
            return -1;
        }

        if (test_index == CHECKER_REF_TEST_INDEX && compare_checker_with_python_reference() != 0) {
            xil_printf("RGB FFT Python reference comparison failed.\r\n");
            return -1;
        }

        xil_printf("BOARD_BENCHMARK_RESULT,%u,%s,",
                   (unsigned int)(run_index + 1U),
                   rgb_image_test_names[test_index]);
        xil_print_u64(cpu_ticks);
        xil_printf(",");
        xil_print_u64(cpu_us);
        xil_printf(",");
        xil_print_u64(fpga_ticks);
        xil_printf(",");
        xil_print_u64(fpga_us);
        xil_printf(",");
        xil_print_fixed_x100(speedup_x100);
        xil_printf(",PASS\r\n");

#if ENABLE_DOUBLE_RUNTIME_TRIG_BENCHMARK
        if (fpga_us != 0ULL) {
            ref_speedup_x100 = (ref_us * 100ULL) / fpga_us;
        }

        xil_printf("REFERENCE_BENCHMARK_RESULT,%u,%s,",
                   (unsigned int)(run_index + 1U),
                   rgb_image_test_names[test_index]);
        xil_print_u64(ref_ticks);
        xil_printf(",");
        xil_print_u64(ref_us);
        xil_printf(",");
        xil_print_u64(fpga_us);
        xil_printf(",");
        xil_print_fixed_x100(ref_speedup_x100);
        xil_printf(",PASS\r\n");
#endif
    }

    xil_printf("BOARD_BENCHMARK_END\r\n\r\n");

#if ENABLE_FULL_UART_DUMP
    prepare_rgb_image_test(rgb_image_test_inputs[DUMP_TEST_INDEX]);
    if (run_fft_ip(0) != 0 || verify_rgb_image_fft(DUMP_TEST_INDEX) != 0) {
        xil_printf("RGB FFT dump app failed.\r\n");
        return -1;
    }
    xil_printf("Output dump format: FFT_DUMP_BEGIN / D,ch,bin,real_hex,imag_hex / FFT_DUMP_END\r\n");
    xil_printf("Starting full FFT UART dump. Capture this log and run tools/render_fpga_fft_dump.py.\r\n");
    dump_full_fft_output_uart(test_name);
#else
    xil_printf("Full FFT UART dump disabled to keep Hercules log short.\r\n");
    xil_printf("Set ENABLE_FULL_UART_DUMP to 1 in main.c only when exporting spectrum data.\r\n");
#endif
    xil_printf("RGB FFT dump app passed.\r\n");

    return 0;
}
