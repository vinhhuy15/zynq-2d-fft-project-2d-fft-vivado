#include "fft2d_reference.hpp"

#include <algorithm>
#include <cmath>
#include <fstream>
#include <stdexcept>

static const double PI = std::acos(-1.0);

Complex operator+(const Complex& a, const Complex& b) {
    return Complex(a.real + b.real, a.imag + b.imag);
}

Complex operator-(const Complex& a, const Complex& b) {
    return Complex(a.real - b.real, a.imag - b.imag);
}

Complex operator*(const Complex& a, const Complex& b) {
    return Complex(
        a.real * b.real - a.imag * b.imag,
        a.real * b.imag + a.imag * b.real
    );
}

bool is_power_of_two(std::size_t n) {
    return n > 0 && ((n & (n - 1)) == 0);
}

// Iterative radix-2 Cooley-Tukey FFT.
// Forward convention matches numpy.fft.fft:
// X[k] = sum_n x[n] * exp(-j * 2pi * k * n / N)
// Forward FFT is not normalized.
void fft1d(std::vector<Complex>& a, bool inverse) {
    const std::size_t n = a.size();

    if (!is_power_of_two(n)) {
        throw std::runtime_error("fft1d only supports power-of-two length.");
    }

    // Bit-reversal permutation
    for (std::size_t i = 1, j = 0; i < n; i++) {
        std::size_t bit = n >> 1;

        while (j & bit) {
            j ^= bit;
            bit >>= 1;
        }

        j ^= bit;

        if (i < j) {
            std::swap(a[i], a[j]);
        }
    }

    // Butterfly stages
    for (std::size_t len = 2; len <= n; len <<= 1) {
        double angle = 2.0 * PI / static_cast<double>(len);
        if (!inverse) {
            angle = -angle;
        }

        Complex wlen(std::cos(angle), std::sin(angle));

        for (std::size_t i = 0; i < n; i += len) {
            Complex w(1.0, 0.0);

            for (std::size_t j = 0; j < len / 2; j++) {
                Complex u = a[i + j];
                Complex v = a[i + j + len / 2] * w;

                a[i + j] = u + v;
                a[i + j + len / 2] = u - v;

                w = w * wlen;
            }
        }
    }

    if (inverse) {
        for (auto& x : a) {
            x.real /= static_cast<double>(n);
            x.imag /= static_cast<double>(n);
        }
    }
}

void fft2d(
    std::vector<Complex>& data,
    std::size_t height,
    std::size_t width,
    bool inverse
) {
    if (!is_power_of_two(height) || !is_power_of_two(width)) {
        throw std::runtime_error("fft2d requires power-of-two height and width.");
    }

    if (data.size() != height * width) {
        throw std::runtime_error("data size does not match height * width.");
    }

    // FFT each row
    for (std::size_t r = 0; r < height; r++) {
        std::vector<Complex> row(width);

        for (std::size_t c = 0; c < width; c++) {
            row[c] = data[r * width + c];
        }

        fft1d(row, inverse);

        for (std::size_t c = 0; c < width; c++) {
            data[r * width + c] = row[c];
        }
    }

    // FFT each column
    for (std::size_t c = 0; c < width; c++) {
        std::vector<Complex> col(height);

        for (std::size_t r = 0; r < height; r++) {
            col[r] = data[r * width + c];
        }

        fft1d(col, inverse);

        for (std::size_t r = 0; r < height; r++) {
            data[r * width + c] = col[r];
        }
    }
}

std::vector<double> read_matrix_txt(
    const std::string& path,
    std::size_t height,
    std::size_t width
) {
    std::ifstream fin(path);
    if (!fin) {
        throw std::runtime_error("Cannot open file: " + path);
    }

    std::vector<double> data(height * width);

    for (std::size_t i = 0; i < height * width; i++) {
        if (!(fin >> data[i])) {
            throw std::runtime_error("Not enough numbers in file: " + path);
        }
    }

    return data;
}

void write_matrix_txt(
    const std::string& path,
    const std::vector<double>& data,
    std::size_t height,
    std::size_t width
) {
    if (data.size() != height * width) {
        throw std::runtime_error("write_matrix_txt size mismatch.");
    }

    std::ofstream fout(path);
    if (!fout) {
        throw std::runtime_error("Cannot write file: " + path);
    }

    fout.setf(std::ios::fixed);
    fout.precision(10);

    for (std::size_t r = 0; r < height; r++) {
        for (std::size_t c = 0; c < width; c++) {
            fout << data[r * width + c];

            if (c + 1 < width) {
                fout << " ";
            }
        }

        fout << "\n";
    }
}

Metrics compare_vectors(
    const std::vector<double>& ref,
    const std::vector<double>& test
) {
    if (ref.size() != test.size()) {
        throw std::runtime_error("compare_vectors size mismatch.");
    }

    double abs_sum = 0.0;
    double sq_sum = 0.0;
    double max_abs = 0.0;

    for (std::size_t i = 0; i < ref.size(); i++) {
        double diff = test[i] - ref[i];
        double abs_diff = std::abs(diff);

        abs_sum += abs_diff;
        sq_sum += diff * diff;
        max_abs = std::max(max_abs, abs_diff);
    }

    Metrics m;
    m.mae = abs_sum / static_cast<double>(ref.size());
    m.mse = sq_sum / static_cast<double>(ref.size());
    m.rmse = std::sqrt(m.mse);
    m.max_abs_error = max_abs;
    return m;
}
