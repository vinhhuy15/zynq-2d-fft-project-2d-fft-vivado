#include "fft2d_reference.hpp"

#include <chrono>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <string>
#include <vector>

static void usage(const char* exe) {
    std::cout
        << "Usage:\n"
        << "  " << exe << " <height> <width> <input_matrix_txt> <output_prefix> [ref_real_txt] [ref_imag_txt]\n\n"
        << "Example:\n"
        << "  " << exe << " 64 64 ../../data/input/square_64x64_matrix_2d.txt output/square_64x64 ../../data/reference/square_64x64_fft_real_2d.txt ../../data/reference/square_64x64_fft_imag_2d.txt\n";
}

int main(int argc, char** argv) {
    if (argc != 5 && argc != 7) {
        usage(argv[0]);
        return 1;
    }

    try {
        std::size_t height = static_cast<std::size_t>(std::stoul(argv[1]));
        std::size_t width = static_cast<std::size_t>(std::stoul(argv[2]));

        std::string input_path = argv[3];
        std::string output_prefix = argv[4];

        std::vector<double> input = read_matrix_txt(input_path, height, width);

        std::vector<Complex> data(height * width);
        for (std::size_t i = 0; i < height * width; i++) {
            data[i].real = input[i];
            data[i].imag = 0.0;
        }

        auto t0 = std::chrono::high_resolution_clock::now();
        fft2d(data, height, width, false);
        auto t1 = std::chrono::high_resolution_clock::now();

        double elapsed_ms = std::chrono::duration<double, std::milli>(t1 - t0).count();

        std::vector<double> out_real(height * width);
        std::vector<double> out_imag(height * width);

        for (std::size_t i = 0; i < height * width; i++) {
            out_real[i] = data[i].real;
            out_imag[i] = data[i].imag;
        }

        std::string real_path = output_prefix + "_cpp_fft_real_2d.txt";
        std::string imag_path = output_prefix + "_cpp_fft_imag_2d.txt";

        write_matrix_txt(real_path, out_real, height, width);
        write_matrix_txt(imag_path, out_imag, height, width);

        std::cout << std::fixed << std::setprecision(10);
        std::cout << "C++ 2D FFT done.\n";
        std::cout << "Size: " << width << "x" << height << "\n";
        std::cout << "Time_ms: " << elapsed_ms << "\n";
        std::cout << "Output real: " << real_path << "\n";
        std::cout << "Output imag: " << imag_path << "\n";

        if (argc == 7) {
            std::vector<double> ref_real = read_matrix_txt(argv[5], height, width);
            std::vector<double> ref_imag = read_matrix_txt(argv[6], height, width);

            Metrics real_m = compare_vectors(ref_real, out_real);
            Metrics imag_m = compare_vectors(ref_imag, out_imag);

            std::cout << "\nComparison with Python NumPy reference:\n";
            std::cout << "Real MAE: " << real_m.mae
                      << ", MSE: " << real_m.mse
                      << ", RMSE: " << real_m.rmse
                      << ", MaxAbs: " << real_m.max_abs_error << "\n";
            std::cout << "Imag MAE: " << imag_m.mae
                      << ", MSE: " << imag_m.mse
                      << ", RMSE: " << imag_m.rmse
                      << ", MaxAbs: " << imag_m.max_abs_error << "\n";
        }

        return 0;
    } catch (const std::exception& e) {
        std::cerr << "ERROR: " << e.what() << "\n";
        return 2;
    }
}
