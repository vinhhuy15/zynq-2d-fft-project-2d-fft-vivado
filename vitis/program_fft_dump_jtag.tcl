set script_dir [file normalize [file dirname [info script]]]
set platform_hw [file join $script_dir fft_platform hw]
set app_elf [file join $script_dir fft_dump_app build fft_dump_app.elf]

connect
source [file join $platform_hw ps7_init.tcl]
targets -set -nocase -filter {name =~ "APU*"}
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "ARM Cortex-A9 MPCore #0"}
rst -processor
fpga -file [file join $platform_hw sdt fft_rgb.bit]
after 1000
dow $app_elf
con
