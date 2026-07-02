# Reproduce the HLS data used by the paper tables and Figure 6.
#
# Run from hls/fft2d_accel:
#   C:/AMDDesignTools/2025.2/Vitis/bin/vitis-run.bat --mode hls --tcl run_hls_paper_tables_64.tcl
#
# Outputs are copied to:
#   results/paper_reproduce_64

set repo_root [file normalize ../..]
set hls_root [file normalize .]
set data_root "$repo_root/software/python_reference/zynq_2d_fft_python_reference/data"
set results_dir "$hls_root/results/paper_reproduce_64"
file mkdir $results_dir

set part_name xc7z020clg400-1
set clock_period 10
set samples {square gradient checker circle}
set channels {r g b}
set formats {
    {32 20}
    {28 20}
    {24 20}
    {22 20}
    {24 16}
    {24 12}
    {20 12}
}

proc copy_if_exists {src dst} {
    if {[file exists $src]} {
        file copy -force $src $dst
    } else {
        puts "WARNING: missing file $src"
    }
}

proc open_paper_solution {project_name source_file cflags} {
    global part_name clock_period

    open_project -reset $project_name
    set_top fft2d_fixed_top
    add_files $source_file -cflags $cflags
    add_files -tb tb/testbench.cpp -cflags $cflags
    open_solution -reset solution1 -flow_target vivado
    set_part $part_name
    create_clock -period $clock_period -name default
}

proc run_resource_variant {project_name source_file cflags result_prefix} {
    global results_dir

    puts "CODEX_CSYNTH_BEGIN prefix=$result_prefix"
    open_paper_solution $project_name $source_file $cflags
    csynth_design

    copy_if_exists "$project_name/solution1/syn/report/fft2d_fixed_top_csynth.rpt" "$results_dir/${result_prefix}_csynth.rpt"
    copy_if_exists "$project_name/solution1/syn/report/csynth.xml" "$results_dir/${result_prefix}_csynth.xml"
    catch {close_project}
    puts "CODEX_CSYNTH_END prefix=$result_prefix"
}

proc run_csim_sweep_for_format {total_bits integer_bits} {
    global data_root results_dir samples channels

    set project_name "paper_csim_${total_bits}_${integer_bits}_prj"
    set cflags "-Iinclude -DUSE_AP_FIXED -DFFT2D_FIXED_TOTAL_BITS=${total_bits} -DFFT2D_FIXED_INTEGER_BITS=${integer_bits}"

    open_paper_solution $project_name src/fft2d_fixed.cpp $cflags

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

        set log_path "$project_name/solution1/csim/report/fft2d_fixed_top_csim.log"
        copy_if_exists $log_path "$results_dir/${sample}_${total_bits}_${integer_bits}_csim.log"
        puts "CODEX_CSIM_END total=${total_bits} integer=${integer_bits} sample=${sample}"
    }

    catch {close_project}
}

set cflags_28_20 "-Iinclude -DUSE_AP_FIXED -DFFT2D_FIXED_TOTAL_BITS=28 -DFFT2D_FIXED_INTEGER_BITS=20"
set cflags_32_20 "-Iinclude -DUSE_AP_FIXED -DFFT2D_FIXED_TOTAL_BITS=32 -DFFT2D_FIXED_INTEGER_BITS=20"

# Table V and Figure 6: compare the same fixed-point format for the two twiddle implementations.
run_resource_variant paper_runtime_trig_28_20_prj src/fft2d_fixed_runtime_trig.cpp $cflags_28_20 runtime_trig_28_20
run_resource_variant paper_twiddle_lut_28_20_prj src/fft2d_fixed.cpp $cflags_28_20 twiddle_lut_28_20

# Table VI: resource rows for the passing candidate formats.
run_resource_variant paper_bitwidth_32_20_prj src/fft2d_fixed.cpp $cflags_32_20 bitwidth_32_20
copy_if_exists "$results_dir/twiddle_lut_28_20_csynth.rpt" "$results_dir/bitwidth_28_20_csynth.rpt"
copy_if_exists "$results_dir/twiddle_lut_28_20_csynth.xml" "$results_dir/bitwidth_28_20_csynth.xml"

# Table VI: C simulation sweep over all evaluated fixed-point formats.
foreach fmt $formats {
    lassign $fmt total_bits integer_bits
    run_csim_sweep_for_format $total_bits $integer_bits
}

puts "CODEX_RESULTS_DIR $results_dir"
exit
