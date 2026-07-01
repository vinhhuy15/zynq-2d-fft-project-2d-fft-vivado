# Tóm Tắt Dự Án Tăng Tốc 2D FFT Cho Ảnh Màu RGB Trên Zynq-7000 FPGA

Dự án này triển khai bộ tăng tốc phần cứng **2D FFT (Fast Fourier Transform)** cho ảnh màu RGB (3 kênh độc lập, kích thước cố định $64 \times 64$ pixels) trên dòng chip SoC Zynq-7000 (cụ thể là bo mạch PYNQ-Z1 sử dụng chip `xc7z020clg400-1`).

---

## 1. Kiến Trúc Hệ Thống Tổng Quan

Hệ thống hoạt động dựa trên sự kết hợp chặt chẽ giữa **Processing System (PS - Phần mềm)** và **Programmable Logic (PL - Phần cứng)**:

```text
       ┌────────────────────────────────────────────────────────┐
       │                 Processing System (PS)                 │
       │                 ARM Cortex-A9 CPU                     │
       └─────────────────────────┬──────────────────────────────┘
                                 │ AXI-Lite (Control)
                                 ▼
       ┌────────────────────────────────────────────────────────┐
       │                 Programmable Logic (PL)                │
       │  ┌──────────────────────────────────────────────────┐  │
       │  │             FFT2D HLS Accel IP                   │  │
       │  │  - Đọc R, G, B từ DDR qua AXI Master             │  │
       │  │  - Chạy 2D FFT từng kênh độc lập (Twiddle LUT)   │  │
       │  │  - Ghi Real/Imag ngược lại DDR                   │  │
       │  └──────────────────────────────────────────────────┘  │
       └─────────────────────────▲──────────────────────────────┘
                                 │ AXI Master (DDR Access)
                                 ▼
       ┌────────────────────────────────────────────────────────┐
       │                      DDR Memory                        │
       │  - Input buffer (Ảnh màu RGB 64x64)                    │
       │  - Output Real buffer (Kết quả phần thực)              │
       │  - Output Imag buffer (Kết quả phần ảo)                │
       └────────────────────────────────────────────────────────┘
```

---

## 2. Chi Tiết Cấu Trúc Thư Mục & Các File Quan Trọng

Dưới đây là sơ đồ tổ chức thư mục của dự án và các liên kết trực tiếp đến mã nguồn:

### 📁 [hls/fft2d_accel/](file:///D:/zynq-2d-fft-project-2d-fft-vivado/hls/fft2d_accel) — Thiết kế phần cứng High-Level Synthesis (HLS)
*   **[include/fft2d_fixed.hpp](file:///D:/zynq-2d-fft-project-2d-fft-vivado/hls/fft2d_accel/include/fft2d_fixed.hpp)**: Định nghĩa kích thước ảnh ($64 \times 64$), số kênh màu ($3$) và cấu hình kiểu dữ liệu dấu chấm tĩnh `ap_fixed<28,20>` chuyên dụng để tránh tràn số khi tính toán FFT với các giá trị DC lớn.
*   **[src/fft2d_fixed.cpp](file:///D:/zynq-2d-fft-project-2d-fft-vivado/hls/fft2d_accel/src/fft2d_fixed.cpp)**: Triển khai thuật toán Cooley-Tukey Radix-2 FFT cho hàng và cột. 
    *   *Tối ưu hóa quan trọng*: Thay vì gọi hàm lượng giác runtime `std::sin()` / `std::cos()`, mã nguồn sử dụng **Twiddle Lookup Table tĩnh 64 điểm**, giúp giảm lượng tiêu thụ DSP từ **186 DSP xuống còn 8 DSP** (tiết kiệm 95% tài nguyên DSP trên FPGA).
*   **[tb/testbench.cpp](file:///D:/zynq-2d-fft-project-2d-fft-vivado/hls/fft2d_accel/tb/testbench.cpp)**: C++ Testbench giả lập môi trường PC, đọc dữ liệu ảnh đầu vào và so sánh kết quả tính toán phần cứng với dữ liệu đối chứng của Python để tính sai số MAE & MaxAbs.

### 📁 [vivado_2d_FFT/](file:///D:/zynq-2d-fft-project-2d-fft-vivado/vivado_2d_FFT) — Thiết kế phần cứng Vivado
*   **`project_1.xpr`**: File dự án chính trong Vivado, chứa Block Design kết nối ARM PS7 với IP FFT2D qua AXI Interconnect.
*   **`fft_rgb.xsa`**: File mô tả kiến trúc phần cứng RGB được xuất ra để nạp cho Vitis SDK.
*   **`pynq_z1_ps7_config.tcl`**: Script tự động cấu hình ngoại vi, RAM DDR3 và Clock cho vi xử lý Zynq.

### 📁 [vitis/](file:///D:/zynq-2d-fft-project-2d-fft-vivado/vitis) — Chương trình điều khiển trên vi xử lý ARM
*   **`fft_platform/`**: Chứa BSP (Board Support Package) và drivers điều khiển cấp thấp.
*   **[fft_app/src/main.c](file:///D:/zynq-2d-fft-project-2d-fft-vivado/vitis/fft_app/src/main.c)**: Chương trình điều khiển bare-metal chính. Thực hiện cấu hình con trỏ bộ nhớ DDR thông qua AXI-Lite, kích hoạt phần cứng IP FFT, đồng bộ Cache (`Xil_DCacheFlushRange` / `Xil_DCacheInvalidateRange`), đo thời gian chạy thực tế và so sánh kết quả.
*   **`fft_app/src/rgb_image_fft_tests.h`**: Header chứa các mảng hằng số ảnh mẫu (như bàn cờ, vòng tròn...) và kết quả đối chứng tương ứng được sinh tự động nhằm mục đích test offline trực tiếp trên board.

### 📁 [software/python_reference/](file:///D:/zynq-2d-fft-project-2d-fft-vivado/software/python_reference) — Mô hình đối chứng tham chiếu
*   **[fft2_reference.py](file:///D:/zynq-2d-fft-project-2d-fft-vivado/software/python_reference/zynq_2d_fft_python_reference/software/python_reference/fft2_reference.py)**: Script Python sử dụng thư viện NumPy làm nguồn đối chứng đáng tin cậy. Nó thực hiện sinh ảnh mẫu, xuất file ma trận đầu vào và kết quả FFT thô (dạng văn bản `.txt`) cho C++ Testbench và Vitis kiểm thử.

### 📁 [tools/](file:///D:/zynq-2d-fft-project-2d-fft-vivado/tools) — Công cụ bổ trợ
*   **[generate_vitis_rgb_image_tests.py](file:///D:/zynq-2d-fft-project-2d-fft-vivado/tools/generate_vitis_rgb_image_tests.py)**: Tự động chuyển đổi các file ảnh mẫu sang định dạng số dấu chấm tĩnh C và xuất ra file header `rgb_image_fft_tests.h`.

---

## 3. Quy Trình Kiểm Chứng & Đánh Giá Chất Lượng

Dự án đi theo chuỗi kiểm chứng đa tầng chặt chẽ từ mô hình lý thuyết đến phần cứng thực tế:

```text
Python NumPy Reference 
  └─► C++ Reference (Double)
        └─► HLS C-Simulation (Fixed-Point ap_fixed)
              └─► RTL Co-Simulation (Verilog/VHDL)
                    └─► Deploy Zynq Board (Bare-metal main.c)
```

---

## 4. Kết Quả Thực Nghiệm & Tài Nguyên Phần Cứng

Dưới đây là thông số đo đạc thực tế của bộ tăng tốc FFT 2D sau khi tối ưu hóa bảng tra cứu Twiddle trên thiết bị target **xc7z020clg400-1**:

### Tài nguyên phần cứng ước lượng (Vitis HLS 2025.2)

| Loại Tài Nguyên | Số Lượng Sử Dụng | Tổng Tài Nguyên Trên Chip | Tỷ Lệ Sử Dụng (%) |
| :--- | :---: | :---: | :---: |
| **BRAM_18K** | 26 | 280 | 9% |
| **DSP** | 8 | 220 | 3% |
| **FF** | 10,313 | 106,400 | 9% |
| **LUT** | 12,126 | 53,200 | 22% |

### Hiệu năng & Độ chính xác (Co-simulation)

*   **Thời gian xử lý (RTL Latency)**: **420,207 chu kỳ clock** cho mỗi khung ảnh RGB $64 \times 64$ pixels. Ở tần số 100 MHz, thời gian xử lý khoảng **4.2 ms/khung hình**.
*   **Độ chính xác (Sai số so với Python NumPy)**:
    *   Mẫu `square`: Real MAE = 2.3940, Imag MAE = 1.6828 (Đạt chuẩn chính xác cao).
    *   Mẫu `gradient`: Real MAE = 0.3415, Imag MAE = 0.5031 (Đạt chuẩn chính xác cao).
    *   Mẫu `checker`: Real MAE = 1.5384, Imag MAE = 0.6143 (Đạt chuẩn chính xác cao).
    *   Mẫu `circle`: Real MAE = 4.3268, Imag MAE = 3.0387 (Đạt chuẩn chính xác cao).
