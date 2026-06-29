#include "fft2d_fixed.hpp"

#include <algorithm>
#include <cmath>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

#if defined(USE_AP_FIXED)
static const double MAX_ABS_TOLERANCE = 1024.0;
#else
static const double MAX_ABS_TOLERANCE = 1e-6;
#endif

struct Metrics {
    double mae;
    double mse;
    double rmse;
    double max_abs_error;
};

static void read_matrix(const std::string& path, data_t matrix[FFT2D_HEIGHT][FFT2D_WIDTH]) {
    std::ifstream fin(path);
    if (!fin) {
        throw std::runtime_error("Cannot open file: " + path);
    }

    for (int r = 0; r < FFT2D_HEIGHT; r++) {
        for (int c = 0; c < FFT2D_WIDTH; c++) {
            double value = 0.0;
            if (!(fin >> value)) {
                throw std::runtime_error("Not enough values in file: " + path);
            }
            matrix[r][c] = static_cast<data_t>(value);
        }
    }
}

static bool file_exists(const std::string& path) {
    std::ifstream fin(path);
    return fin.good();
}

static std::string find_project_file(const std::string& project_relative_path) {
    std::string prefix;
    for (int depth = 0; depth <= 12; ++depth) {
        const std::string candidate = prefix + project_relative_path;
        if (file_exists(candidate)) {
            return candidate;
        }
        prefix += "../";
    }

    return project_relative_path;
}

static void read_matrix_double(const std::string& path, double matrix[FFT2D_HEIGHT][FFT2D_WIDTH]) {
    std::ifstream fin(path);
    if (!fin) {
        throw std::runtime_error("Cannot open file: " + path);
    }

    for (int r = 0; r < FFT2D_HEIGHT; r++) {
        for (int c = 0; c < FFT2D_WIDTH; c++) {
            if (!(fin >> matrix[r][c])) {
                throw std::runtime_error("Not enough values in file: " + path);
            }
        }
    }
}

static void write_matrix(const std::string& path, data_t matrix[FFT2D_HEIGHT][FFT2D_WIDTH]) {
    std::ofstream fout(path);
    if (!fout) {
        throw std::runtime_error("Cannot write file: " + path);
    }

    fout << std::fixed << std::setprecision(10);
    for (int r = 0; r < FFT2D_HEIGHT; r++) {
        for (int c = 0; c < FFT2D_WIDTH; c++) {
            fout << static_cast<double>(matrix[r][c]);
            if (c + 1 < FFT2D_WIDTH) {
                fout << " ";
            }
        }
        fout << "\n";
    }
}

static Metrics compare_matrix(
    double reference[FFT2D_HEIGHT][FFT2D_WIDTH],
    data_t test[FFT2D_HEIGHT][FFT2D_WIDTH]
) {
    double abs_sum = 0.0;
    double sq_sum = 0.0;
    double max_abs = 0.0;

    for (int r = 0; r < FFT2D_HEIGHT; r++) {
        for (int c = 0; c < FFT2D_WIDTH; c++) {
            const double diff = static_cast<double>(test[r][c]) - reference[r][c];
            const double abs_diff = std::abs(diff);
            abs_sum += abs_diff;
            sq_sum += diff * diff;
            max_abs = std::max(max_abs, abs_diff);
        }
    }

    const double count = static_cast<double>(FFT2D_HEIGHT * FFT2D_WIDTH);
    Metrics metrics;
    metrics.mae = abs_sum / count;
    metrics.mse = sq_sum / count;
    metrics.rmse = std::sqrt(metrics.mse);
    metrics.max_abs_error = max_abs;
    return metrics;
}

int main(int argc, char** argv) {
    std::string input_path = find_project_file(
        "software/python_reference/zynq_2d_fft_python_reference/data/input/square_64x64_matrix_2d.txt");
    std::string ref_real_path = find_project_file(
        "software/python_reference/zynq_2d_fft_python_reference/data/reference/square_64x64_fft_real_2d.txt");
    std::string ref_imag_path = find_project_file(
        "software/python_reference/zynq_2d_fft_python_reference/data/reference/square_64x64_fft_imag_2d.txt");
    std::string out_real_path = "hls_square_64x64_real.txt";
    std::string out_imag_path = "hls_square_64x64_imag.txt";

    if (argc == 6) {
        input_path = argv[1];
        ref_real_path = argv[2];
        ref_imag_path = argv[3];
        out_real_path = argv[4];
        out_imag_path = argv[5];
    } else if (argc != 1) {
        std::cerr
            << "Usage:\n"
            << "  " << argv[0]
            << " <input_matrix> <ref_real> <ref_imag> <output_real> <output_imag>\n";
        return 1;
    }

    try {
        static data_t input[FFT2D_HEIGHT][FFT2D_WIDTH];
        static data_t output_real[FFT2D_HEIGHT][FFT2D_WIDTH];
        static data_t output_imag[FFT2D_HEIGHT][FFT2D_WIDTH];
        static double ref_real[FFT2D_HEIGHT][FFT2D_WIDTH];
        static double ref_imag[FFT2D_HEIGHT][FFT2D_WIDTH];

        read_matrix(input_path, input);
        read_matrix_double(ref_real_path, ref_real);
        read_matrix_double(ref_imag_path, ref_imag);

        fft2d_fixed_top(input, output_real, output_imag);

        write_matrix(out_real_path, output_real);
        write_matrix(out_imag_path, output_imag);

        const Metrics real_metrics = compare_matrix(ref_real, output_real);
        const Metrics imag_metrics = compare_matrix(ref_imag, output_imag);

        std::cout << std::fixed << std::setprecision(10);
        std::cout << "FFT2D HLS-prep testbench complete.\n";
        std::cout << "Size: " << FFT2D_WIDTH << "x" << FFT2D_HEIGHT << "\n";
        std::cout << "Real MAE: " << real_metrics.mae
                  << ", MSE: " << real_metrics.mse
                  << ", RMSE: " << real_metrics.rmse
                  << ", MaxAbs: " << real_metrics.max_abs_error << "\n";
        std::cout << "Imag MAE: " << imag_metrics.mae
                  << ", MSE: " << imag_metrics.mse
                  << ", RMSE: " << imag_metrics.rmse
                  << ", MaxAbs: " << imag_metrics.max_abs_error << "\n";
        std::cout << "Pass tolerance MaxAbs <= " << MAX_ABS_TOLERANCE << "\n";

        return (
            real_metrics.max_abs_error <= MAX_ABS_TOLERANCE &&
            imag_metrics.max_abs_error <= MAX_ABS_TOLERANCE
        ) ? 0 : 2;
    } catch (const std::exception& e) {
        std::cerr << "ERROR: " << e.what() << "\n";
        return 3;
    }
}
