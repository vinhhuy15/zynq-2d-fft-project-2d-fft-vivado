connect
source "D:/zynq-2d-fft-project-2d-fft-vivado/vitis/fft_platform/hw/ps7_init.tcl"
targets -set -nocase -filter {name =~ "APU*"}
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "ARM Cortex-A9 MPCore #0"}
rst -processor
fpga -file "D:/zynq-2d-fft-project-2d-fft-vivado/vitis/fft_platform/hw/sdt/fft_rgb.bit"
after 1000
dow "D:/zynq-2d-fft-project-2d-fft-vivado/vitis/fft_app/build/fft_app.elf"
con
