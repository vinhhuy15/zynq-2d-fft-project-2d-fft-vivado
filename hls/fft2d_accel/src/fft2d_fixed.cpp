#include "fft2d_fixed.hpp"

#if FFT2D_WIDTH > 64 || FFT2D_HEIGHT > 64
#error "The current twiddle lookup table supports FFT sizes up to 64 points."
#endif

static const int TWIDDLE_TABLE_SIZE = 64;

static const data_t TWIDDLE_REAL[TWIDDLE_TABLE_SIZE / 2] = {
    static_cast<data_t>(1.0),
    static_cast<data_t>(0.99518472667219693),
    static_cast<data_t>(0.98078528040323043),
    static_cast<data_t>(0.95694033573220882),
    static_cast<data_t>(0.92387953251128674),
    static_cast<data_t>(0.88192126434835505),
    static_cast<data_t>(0.83146961230254524),
    static_cast<data_t>(0.77301045336273699),
    static_cast<data_t>(0.70710678118654757),
    static_cast<data_t>(0.63439328416364549),
    static_cast<data_t>(0.55557023301960229),
    static_cast<data_t>(0.47139673682599781),
    static_cast<data_t>(0.38268343236508984),
    static_cast<data_t>(0.29028467725446233),
    static_cast<data_t>(0.19509032201612833),
    static_cast<data_t>(0.09801714032956077),
    static_cast<data_t>(0.0),
    static_cast<data_t>(-0.098017140329560645),
    static_cast<data_t>(-0.19509032201612819),
    static_cast<data_t>(-0.29028467725446216),
    static_cast<data_t>(-0.38268343236508973),
    static_cast<data_t>(-0.4713967368259977),
    static_cast<data_t>(-0.55557023301960196),
    static_cast<data_t>(-0.63439328416364538),
    static_cast<data_t>(-0.70710678118654746),
    static_cast<data_t>(-0.77301045336273699),
    static_cast<data_t>(-0.83146961230254535),
    static_cast<data_t>(-0.88192126434835494),
    static_cast<data_t>(-0.92387953251128674),
    static_cast<data_t>(-0.95694033573220882),
    static_cast<data_t>(-0.98078528040323043),
    static_cast<data_t>(-0.99518472667219682)
};

static const data_t TWIDDLE_IMAG[TWIDDLE_TABLE_SIZE / 2] = {
    static_cast<data_t>(0.0),
    static_cast<data_t>(-0.098017140329560604),
    static_cast<data_t>(-0.19509032201612825),
    static_cast<data_t>(-0.29028467725446233),
    static_cast<data_t>(-0.38268343236508978),
    static_cast<data_t>(-0.47139673682599764),
    static_cast<data_t>(-0.55557023301960218),
    static_cast<data_t>(-0.63439328416364549),
    static_cast<data_t>(-0.70710678118654757),
    static_cast<data_t>(-0.77301045336273688),
    static_cast<data_t>(-0.83146961230254524),
    static_cast<data_t>(-0.88192126434835494),
    static_cast<data_t>(-0.92387953251128674),
    static_cast<data_t>(-0.95694033573220894),
    static_cast<data_t>(-0.98078528040323043),
    static_cast<data_t>(-0.99518472667219682),
    static_cast<data_t>(-1.0),
    static_cast<data_t>(-0.99518472667219693),
    static_cast<data_t>(-0.98078528040323043),
    static_cast<data_t>(-0.95694033573220894),
    static_cast<data_t>(-0.92387953251128674),
    static_cast<data_t>(-0.88192126434835505),
    static_cast<data_t>(-0.83146961230254535),
    static_cast<data_t>(-0.7730104533627371),
    static_cast<data_t>(-0.70710678118654757),
    static_cast<data_t>(-0.63439328416364549),
    static_cast<data_t>(-0.55557023301960218),
    static_cast<data_t>(-0.47139673682599781),
    static_cast<data_t>(-0.38268343236508989),
    static_cast<data_t>(-0.29028467725446239),
    static_cast<data_t>(-0.19509032201612861),
    static_cast<data_t>(-0.098017140329560826)
};

static ComplexFixed twiddle_at(int j, int len) {
    const int index = (j * TWIDDLE_TABLE_SIZE) / len;
    return ComplexFixed(TWIDDLE_REAL[index], TWIDDLE_IMAG[index]);
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
                const ComplexFixed w = twiddle_at(j, len);
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
                const ComplexFixed w = twiddle_at(j, len);
                const ComplexFixed u = data[i + j];
                const ComplexFixed v = complex_mul(data[i + j + len / 2], w);

                data[i + j] = complex_add(u, v);
                data[i + j + len / 2] = complex_sub(u, v);
            }
        }
    }
}

void fft2d_fixed_top(
    data_t input[FFT2D_HEIGHT][FFT2D_WIDTH],
    data_t output_real[FFT2D_HEIGHT][FFT2D_WIDTH],
    data_t output_imag[FFT2D_HEIGHT][FFT2D_WIDTH]
) {
#pragma HLS INTERFACE m_axi port=input offset=slave bundle=gmem0
#pragma HLS INTERFACE m_axi port=output_real offset=slave bundle=gmem1
#pragma HLS INTERFACE m_axi port=output_imag offset=slave bundle=gmem2
#pragma HLS INTERFACE s_axilite port=input bundle=CTRL
#pragma HLS INTERFACE s_axilite port=output_real bundle=CTRL
#pragma HLS INTERFACE s_axilite port=output_imag bundle=CTRL
#pragma HLS INTERFACE s_axilite port=return bundle=CTRL

    static ComplexFixed matrix[FFT2D_HEIGHT][FFT2D_WIDTH];
    ComplexFixed row_buffer[FFT2D_WIDTH];
    ComplexFixed col_buffer[FFT2D_HEIGHT];

    for (int r = 0; r < FFT2D_HEIGHT; r++) {
        for (int c = 0; c < FFT2D_WIDTH; c++) {
            matrix[r][c].real = input[r][c];
            matrix[r][c].imag = 0;
        }
    }

    for (int r = 0; r < FFT2D_HEIGHT; r++) {
        for (int c = 0; c < FFT2D_WIDTH; c++) {
            row_buffer[c] = matrix[r][c];
        }

        fft1d_fixed(row_buffer, FFT2D_WIDTH);

        for (int c = 0; c < FFT2D_WIDTH; c++) {
            matrix[r][c] = row_buffer[c];
        }
    }

    for (int c = 0; c < FFT2D_WIDTH; c++) {
        for (int r = 0; r < FFT2D_HEIGHT; r++) {
            col_buffer[r] = matrix[r][c];
        }

        fft1d_fixed_col(col_buffer, FFT2D_HEIGHT);

        for (int r = 0; r < FFT2D_HEIGHT; r++) {
            matrix[r][c] = col_buffer[r];
        }
    }

    for (int r = 0; r < FFT2D_HEIGHT; r++) {
        for (int c = 0; c < FFT2D_WIDTH; c++) {
            output_real[r][c] = matrix[r][c].real;
            output_imag[r][c] = matrix[r][c].imag;
        }
    }
}
