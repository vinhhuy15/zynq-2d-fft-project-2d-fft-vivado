# 2026-06-29T10:39:25.979601400
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis")

client.delete_component(name="fft_application")

client.delete_component(name="componentName")

client.delete_component(name="fft_platform")

client.delete_component(name="componentName")

platform = client.create_platform_component(name = "fft_platform",hw_design = "$COMPONENT_LOCATION/../../vivado_2d_FFT/design_1_wrapper.xsa",os = "standalone",cpu = "ps7_cortexa9_0",domain_name = "standalone_ps7_cortexa9_0",compiler = "gcc")

comp = client.create_app_component(name="fft_app",platform = "$COMPONENT_LOCATION/../fft_platform/export/fft_platform/fft_platform.xpfm",domain = "standalone_ps7_cortexa9_0")

comp = client.get_component(name="fft_app")
status = comp.import_files(from_loc="D:\", files=["main.c", "checker_64x64_input.h"], dest_dir_in_cmp = "src", is_skip_copy_sources = False)

platform = client.get_component(name="fft_platform")
status = platform.build()

status = platform.build()

comp = client.get_component(name="fft_app")
comp.build()

status = platform.build()

comp.build()

