# Run from hls/fft2d_accel:
#   C:/AMDDesignTools/2025.2/Vitis/bin/vitis-run.bat --mode hls --tcl run_hls_cosim_28_20_64.tcl

set project_name fft2d_accel_verify_28_20_prj
set solution_name solution1
set cflags "-Iinclude -DUSE_AP_FIXED -DFFT2D_FIXED_TOTAL_BITS=28 -DFFT2D_FIXED_INTEGER_BITS=20"

open_project -reset $project_name
set_top fft2d_fixed_top

add_files src/fft2d_fixed.cpp -cflags $cflags
add_files -tb tb/testbench.cpp -cflags $cflags

open_solution -reset $solution_name -flow_target vivado
set_part xc7z020clg400-1
create_clock -period 10 -name default

set repo_root [file normalize ../..]
set hls_root [file normalize .]
set data_root "$repo_root/software/python_reference/zynq_2d_fft_python_reference/data"
set results_dir "$hls_root/results/cosim_28_20_64"
file mkdir $results_dir

csynth_design
file copy -force "$project_name/$solution_name/syn/report/fft2d_fixed_top_csynth.rpt" "$results_dir/fft2d_fixed_top_csynth_28_20.rpt"

set samples {square gradient checker circle}
set channels {r g b}

foreach sample $samples {
    set argv_parts {}

    foreach ch $channels {
        lappend argv_parts "$data_root/input/${sample}_64x64_${ch}_matrix_2d.txt"
    }
    foreach ch $channels {
        lappend argv_parts "$data_root/reference/${sample}_64x64_${ch}_fft_real_2d.txt"
    }
    foreach ch $channels {
        lappend argv_parts "$data_root/reference/${sample}_64x64_${ch}_fft_imag_2d.txt"
    }
    foreach ch $channels {
        lappend argv_parts "$results_dir/${sample}_64x64_${ch}_rtl_fft_real_2d.txt"
    }
    foreach ch $channels {
        lappend argv_parts "$results_dir/${sample}_64x64_${ch}_rtl_fft_imag_2d.txt"
    }

    set cosim_args [join $argv_parts " "]
    puts "CODEx_SAMPLE_BEGIN $sample"
    cosim_design -argv "$cosim_args" -rtl verilog
    puts "CODEx_SAMPLE_END $sample"

    set report_dir "$project_name/$solution_name/sim/report"
    if {[file exists "$report_dir/fft2d_fixed_top_cosim.rpt"]} {
        file copy -force "$report_dir/fft2d_fixed_top_cosim.rpt" "$results_dir/${sample}_fft2d_fixed_top_cosim.rpt"
    }
    if {[file exists "$report_dir/verilog/fft2d_fixed_top.log"]} {
        file copy -force "$report_dir/verilog/fft2d_fixed_top.log" "$results_dir/${sample}_fft2d_fixed_top_verilog.log"
    }
}

exit
