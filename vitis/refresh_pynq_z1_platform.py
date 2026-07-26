#!/usr/bin/env python3
import os
import vitis


workspace = os.path.abspath(os.path.dirname(__file__))
repo_root = os.path.abspath(os.path.join(workspace, os.pardir))
xsa_path = os.path.join(repo_root, "vivado_2d_FFT", "fft_rgb.xsa")

client = vitis.create_client()

try:
    client.set_workspace(workspace)

    platform = client.get_component(name="fft_platform")
    if platform is None:
        raise RuntimeError("Vitis platform component 'fft_platform' was not found.")

    print(f"Refreshing fft_platform hardware from: {xsa_path}")
    platform.update_hw(hw_design=xsa_path)
    platform.build()

    app = client.get_component(name="fft_dump_app")
    if app is None:
        raise RuntimeError("Vitis application component 'fft_dump_app' was not found.")

    print("Building fft_dump_app...")
    app.build()
finally:
    vitis.dispose()
