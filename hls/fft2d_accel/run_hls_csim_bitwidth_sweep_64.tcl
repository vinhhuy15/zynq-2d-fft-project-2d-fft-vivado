# Run from hls/fft2d_accel:
#   C:/AMDDesignTools/2025.2/Vitis/bin/vitis-run.bat --mode hls --tcl run_hls_csim_bitwidth_sweep_64.tcl

set formats {
    {32 20}
    {28 20}
    {24 20}
    {22 20}
    {24 16}
    {24 12}
    {20 12}
}
set samples {square gradient checker circle}
set channels {r g b}

set repo_root [file normalize ../..]
set hls_root [file normalize .]
set data_root "$repo_root/software/python_reference/zynq_2d_fft_python_reference/data"
set results_dir "$hls_root/results/bitwidth_sweep_64"
file mkdir $results_dir

foreach fmt $formats {
    lassign $fmt total_bits integer_bits
    set project_name "fft2d_accel_csim_${total_bits}_${integer_bits}_prj"
    set solution_name solution1
    set cflags "-Iinclude -DUSE_AP_FIXED -DFFT2D_FIXED_TOTAL_BITS=${total_bits} -DFFT2D_FIXED_INTEGER_BITS=${integer_bits}"

    open_project -reset $project_name
    set_top fft2d_fixed_top
    add_files src/fft2d_fixed.cpp -cflags $cflags
    add_files -tb tb/testbench.cpp -cflags $cflags
    open_solution -reset $solution_name -flow_target vivado
    set_part xc7z020clg400-1
    create_clock -period 10 -name default

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
            lappend argv_parts "$results_dir/${sample}_${total_bits}_${integer_bits}_${ch}_csim_fft_real_2d.txt"
        }
        foreach ch $channels {
            lappend argv_parts "$results_dir/${sample}_${total_bits}_${integer_bits}_${ch}_csim_fft_imag_2d.txt"
        }

        set csim_args [join $argv_parts " "]
        puts "CODEX_CSIM_BEGIN total=${total_bits} integer=${integer_bits} sample=${sample}"
        set status [catch {csim_design -argv "$csim_args"} result]
        puts "CODEX_CSIM_STATUS total=${total_bits} integer=${integer_bits} sample=${sample} status=${status}"
        if {$status != 0} {
            puts $result
        }
        puts "CODEX_CSIM_END total=${total_bits} integer=${integer_bits} sample=${sample}"

        set log_path "$project_name/$solution_name/csim/report/fft2d_fixed_top_csim.log"
        if {[file exists $log_path]} {
            file copy -force $log_path "$results_dir/${sample}_${total_bits}_${integer_bits}_csim.log"
        }
    }
}

exit
