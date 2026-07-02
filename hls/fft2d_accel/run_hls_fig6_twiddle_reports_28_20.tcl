# Generate only the two HLS synthesis reports used for Figure 6.
#
# Run from hls/fft2d_accel:
#   C:/AMDDesignTools/2025.2/Vitis/bin/vitis-run.bat --mode hls --tcl run_hls_fig6_twiddle_reports_28_20.tcl
#
# Sources:
#   Runtime sin/cos : src/fft2d_fixed_runtime_trig.cpp
#   Twiddle LUT     : src/fft2d_fixed.cpp
#
# Expected Vitis HLS 2025.2 resource estimates for xc7z020clg400-1, 10 ns:
#   Runtime sin/cos : 78 BRAM_18K, 197 DSP, 18271 FF, 25593 LUT
#   Twiddle LUT     : 66 BRAM_18K,   8 DSP,  9869 FF, 12375 LUT

set hls_root [file normalize .]
set results_dir "$hls_root/results/fig6_twiddle_reports_28_20"
file mkdir $results_dir

set part_name xc7z020clg400-1
set clock_period 10
set cflags "-Iinclude -DUSE_AP_FIXED -DFFT2D_FIXED_TOTAL_BITS=28 -DFFT2D_FIXED_INTEGER_BITS=20"

proc copy_if_exists {src dst} {
    if {[file exists $src]} {
        file copy -force $src $dst
    } else {
        puts "WARNING: missing file $src"
    }
}

proc run_fig6_variant {project_name source_file result_prefix} {
    global cflags part_name clock_period results_dir

    puts "FIG6_CSYNTH_BEGIN prefix=$result_prefix source=$source_file"
    open_project -reset $project_name
    set_top fft2d_fixed_top
    add_files $source_file -cflags $cflags
    add_files -tb tb/testbench.cpp -cflags $cflags
    open_solution -reset solution1 -flow_target vivado
    set_part $part_name
    create_clock -period $clock_period -name default
    csynth_design

    copy_if_exists "$project_name/solution1/syn/report/fft2d_fixed_top_csynth.rpt" "$results_dir/${result_prefix}_csynth.rpt"
    copy_if_exists "$project_name/solution1/syn/report/csynth.xml" "$results_dir/${result_prefix}_csynth.xml"
    catch {close_project}
    puts "FIG6_CSYNTH_END prefix=$result_prefix"
}

run_fig6_variant fig6_runtime_trig_28_20_prj src/fft2d_fixed_runtime_trig.cpp runtime_trig_28_20
run_fig6_variant fig6_twiddle_lut_28_20_prj src/fft2d_fixed.cpp twiddle_lut_28_20

puts "FIG6_RESULTS_DIR $results_dir"
exit
