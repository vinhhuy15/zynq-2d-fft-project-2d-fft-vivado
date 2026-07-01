#include "fft2d_fixed.hpp"

#include <cmath>

/*
 * Pre-optimization reference version.
 *
 * This file keeps the same top-level interface and FFT flow as the optimized
 * implementation, but computes twiddle factors with runtime cos/sin calls.
 * Use it only for resource-comparison synthesis. Do not compile it together
 * with fft2d_fixed.cpp because both files define fft2d_fixed_top().
 */

static ComplexFixed twiddle_runtime(int j, int len) {
    const double pi = 3.14159265358979323846264338327950288;
    const double angle = -2.0 * pi * static_cast<double>(j) / static_cast<double>(len);
    return ComplexFixed(
        static_cast<data_t>(std::cos(angle)),
        static_cast<data_t>(std::sin(angle))
    );
}

static ComplexFixed complex_add(const ComplexFixed& a, const ComplexFixed& b) {
    return ComplexFixed(a.real + b.real, a.imag + b.imag);
}

static ComplexFixed complex_sub(const ComplexFixed& a, const ComplexFixed& b) {
    return ComplexFixed(a.real - b.real, a.imag - b.imag);
}

static ComplexFixed complex_mul(const ComplexFixed& a, const ComplexFixed& b) {
    return ComplexFixed(
        a.real * b.real - a.imag * b.imag,
        a.real * b.imag + a.imag * b.real
    );
}

static void fft1d_fixed(ComplexFixed data[FFT2D_WIDTH], int n) {
    for (int i = 1, j = 0; i < n; i++) {
        int bit = n >> 1;

        while (j & bit) {
            j ^= bit;
            bit >>= 1;
        }

        j ^= bit;

        if (i < j) {
            ComplexFixed tmp = data[i];
            data[i] = data[j];
            data[j] = tmp;
        }
    }

    for (int len = 2; len <= n; len <<= 1) {
        for (int i = 0; i < n; i += len) {
            for (int j = 0; j < len / 2; j++) {
                const ComplexFixed w = twiddle_runtime(j, len);
                const ComplexFixed u = data[i + j];
                const ComplexFixed v = complex_mul(data[i + j + len / 2], w);

                data[i + j] = complex_add(u, v);
                data[i + j + len / 2] = complex_sub(u, v);
            }
        }
    }
}

static void fft1d_fixed_col(ComplexFixed data[FFT2D_HEIGHT], int n) {
    for (int i = 1, j = 0; i < n; i++) {
        int bit = n >> 1;

        while (j & bit) {
            j ^= bit;
            bit >>= 1;
        }

        j ^= bit;

        if (i < j) {
            ComplexFixed tmp = data[i];
            data[i] = data[j];
            data[j] = tmp;
        }
    }

    for (int len = 2; len <= n; len <<= 1) {
        for (int i = 0; i < n; i += len) {
            for (int j = 0; j < len / 2; j++) {
                const ComplexFixed w = twiddle_runtime(j, len);
                const ComplexFixed u = data[i + j];
                const ComplexFixed v = complex_mul(data[i + j + len / 2], w);

                data[i + j] = complex_add(u, v);
                data[i + j + len / 2] = complex_sub(u, v);
            }
        }
    }
}

void fft2d_fixed_top(
    data_t input[FFT2D_CHANNELS][FFT2D_HEIGHT][FFT2D_WIDTH],
    data_t output_real[FFT2D_CHANNELS][FFT2D_HEIGHT][FFT2D_WIDTH],
    data_t output_imag[FFT2D_CHANNELS][FFT2D_HEIGHT][FFT2D_WIDTH]
) {
#pragma HLS INTERFACE m_axi port=input offset=slave bundle=gmem0
#pragma HLS INTERFACE m_axi port=output_real offset=slave bundle=gmem1
#pragma HLS INTERFACE m_axi port=output_imag offset=slave bundle=gmem2
#pragma HLS INTERFACE s_axilite port=input bundle=CTRL
#pragma HLS INTERFACE s_axilite port=output_real bundle=CTRL
#pragma HLS INTERFACE s_axilite port=output_imag bundle=CTRL
#pragma HLS INTERFACE s_axilite port=return bundle=CTRL

    static ComplexFixed matrix[FFT2D_CHANNELS][FFT2D_HEIGHT][FFT2D_WIDTH];
    ComplexFixed row_buffer[FFT2D_WIDTH];
    ComplexFixed col_buffer[FFT2D_HEIGHT];

    for (int ch = 0; ch < FFT2D_CHANNELS; ch++) {
        for (int r = 0; r < FFT2D_HEIGHT; r++) {
            for (int c = 0; c < FFT2D_WIDTH; c++) {
                matrix[ch][r][c].real = input[ch][r][c];
                matrix[ch][r][c].imag = 0;
            }
        }
    }

    for (int ch = 0; ch < FFT2D_CHANNELS; ch++) {
        for (int r = 0; r < FFT2D_HEIGHT; r++) {
            for (int c = 0; c < FFT2D_WIDTH; c++) {
                row_buffer[c] = matrix[ch][r][c];
            }

            fft1d_fixed(row_buffer, FFT2D_WIDTH);

            for (int c = 0; c < FFT2D_WIDTH; c++) {
                matrix[ch][r][c] = row_buffer[c];
            }
        }
    }

    for (int ch = 0; ch < FFT2D_CHANNELS; ch++) {
        for (int c = 0; c < FFT2D_WIDTH; c++) {
            for (int r = 0; r < FFT2D_HEIGHT; r++) {
                col_buffer[r] = matrix[ch][r][c];
            }

            fft1d_fixed_col(col_buffer, FFT2D_HEIGHT);

            for (int r = 0; r < FFT2D_HEIGHT; r++) {
                matrix[ch][r][c] = col_buffer[r];
            }
        }
    }

    for (int ch = 0; ch < FFT2D_CHANNELS; ch++) {
        for (int r = 0; r < FFT2D_HEIGHT; r++) {
            for (int c = 0; c < FFT2D_WIDTH; c++) {
                output_real[ch][r][c] = matrix[ch][r][c].real;
                output_imag[ch][r][c] = matrix[ch][r][c].imag;
            }
        }
    }
}
