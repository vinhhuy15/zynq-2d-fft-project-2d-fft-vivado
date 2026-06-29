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
set input_matrix "$project_root/software/python_reference/zynq_2d_fft_python_reference/data/input/square_64x64_matrix_2d.txt"
set ref_real "$project_root/software/python_reference/zynq_2d_fft_python_reference/data/reference/square_64x64_fft_real_2d.txt"
set ref_imag "$project_root/software/python_reference/zynq_2d_fft_python_reference/data/reference/square_64x64_fft_imag_2d.txt"
set out_real "$hls_root/hls_square_64x64_real.txt"
set out_imag "$hls_root/hls_square_64x64_imag.txt"

csim_design -argv "$input_matrix $ref_real $ref_imag $out_real $out_imag"
csynth_design

exit
