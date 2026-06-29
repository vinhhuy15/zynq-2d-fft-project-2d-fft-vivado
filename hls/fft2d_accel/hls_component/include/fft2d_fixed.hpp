#ifndef FFT2D_FIXED_HPP
#define FFT2D_FIXED_HPP

#include <cstddef>

#ifndef FFT2D_HEIGHT
#define FFT2D_HEIGHT 64
#endif

#ifndef FFT2D_WIDTH
#define FFT2D_WIDTH 64
#endif

#if defined(USE_AP_FIXED)
#include <ap_fixed.h>
#ifndef FFT2D_FIXED_TOTAL_BITS
#define FFT2D_FIXED_TOTAL_BITS 32
#endif
#ifndef FFT2D_FIXED_INTEGER_BITS
#define FFT2D_FIXED_INTEGER_BITS 20
#endif
typedef ap_fixed<FFT2D_FIXED_TOTAL_BITS, FFT2D_FIXED_INTEGER_BITS, AP_RND, AP_SAT> data_t;
#else
typedef double data_t;
#endif

struct ComplexFixed {
    data_t real;
    data_t imag;

    ComplexFixed(data_t r = 0, data_t i = 0) : real(r), imag(i) {}
};

void fft2d_fixed_top(
    data_t input[FFT2D_HEIGHT][FFT2D_WIDTH],
    data_t output_real[FFT2D_HEIGHT][FFT2D_WIDTH],
    data_t output_imag[FFT2D_HEIGHT][FFT2D_WIDTH]
);

#endif
