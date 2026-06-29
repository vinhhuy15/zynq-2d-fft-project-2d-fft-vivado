#include "xparameters.h"
#include "xfft2d_fixed_top.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "xstatus.h"
#include "sleep.h"

#define FFT_H 64
#define FFT_W 64
#define FFT_N (FFT_H * FFT_W)
#define FIXED_FRAC_BITS 12
#define FFT_TIMEOUT 100000000U

static u32 input_buf[FFT_N] __attribute__((aligned(64)));
static u32 output_real_buf[FFT_N] __attribute__((aligned(64)));
static u32 output_imag_buf[FFT_N] __attribute__((aligned(64)));

static u32 fixed_from_int(int value)
{
    return (u32)(value << FIXED_FRAC_BITS);
}

static int fixed_to_int(u32 raw)
{
    return ((int)raw) >> FIXED_FRAC_BITS;
}

static void prepare_test_image(void)
{
    int r;
    int c;

    for (r = 0; r < FFT_H; ++r) {
        for (c = 0; c < FFT_W; ++c) {
            int idx = r * FFT_W + c;

            if (r >= 24 && r < 40 && c >= 24 && c < 40) {
                input_buf[idx] = fixed_from_int(255);
            } else {
                input_buf[idx] = fixed_from_int(0);
            }

            output_real_buf[idx] = 0;
            output_imag_buf[idx] = 0;
        }
    }
}

int main(void)
{
    XFft2d_fixed_top fft_ip;
    int status;
    u32 wait_count = 0;

    xil_printf("\r\n2D FFT hardware test start\r\n");

    prepare_test_image();

    status = XFft2d_fixed_top_Initialize(&fft_ip, XPAR_FFT2D_FIXED_TOP_0_DEVICE_ID);
    if (status != XST_SUCCESS) {
        xil_printf("ERROR: Cannot initialize fft2d_fixed_top\r\n");
        return XST_FAILURE;
    }

    XFft2d_fixed_top_Set_input_V(&fft_ip, (u32)input_buf);
    XFft2d_fixed_top_Set_output_real_V(&fft_ip, (u32)output_real_buf);
    XFft2d_fixed_top_Set_output_imag_V(&fft_ip, (u32)output_imag_buf);

    Xil_DCacheFlushRange((u32)input_buf, sizeof(input_buf));
    Xil_DCacheFlushRange((u32)output_real_buf, sizeof(output_real_buf));
    Xil_DCacheFlushRange((u32)output_imag_buf, sizeof(output_imag_buf));

    xil_printf("Starting FFT IP...\r\n");
    XFft2d_fixed_top_Start(&fft_ip);

    while (!XFft2d_fixed_top_IsDone(&fft_ip)) {
        if (++wait_count >= FFT_TIMEOUT) {
            xil_printf("ERROR: FFT IP timeout\r\n");
            return XST_FAILURE;
        }
    }

    Xil_DCacheInvalidateRange((u32)output_real_buf, sizeof(output_real_buf));
    Xil_DCacheInvalidateRange((u32)output_imag_buf, sizeof(output_imag_buf));

    xil_printf("FFT IP done\r\n");
    xil_printf("Sample outputs, raw fixed-point and integer approximation:\r\n");
    xil_printf("[0] real raw=0x%08x int=%d, imag raw=0x%08x int=%d\r\n",
               output_real_buf[0], fixed_to_int(output_real_buf[0]),
               output_imag_buf[0], fixed_to_int(output_imag_buf[0]));
    xil_printf("[1] real raw=0x%08x int=%d, imag raw=0x%08x int=%d\r\n",
               output_real_buf[1], fixed_to_int(output_real_buf[1]),
               output_imag_buf[1], fixed_to_int(output_imag_buf[1]));
    xil_printf("[64] real raw=0x%08x int=%d, imag raw=0x%08x int=%d\r\n",
               output_real_buf[64], fixed_to_int(output_real_buf[64]),
               output_imag_buf[64], fixed_to_int(output_imag_buf[64]));

    xil_printf("2D FFT hardware test finished\r\n");
    return XST_SUCCESS;
}
