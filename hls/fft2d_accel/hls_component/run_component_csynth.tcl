# Run from this folder:
#   vitis-run --mode hls --tcl run_hls_csynth.tcl

open_project -reset fft2d_accel_prj
set_top fft2d_fixed_top

add_files src/fft2d_fixed.cpp -cflags "-Iinclude -DUSE_AP_FIXED"
add_files -tb tb/testbench.cpp -cflags "-Iinclude -DUSE_AP_FIXED"

open_solution -reset solution1 -flow_target vivado

# Change this if your board is Zynq-7010.
set_part xc7z020clg400-1
create_clock -period 10 -name default

set project_root [file normalize ../..]
set hls_root [file normalize .]
set input_r "$project_root/software/python_reference/zynq_2d_fft_python_reference/data/input/square_64x64_r_matrix_2d.txt"
set input_g "$project_root/software/python_reference/zynq_2d_fft_python_reference/data/input/square_64x64_g_matrix_2d.txt"
set input_b "$project_root/software/python_reference/zynq_2d_fft_python_reference/data/input/square_64x64_b_matrix_2d.txt"
set ref_real_r "$project_root/software/python_reference/zynq_2d_fft_python_reference/data/reference/square_64x64_r_fft_real_2d.txt"
set ref_real_g "$project_root/software/python_reference/zynq_2d_fft_python_reference/data/reference/square_64x64_g_fft_real_2d.txt"
set ref_real_b "$project_root/software/python_reference/zynq_2d_fft_python_reference/data/reference/square_64x64_b_fft_real_2d.txt"
set ref_imag_r "$project_root/software/python_reference/zynq_2d_fft_python_reference/data/reference/square_64x64_r_fft_imag_2d.txt"
set ref_imag_g "$project_root/software/python_reference/zynq_2d_fft_python_reference/data/reference/square_64x64_g_fft_imag_2d.txt"
set ref_imag_b "$project_root/software/python_reference/zynq_2d_fft_python_reference/data/reference/square_64x64_b_fft_imag_2d.txt"
set out_real_r "$hls_root/hls_square_64x64_r_real.txt"
set out_real_g "$hls_root/hls_square_64x64_g_real.txt"
set out_real_b "$hls_root/hls_square_64x64_b_real.txt"
set out_imag_r "$hls_root/hls_square_64x64_r_imag.txt"
set out_imag_g "$hls_root/hls_square_64x64_g_imag.txt"
set out_imag_b "$hls_root/hls_square_64x64_b_imag.txt"
set csim_args "$input_r $input_g $input_b $ref_real_r $ref_real_g $ref_real_b $ref_imag_r $ref_imag_g $ref_imag_b $out_real_r $out_real_g $out_real_b $out_imag_r $out_imag_g $out_imag_b"

csim_design -argv "$csim_args"
csynth_design

exit
