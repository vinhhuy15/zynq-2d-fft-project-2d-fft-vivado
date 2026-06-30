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
#ifndef HLS_TEST_MAX_ABS_TOLERANCE
#define HLS_TEST_MAX_ABS_TOLERANCE 1024.0
#endif
static const double MAX_ABS_TOLERANCE = HLS_TEST_MAX_ABS_TOLERANCE;
#else
static const double MAX_ABS_TOLERANCE = 1e-6;
#endif

static const char* CHANNEL_NAMES[FFT2D_CHANNELS] = {"r", "g", "b"};

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
    std::string input_paths[FFT2D_CHANNELS];
    std::string ref_real_paths[FFT2D_CHANNELS];
    std::string ref_imag_paths[FFT2D_CHANNELS];
    std::string out_real_paths[FFT2D_CHANNELS];
    std::string out_imag_paths[FFT2D_CHANNELS];

    for (int ch = 0; ch < FFT2D_CHANNELS; ch++) {
        const std::string suffix = CHANNEL_NAMES[ch];
        input_paths[ch] = find_project_file(
            "software/python_reference/zynq_2d_fft_python_reference/data/input/square_64x64_" + suffix + "_matrix_2d.txt");
        ref_real_paths[ch] = find_project_file(
            "software/python_reference/zynq_2d_fft_python_reference/data/reference/square_64x64_" + suffix + "_fft_real_2d.txt");
        ref_imag_paths[ch] = find_project_file(
            "software/python_reference/zynq_2d_fft_python_reference/data/reference/square_64x64_" + suffix + "_fft_imag_2d.txt");
        out_real_paths[ch] = "hls_square_64x64_" + suffix + "_real.txt";
        out_imag_paths[ch] = "hls_square_64x64_" + suffix + "_imag.txt";
    }

    if (argc == 16) {
        for (int ch = 0; ch < FFT2D_CHANNELS; ch++) {
            input_paths[ch] = argv[1 + ch];
            ref_real_paths[ch] = argv[4 + ch];
            ref_imag_paths[ch] = argv[7 + ch];
            out_real_paths[ch] = argv[10 + ch];
            out_imag_paths[ch] = argv[13 + ch];
        }
    } else if (argc != 1) {
        std::cerr
            << "Usage:\n"
            << "  " << argv[0]
            << " <input_r> <input_g> <input_b>"
            << " <ref_real_r> <ref_real_g> <ref_real_b>"
            << " <ref_imag_r> <ref_imag_g> <ref_imag_b>"
            << " <output_real_r> <output_real_g> <output_real_b>"
            << " <output_imag_r> <output_imag_g> <output_imag_b>\n";
        return 1;
    }

    try {
        static data_t input[FFT2D_CHANNELS][FFT2D_HEIGHT][FFT2D_WIDTH];
        static data_t output_real[FFT2D_CHANNELS][FFT2D_HEIGHT][FFT2D_WIDTH];
        static data_t output_imag[FFT2D_CHANNELS][FFT2D_HEIGHT][FFT2D_WIDTH];
        static double ref_real[FFT2D_CHANNELS][FFT2D_HEIGHT][FFT2D_WIDTH];
        static double ref_imag[FFT2D_CHANNELS][FFT2D_HEIGHT][FFT2D_WIDTH];

        for (int ch = 0; ch < FFT2D_CHANNELS; ch++) {
            read_matrix(input_paths[ch], input[ch]);
            read_matrix_double(ref_real_paths[ch], ref_real[ch]);
            read_matrix_double(ref_imag_paths[ch], ref_imag[ch]);
        }

        fft2d_fixed_top(input, output_real, output_imag);

        std::cout << std::fixed << std::setprecision(10);
        std::cout << "Color FFT2D HLS-prep testbench complete.\n";
        std::cout << "Size: " << FFT2D_WIDTH << "x" << FFT2D_HEIGHT << "\n";
        std::cout << "Pass tolerance MaxAbs <= " << MAX_ABS_TOLERANCE << "\n";

        bool pass = true;
        for (int ch = 0; ch < FFT2D_CHANNELS; ch++) {
            write_matrix(out_real_paths[ch], output_real[ch]);
            write_matrix(out_imag_paths[ch], output_imag[ch]);

            const Metrics real_metrics = compare_matrix(ref_real[ch], output_real[ch]);
            const Metrics imag_metrics = compare_matrix(ref_imag[ch], output_imag[ch]);

            std::cout << "Channel " << CHANNEL_NAMES[ch] << " Real MAE: " << real_metrics.mae
                      << ", MSE: " << real_metrics.mse
                      << ", RMSE: " << real_metrics.rmse
                      << ", MaxAbs: " << real_metrics.max_abs_error << "\n";
            std::cout << "Channel " << CHANNEL_NAMES[ch] << " Imag MAE: " << imag_metrics.mae
                      << ", MSE: " << imag_metrics.mse
                      << ", RMSE: " << imag_metrics.rmse
                      << ", MaxAbs: " << imag_metrics.max_abs_error << "\n";

            pass = pass &&
                real_metrics.max_abs_error <= MAX_ABS_TOLERANCE &&
                imag_metrics.max_abs_error <= MAX_ABS_TOLERANCE;
        }

        return pass ? 0 : 2;
    } catch (const std::exception& e) {
        std::cerr << "ERROR: " << e.what() << "\n";
        return 3;
    }
}
