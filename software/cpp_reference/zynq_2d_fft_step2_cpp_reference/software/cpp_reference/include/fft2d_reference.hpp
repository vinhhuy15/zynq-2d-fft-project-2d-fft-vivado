#ifndef FFT2D_REFERENCE_HPP
#define FFT2D_REFERENCE_HPP

#include <cstddef>
#include <string>
#include <vector>

struct Complex {
    double real;
    double imag;

    Complex(double r = 0.0, double i = 0.0) : real(r), imag(i) {}
};

Complex operator+(const Complex& a, const Complex& b);
Complex operator-(const Complex& a, const Complex& b);
Complex operator*(const Complex& a, const Complex& b);

bool is_power_of_two(std::size_t n);

void fft1d(std::vector<Complex>& a, bool inverse = false);

void fft2d(
    std::vector<Complex>& data,
    std::size_t height,
    std::size_t width,
    bool inverse = false
);

std::vector<double> read_matrix_txt(
    const std::string& path,
    std::size_t height,
    std::size_t width
);

void write_matrix_txt(
    const std::string& path,
    const std::vector<double>& data,
    std::size_t height,
    std::size_t width
);

struct Metrics {
    double mae;
    double mse;
    double rmse;
    double max_abs_error;
};

Metrics compare_vectors(
    const std::vector<double>& ref,
    const std::vector<double>& test
);

#endif
