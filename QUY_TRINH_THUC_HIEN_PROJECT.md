# Quy trình thực hiện project Zynq 2D FFT

Tài liệu này giải thích lại toàn bộ quy trình đã làm trong project `zynq-2d-fft`: từ ý tưởng ban đầu, tạo dữ liệu chuẩn bằng Python, kiểm chứng thuật toán bằng C++, chuyển sang phiên bản phù hợp với Vitis HLS, chạy mô phỏng/tổng hợp HLS, và định hướng các bước tiếp theo để đưa lên Zynq.

Mục tiêu của project là xây dựng một bộ tăng tốc 2D FFT cho ảnh xám kích thước nhỏ, phù hợp với FPGA Zynq-7000. Thay vì làm ngay luồng camera thời gian thực phức tạp, project chọn hướng an toàn hơn: xử lý ảnh tĩnh 32x32 hoặc 64x64, kiểm tra kết quả thật kỹ, rồi mới tính đến tích hợp Vivado/Vitis.

---

## 1. Ý tưởng tổng quát

2D FFT là phép biến đổi ảnh từ miền không gian sang miền tần số. Ảnh ban đầu là ma trận pixel, ví dụ ảnh xám 64x64. Sau khi FFT, kết quả không còn là pixel bình thường nữa mà là các hệ số phức gồm phần thực và phần ảo.

Luồng xử lý mong muốn:

```text
Ảnh xám đầu vào
    -> ma trận pixel
    -> 2D FFT
    -> kết quả real/imag
    -> so sánh với Python
    -> dùng kết quả để đánh giá HLS/FPGA
```

Điểm quan trọng là project không so sánh trực tiếp ảnh magnitude đã tô màu hoặc ảnh log-magnitude, vì ảnh đó chỉ dùng để nhìn trực quan. Kết quả đúng/sai phải dựa trên số liệu real và imag thô.

---

## 2. Cấu trúc thư mục chính

Project hiện có các phần quan trọng sau:

```text
zynq-2d-fft/
+-- software/
|   +-- python_reference/
|   |   +-- zynq_2d_fft_python_reference/
|   |       +-- software/python_reference/fft2_reference.py
|   |       +-- data/input/
|   |       +-- data/reference/
|   |       +-- data/visual/
|   |       +-- results/
|   |
|   +-- cpp_reference/
|       +-- zynq_2d_fft_step2_cpp_reference/
|           +-- software/cpp_reference/src/
|           +-- software/cpp_reference/include/
|           +-- data/input/
|           +-- data/reference/
|           +-- results/
|
+-- hls/
|   +-- fft2d_accel/
|       +-- include/fft2d_fixed.hpp
|       +-- src/fft2d_fixed.cpp
|       +-- tb/testbench.cpp
|       +-- run_hls_csim.tcl
|       +-- run_hls_csynth.tcl
|       +-- run_hls_cosim.tcl
|       +-- hls_component/
|
+-- vivado/
|   +-- reports/
|
+-- FPGA-Based Real-Time Video 2D FFT Accelerator.pdf
+-- zynq_2d_fft_project_handoff_summary.md
+-- bao_cao_tien_do_zynq_2d_fft.docx
```

Ý nghĩa ngắn gọn:

- `software/python_reference`: tạo dữ liệu chuẩn bằng Python/NumPy.
- `software/cpp_reference`: hiện thực FFT bằng C++ double để kiểm chứng thuật toán.
- `hls/fft2d_accel`: phiên bản đã chỉnh để phù hợp Vitis HLS.
- `vivado`: hiện mới là thư mục chuẩn bị/báo cáo, chưa phải block design hoàn chỉnh.

---

## 3. Bước 1 - Tạo dữ liệu chuẩn bằng Python

Đây là bước nền tảng. Trước khi viết C++ hay HLS, cần có một nguồn kết quả đáng tin cậy để so sánh. Project dùng `numpy.fft.fft2()` làm chuẩn vì NumPy đã được kiểm chứng tốt.

File chính:

```text
software/python_reference/zynq_2d_fft_python_reference/software/python_reference/fft2_reference.py
```

Script này làm các việc sau:

1. Tạo ảnh mẫu hoặc đọc ảnh người dùng đưa vào.
2. Chuyển ảnh sang grayscale.
3. Resize ảnh về kích thước cố định, thường là 32x32 hoặc 64x64.
4. Lưu ma trận pixel đầu vào ra file `.txt`.
5. Tính 2D FFT bằng NumPy.
6. Lưu phần thực, phần ảo, magnitude và log-magnitude.
7. Tạo ảnh trực quan để dễ nhìn phổ tần số.

Các ảnh mẫu đã dùng:

- `square`: hình vuông trắng trên nền đen.
- `gradient`: ảnh chuyển sáng dần theo chiều ngang.
- `checker`: ảnh bàn cờ.
- `circle`: hình tròn trắng trên nền đen.

Lệnh chạy mẫu:

```powershell
cd D:\subjects\Thiet_ke_HW_SW\project\zynq-2d-fft\software\python_reference\zynq_2d_fft_python_reference
python software/python_reference/fft2_reference.py --sample all --width 64 --height 64 --out .
```

Sau khi chạy, các file quan trọng được sinh ra:

```text
data/input/*_matrix_2d.txt
data/input/*_matrix_flat_row_major.txt
data/reference/*_fft_real_2d.txt
data/reference/*_fft_imag_2d.txt
data/reference/*_fft_magnitude_2d.txt
data/reference/*_fft_log_magnitude_2d.txt
data/visual/*_fft_log_magnitude_shifted.png
data/visual/*_fft_log_magnitude_unshifted.png
```

Trong đó:

- `*_matrix_2d.txt`: ma trận ảnh đầu vào dạng 2D.
- `*_matrix_flat_row_major.txt`: ma trận ảnh được trải phẳng theo thứ tự từng hàng, thuận tiện cho stream/DMA sau này.
- `*_fft_real_2d.txt`: phần thực của FFT chuẩn.
- `*_fft_imag_2d.txt`: phần ảo của FFT chuẩn.
- `*_fft_log_magnitude_shifted.png`: ảnh phổ tần số để xem bằng mắt.

Lưu ý rất quan trọng:

- File real/imag thô không dùng `fftshift`.
- `fftshift` chỉ dùng cho ảnh visualization để đưa thành phần tần số thấp vào giữa ảnh.
- Khi so sánh C++ hoặc HLS với Python, phải dùng real/imag thô, không dùng ảnh PNG.

---

## 4. Bước 2 - Viết C++ reference

Sau khi có kết quả Python chuẩn, project viết lại thuật toán 2D FFT bằng C++. Mục đích của bước này là chứng minh rằng thuật toán tự viết cho ra kết quả giống NumPy trước khi chuyển sang fixed-point/HLS.

File chính:

```text
software/cpp_reference/zynq_2d_fft_step2_cpp_reference/software/cpp_reference/src/fft2d_reference.cpp
software/cpp_reference/zynq_2d_fft_step2_cpp_reference/software/cpp_reference/src/main.cpp
software/cpp_reference/zynq_2d_fft_step2_cpp_reference/software/cpp_reference/include/fft2d_reference.hpp
```

Thuật toán được dùng là radix-2 Cooley-Tukey FFT. Vì radix-2 yêu cầu kích thước là lũy thừa của 2, project chọn 32x32 và 64x64.

2D FFT được làm bằng cách áp dụng 1D FFT hai lần:

```text
Bước 1: chạy FFT 1D cho từng hàng
Bước 2: chạy FFT 1D cho từng cột
```

Nếu ảnh có kích thước 64x64:

```text
64 hàng  -> mỗi hàng chạy FFT 64 điểm
64 cột   -> mỗi cột chạy FFT 64 điểm
```

FFT 1D trong C++ gồm 2 phần chính:

1. Bit-reversal permutation: sắp xếp lại thứ tự mẫu đầu vào.
2. Butterfly stages: tính toán từng tầng FFT bằng hệ số xoay twiddle.

Công thức forward FFT được dùng giống NumPy:

```text
X[k] = sum_n x[n] * exp(-j * 2*pi*k*n/N)
```

Forward FFT không chia chuẩn hóa. Điều này cũng giống `numpy.fft.fft2()`. Nếu lỡ chia cho N ở C++ thì kết quả sẽ lệch so với Python.

Lệnh chạy trên Windows PowerShell:

```powershell
cd D:\subjects\Thiet_ke_HW_SW\project\zynq-2d-fft\software\cpp_reference\zynq_2d_fft_step2_cpp_reference\software\cpp_reference
.\build_and_run_windows.ps1
```

Khi chạy, chương trình:

1. Đọc ma trận đầu vào từ `data/input`.
2. Chuyển mỗi pixel thành số phức với imag = 0.
3. Chạy 2D FFT.
4. Ghi kết quả real/imag ra thư mục output.
5. Nếu có file reference Python thì tính sai số.

Các chỉ số sai số:

- `MAE`: sai số tuyệt đối trung bình.
- `MSE`: sai số bình phương trung bình.
- `RMSE`: căn bậc hai của MSE.
- `MaxAbs`: sai số tuyệt đối lớn nhất.

Kết quả mong muốn của C++ double là sai số gần như bằng 0, chỉ còn sai số rất nhỏ do tính toán floating-point. Đây là dấu hiệu cho thấy thuật toán C++ đã đúng và có thể dùng làm nền để chuyển sang HLS.

---

## 5. Bước 3 - Chuyển sang phiên bản HLS-friendly

C++ reference ban đầu dùng `std::vector`, cấp phát động và kiểu `double`. Các thứ này thuận tiện trên PC nhưng không lý tưởng cho HLS. Vì vậy project tạo phiên bản mới trong:

```text
hls/fft2d_accel/
```

Các file chính:

```text
hls/fft2d_accel/include/fft2d_fixed.hpp
hls/fft2d_accel/src/fft2d_fixed.cpp
hls/fft2d_accel/tb/testbench.cpp
```

Mục tiêu của phiên bản HLS:

```text
input grayscale matrix
    -> fft2d_fixed_top()
    -> output_real
    -> output_imag
```

Top function:

```cpp
void fft2d_fixed_top(
    data_t input[FFT2D_HEIGHT][FFT2D_WIDTH],
    data_t output_real[FFT2D_HEIGHT][FFT2D_WIDTH],
    data_t output_imag[FFT2D_HEIGHT][FFT2D_WIDTH]
);
```

Trong header, kích thước mặc định:

```cpp
#define FFT2D_HEIGHT 64
#define FFT2D_WIDTH 64
```

Kiểu dữ liệu có 2 chế độ:

```cpp
#if defined(USE_AP_FIXED)
typedef ap_fixed<32, 20, AP_RND, AP_SAT> data_t;
#else
typedef double data_t;
#endif
```

Ý nghĩa:

- Khi chạy thử trên máy tính bình thường, dùng `double` để dễ compile.
- Khi chạy trong Vitis HLS, bật `USE_AP_FIXED` để dùng fixed-point `ap_fixed<32,20>`.

`ap_fixed<32,20>` nghĩa là:

- Tổng cộng 32 bit.
- 20 bit cho phần nguyên, bao gồm bit dấu.
- Phần còn lại dành cho phần thập phân.
- `AP_RND`: làm tròn.
- `AP_SAT`: bão hòa khi tràn, giúp tránh wrap-around nguy hiểm.

Lý do cần nhiều bit nguyên: với ảnh 64x64, nếu toàn bộ pixel sáng 255, hệ số DC có thể đạt:

```text
255 * 64 * 64 = 1,044,480
```

Giá trị này cần khoảng 20 bit để biểu diễn an toàn. Nếu dùng fixed-point quá nhỏ như `ap_fixed<16,8>`, kết quả rất dễ bị overflow.

---

## 6. Cách HLS top function hoạt động

Trong `fft2d_fixed.cpp`, hàm `fft2d_fixed_top()` làm theo các bước:

1. Đọc input vào ma trận nội bộ `matrix`.
2. Gán phần thực bằng pixel đầu vào.
3. Gán phần ảo ban đầu bằng 0.
4. Chạy FFT cho từng hàng.
5. Chạy FFT cho từng cột.
6. Ghi phần thực ra `output_real`.
7. Ghi phần ảo ra `output_imag`.

Các buffer chính:

```cpp
static ComplexFixed matrix[FFT2D_HEIGHT][FFT2D_WIDTH];
ComplexFixed row_buffer[FFT2D_WIDTH];
ComplexFixed col_buffer[FFT2D_HEIGHT];
```

Lý do dùng mảng tĩnh:

- HLS dễ tổng hợp hơn so với `std::vector`.
- Kích thước được biết trước.
- Bộ nhớ có thể ánh xạ sang BRAM.

Interface HLS hiện tại:

```cpp
#pragma HLS INTERFACE m_axi port=input offset=slave bundle=gmem0
#pragma HLS INTERFACE m_axi port=output_real offset=slave bundle=gmem1
#pragma HLS INTERFACE m_axi port=output_imag offset=slave bundle=gmem2
#pragma HLS INTERFACE s_axilite port=input bundle=CTRL
#pragma HLS INTERFACE s_axilite port=output_real bundle=CTRL
#pragma HLS INTERFACE s_axilite port=output_imag bundle=CTRL
#pragma HLS INTERFACE s_axilite port=return bundle=CTRL
```

Ý nghĩa:

- `m_axi`: IP có thể đọc/ghi dữ liệu từ bộ nhớ ngoài qua AXI master.
- `s_axilite`: ARM PS có thể cấu hình địa chỉ buffer, start, kiểm tra done.
- Có 3 vùng nhớ: input, output real, output imag.

Phiên bản này chưa phải AXI-Stream/DMA hoàn chỉnh. Nó là phiên bản HLS IP kiểu memory-mapped, phù hợp để kiểm chứng thuật toán và xuất IP trước.

---

## 7. Testbench HLS

File testbench:

```text
hls/fft2d_accel/tb/testbench.cpp
```

Testbench làm nhiệm vụ:

1. Đọc input `square_64x64_matrix_2d.txt`.
2. Đọc reference Python:
   - `square_64x64_fft_real_2d.txt`
   - `square_64x64_fft_imag_2d.txt`
3. Gọi `fft2d_fixed_top()`.
4. Ghi output HLS ra file.
5. Tính MAE, MSE, RMSE, MaxAbs.
6. Kiểm tra sai số có nằm trong ngưỡng cho phép không.

Với `double`, ngưỡng `MaxAbs` là rất nhỏ:

```text
1e-6
```

Với `ap_fixed`, ngưỡng được nới rộng:

```text
1024.0
```

Lý do: fixed-point có sai số lượng tử hóa, làm tròn, bão hòa và sai số tích lũy qua nhiều tầng butterfly.

---

## 8. Chạy HLS bằng Vitis

Project có 3 script Tcl:

```text
hls/fft2d_accel/run_hls_csim.tcl
hls/fft2d_accel/run_hls_csynth.tcl
hls/fft2d_accel/run_hls_cosim.tcl
```

Ý nghĩa:

- `run_hls_csim.tcl`: chạy C simulation.
- `run_hls_csynth.tcl`: chạy C simulation + C synthesis.
- `run_hls_cosim.tcl`: chạy C simulation + C synthesis + C/RTL co-simulation.

Lệnh mẫu trên Windows:

```cmd
cd /d D:\subjects\Thiet_ke_HW_SW\project\zynq-2d-fft\hls\fft2d_accel
call C:\AMDDesignTools\settings64.bat
C:\AMDDesignTools\2025.2\Vitis\bin\vitis-run.bat --mode hls --tcl run_hls_csim.tcl
```

Chạy tổng hợp:

```cmd
C:\AMDDesignTools\2025.2\Vitis\bin\vitis-run.bat --mode hls --tcl run_hls_csynth.tcl
```

Chạy đồng mô phỏng RTL:

```cmd
C:\AMDDesignTools\2025.2\Vitis\bin\vitis-run.bat --mode hls --tcl run_hls_cosim.tcl
```

Trong script, part đang đặt là:

```tcl
set_part xc7z020clg400-1
```

Đây là cấu hình cho Zynq-7020. Nếu dùng board Zynq-7010, cần đổi part cho đúng board, ví dụ:

```tcl
set_part xc7z010clg400-1
```

---

## 9. Kết quả HLS hiện tại

Theo log và README trong `hls/fft2d_accel`, trạng thái hiện tại:

```text
C simulation: PASS
C synthesis: PASS
C/RTL co-simulation: PASS
```

Kết quả C simulation fixed-point với ảnh `square_64x64`:

```text
Real MAE: 0.2700051121
Real MSE: 2.8843816629
Real RMSE: 1.6983467440
Real MaxAbs: 37.5489746036

Imag MAE: 0.2147809989
Imag MSE: 1.3439980728
Imag RMSE: 1.1593093085
Imag MaxAbs: 25.8147827409
```

Ngưỡng pass đang dùng:

```text
MaxAbs <= 1024.0
```

Vì cả real và imag đều nhỏ hơn 1024 nên test pass.

Báo cáo tổng hợp HLS:

```text
Tool: Vitis HLS 2025.2
Target device: xc7z020-clg484-1
Target clock: 10.00 ns
Estimated clock: 7.300 ns
Estimated Fmax: 136.99 MHz
```

Ước lượng tài nguyên:

| Tài nguyên | Dùng | Có sẵn | Tỷ lệ |
|---|---:|---:|---:|
| BRAM_18K | 26 | 280 | 9% |
| DSP | 8 | 220 | 3% |
| FF | 10313 | 106400 | 9% |
| LUT | 12126 | 53200 | 22% |

Nhận xét:

- Phiên bản hiện tại đã thay `std::cos()` và `std::sin()` runtime bằng bảng twiddle lookup 64 điểm.
- DSP giảm từ 186 xuống 8, tức từ khoảng 84% xuống khoảng 3% trên Zynq-7020.
- LUT, FF và BRAM cũng giảm, nên phiên bản này phù hợp hơn để làm baseline trước khi tích hợp Vivado.

---

## 10. Vì sao không đưa log/sqrt vào FPGA ngay

Trong xử lý ảnh phổ tần số, người ta thường lấy:

```text
magnitude = sqrt(real^2 + imag^2)
log_magnitude = log(1 + magnitude)
normalize về 0..255
```

Các phép này hữu ích để hiển thị ảnh, nhưng không nên đưa vào FPGA ở phiên bản đầu vì:

- `sqrt` và `log` tốn nhiều tài nguyên.
- Normalize dễ lỗi nếu max = min.
- Nếu output chỉ là ảnh 8-bit thì khó biết sai ở FFT hay sai ở bước hiển thị.
- Fixed-point có thể overflow hoặc mất độ chính xác.

Vì vậy project chọn hướng đúng hơn:

```text
FPGA/HLS chỉ xuất raw real và imag.
Python hoặc CPU xử lý magnitude/log-magnitude để visualize.
```

Cách này dễ debug hơn nhiều.

---

## 11. Quy trình kiểm chứng đúng/sai

Toàn bộ project đi theo chuỗi kiểm chứng:

```text
Python NumPy
    -> tạo reference chuẩn
    -> C++ double so sánh với Python
    -> HLS double/ap_fixed so sánh với Python
    -> RTL co-simulation so sánh với C/HLS
```

Mục tiêu của từng tầng:

| Tầng | Mục đích |
|---|---|
| Python | Chuẩn tham chiếu đáng tin cậy |
| C++ double | Kiểm tra thuật toán tự viết |
| HLS-friendly C++ | Loại bỏ cấp phát động, chuẩn bị cho FPGA |
| ap_fixed | Kiểm tra sai số fixed-point |
| C simulation | Kiểm tra code HLS ở mức C |
| C synthesis | Kiểm tra code có tổng hợp được thành phần cứng không |
| C/RTL co-sim | Kiểm tra RTL sinh ra vẫn đúng với testbench |

Nếu có lỗi, nên debug theo thứ tự này, không nhảy thẳng lên Vivado.

---

## 12. Những lỗi dễ gặp

### Lỗi 1: Kết quả bị lệch do nhầm thứ tự dữ liệu

Python lưu matrix theo dạng:

```text
[height][width]
```

Nếu C++ hoặc HLS đọc nhầm thành `[width][height]`, kết quả sẽ sai. Khi flatten dữ liệu, project dùng row-major:

```text
row 0 trước, rồi row 1, rồi row 2, ...
```

### Lỗi 2: Nhầm giữa shifted và unshifted FFT

Raw FFT dùng để so sánh không shift. Ảnh PNG shifted chỉ để nhìn cho đẹp.

Sai:

```text
So sánh HLS real/imag với dữ liệu đã fftshift
```

Đúng:

```text
So sánh HLS real/imag với *_fft_real_2d.txt và *_fft_imag_2d.txt
```

### Lỗi 3: Fixed-point bị overflow

Với ảnh 64x64, giá trị DC có thể rất lớn. Nếu số bit phần nguyên không đủ, kết quả sẽ tràn. Vì vậy project dùng `ap_fixed<32,20>` trước để ưu tiên đúng.

### Lỗi 4: Sai dấu twiddle factor

Forward FFT dùng:

```text
exp(-j * 2*pi*k*n/N)
```

Nếu dùng dấu dương, kết quả sẽ giống inverse FFT hoặc phần ảo bị đổi dấu.

### Lỗi 5: Tối ưu quá sớm

Nếu thêm pipeline, unroll, partition quá mạnh trước khi đúng, việc debug sẽ khó. Quy trình tốt hơn:

```text
Đúng bằng C simulation
-> đúng bằng C/RTL co-sim
-> rồi mới tối ưu tài nguyên/tốc độ
```

---

## 13. Trạng thái Vivado hiện tại

Trong project có thư mục:

```text
vivado/
```

Tuy nhiên phần Vivado block design chưa phải phần chính đã hoàn thiện. Project hiện đang dừng ở mức HLS IP đã kiểm chứng và có báo cáo tổng hợp.

Kiến trúc Vivado dự kiến cho bước tiếp theo:

```text
DDR memory
    <-> Zynq Processing System
    <-> AXI interconnect
    <-> FFT2D HLS IP
```

Với phiên bản HLS hiện tại dùng `m_axi`, IP có thể đọc input và ghi output qua địa chỉ bộ nhớ. ARM PS sẽ:

1. Chuẩn bị buffer input trong DDR.
2. Ghi địa chỉ input/output vào thanh ghi AXI-Lite của IP.
3. Start IP.
4. Chờ IP done.
5. Đọc output real/imag từ DDR.
6. So sánh hoặc lưu kết quả.

Nếu sau này muốn dùng AXI DMA/AXI Stream, cần viết thêm phiên bản top function dạng stream.

---

## 14. Định hướng tối ưu tiếp theo

Phiên bản hiện tại đã đúng về mặt kiểm chứng và đã có tối ưu twiddle lookup. Các bước nên làm tiếp:

1. Test thêm các ảnh mẫu khác, không chỉ `square_64x64`.
2. Thử các kiểu fixed-point nhỏ hơn:
   - `ap_fixed<32,20>`
   - `ap_fixed<24,16>`
   - `ap_fixed<24,12>`
   - `ap_fixed<20,12>`
3. Lập bảng trade-off giữa sai số và tài nguyên.
4. Sau khi HLS ổn, export IP và tích hợp Vivado.
5. Viết host application trên ARM PS để cấp buffer và đọc kết quả.

Bảng kết quả nên có trong báo cáo:

| Phiên bản | Real MAE | Imag MAE | MaxAbs Real | MaxAbs Imag | DSP | LUT | BRAM |
|---|---:|---:|---:|---:|---:|---:|---:|
| ap_fixed<32,20> + twiddle lookup | 0.2700 | 0.2148 | 37.5490 | 25.8148 | 8 | 12126 | 26 |
| ap_fixed nhỏ hơn | cần đo | cần đo | cần đo | cần đo | cần đo | cần đo | cần đo |

---

## 15. Tóm tắt quy trình đã làm

Có thể tóm tắt project thành các bước:

```text
1. Đọc paper tham khảo về FPGA 2D FFT trên Zynq.
2. Giới hạn lại phạm vi project về ảnh xám nhỏ 32x32/64x64.
3. Tạo Python reference bằng numpy.fft.fft2().
4. Sinh ảnh mẫu: square, gradient, checker, circle.
5. Lưu input matrix, output real/imag và ảnh visualize.
6. Viết C++ radix-2 Cooley-Tukey FFT.
7. Chạy 2D FFT bằng cách FFT theo hàng rồi theo cột.
8. So sánh C++ với Python để xác nhận thuật toán đúng.
9. Chuyển C++ sang dạng HLS-friendly: mảng tĩnh, top function rõ ràng.
10. Thêm kiểu dữ liệu ap_fixed<32,20> cho Vitis HLS.
11. Viết testbench đọc input/reference và tính sai số.
12. Chạy Vitis HLS C simulation.
13. Chạy C synthesis để lấy clock/tài nguyên.
14. Chạy C/RTL co-simulation để kiểm chứng RTL.
15. Ghi nhận kết quả, giới hạn hiện tại và hướng tối ưu tiếp theo.
```

---

## 16. Kết luận

Project đã hoàn thành được phần quan trọng nhất trước khi đưa lên board: xây dựng luồng kiểm chứng từ Python đến C++ và HLS. Python tạo kết quả chuẩn, C++ double xác nhận thuật toán FFT đúng, còn phiên bản HLS dùng fixed-point đã chạy được với ảnh 64x64 và pass theo ngưỡng sai số đã đặt.

Điểm mạnh của cách làm này là không vội đưa camera hoặc Vivado block design vào ngay. Thay vào đó, project kiểm soát từng tầng một. Khi kết quả sai, ta biết nên kiểm tra ở Python, C++, fixed-point hay RTL. Đây là cách làm phù hợp với FPGA, vì lỗi trên phần cứng thường khó tìm hơn nhiều so với lỗi ở mô phỏng.

Trạng thái hiện tại đủ để viết báo cáo tiến độ hoặc báo cáo kỹ thuật về:

- 2D FFT cho ảnh xám.
- Kiểm chứng Python/C++/HLS.
- Sai số fixed-point.
- Tài nguyên HLS trên Zynq-7020.
- Các hướng tối ưu như twiddle lookup table và giảm bit-width.
