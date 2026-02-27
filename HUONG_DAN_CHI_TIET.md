# Hướng Dẫn Cài Đặt và Thực Hành Hadoop MapReduce

Tài liệu này hướng dẫn chi tiết cách thiết lập môi trường bằng Docker và thực hiện các bài tập MapReduce trên cụm Hadoop.

---

## I. Chuẩn bị Môi trường

### 1. Yêu cầu hệ thống

- Máy tính đã cài đặt **Docker Desktop** (cho Windows/Mac) hoặc **Docker Engine** (cho Linux).

### 2. Khởi động Cụm Hadoop

1. Tải bộ mã nguồn (gồm file `docker-compose.yml` và các file cấu hình).
2. Mở Terminal tại thư mục chứa dự án và chạy lệnh:
   ```bash
   docker compose up -d
   ```
3. Đợi khoảng 1-2 phút để cụm Hadoop (Namenode và 2 Datanodes) khởi động hoàn toàn.

### 3. Cấu hình môi trường biên dịch (Rất quan trọng)

Do Docker Image tối ưu chỉ chứa môi trường chạy, bạn cần cài đặt thêm bộ biên dịch Java (JDK) mỗi khi khởi tạo lại container:

Chạy lệnh sau từ Terminal máy Host:

```bash
# Cấu hình lại kho phần mềm và cài đặt JDK + Tắt chế độ Safe Mode
docker exec -it namenode bash -c "sed -i 's/mirror.centos.org/vault.centos.org/g' /etc/yum.repos.d/*.repo && sed -i 's/^#.*baseurl=http/baseurl=http/g' /etc/yum.repos.d/*.repo && sed -i 's/^mirrorlist=http/#mirrorlist=http/g' /etc/yum.repos.d/*.repo && yum install -y java-1.8.0-openjdk-devel && hdfs dfsadmin -safemode leave"
```

---

## II. Thực hành Bài tập 1: Đếm từ (Word Count)

### 1. Mô tả

Đếm số lần xuất hiện của từng từ trong các tệp văn bản.

### 2. Cách thực hiện

1. **Dữ liệu đầu vào**: Chỉnh sửa các file văn bản trong thư mục `workspace/input_data/`.
2. **Chạy chương trình**:
   ```bash
   docker exec namenode bash /workspace/build_and_run.sh
   ```
3. **Xem kết quả**: Kết quả sẽ hiển thị ngay trên màn hình terminal và được lưu tại `/output` trên HDFS.

---

## III. Thực hành Bài tập 3: Thống kê Sản phẩm Bán lẻ

### 1. Mô tả

Đọc các file giao dịch CSV và thống kê tổng số lượng từng mặt hàng bán được.

### 2. Cách thực hiện

1. **Dữ liệu đầu vào**: Chỉnh sửa file `workspace/input_retail/Shop-01.csv`.
2. **Chạy chương trình**:
   ```bash
   docker exec namenode bash /workspace/run_retail.sh
   ```
3. **Xem kết quả**: Kết quả hiển thị tổng hợp số lượng sản phẩm và được lưu tại `/output_retail` trên HDFS.

---

## IV. Cấu trúc thư mục Workspace

- `workspace/wordcount/`: Chứa mã nguồn bài 1.
- `workspace/retail/`: Chứa mã nguồn bài 3 (xử lý dấu phẩy CSV).
- `workspace/build_and_run.sh`: Kịch bản tự động cho bài 1.
- `workspace/run_retail.sh`: Kịch bản tự động cho bài 3.

---

## V. Một số lưu ý và Lỗi thường gặp

- **Lỗi FileAlreadyExistsException**: Các script đã được cấu hình để tự động xóa thư mục đầu ra cũ. Nếu bạn chạy thủ công bàn tay, hãy nhớ xóa thư mục output trên HDFS trước.
- **Dùng 'stop' thay vì 'down'**:
  - Nếu dùng `docker compose stop`: Mọi cài đặt JDK sẽ được giữ nguyên cho lần sau.
  - Nếu dùng `docker compose down`: Mọi cài đặt trong container sẽ bị xóa sạch, bạn phải thực hiện lại **Bước 3** ở phần I.
- **Đường dẫn kết quả trên HDFS**:
  - Bài 1: `hdfs dfs -cat /output/part-r-00000`
  - Bài 3: `hdfs dfs -cat /output_retail/part-r-00000`

---

## VI. Hiểu về Luồng Biên dịch và Các Thành phần Code

### 1. Luồng Biên dịch (Compile Workflow)

Trong các file script `.sh`, quá trình quan trọng nhất diễn ra ở **Bước 2**:

- **Lệnh `javac`**: Đây là bộ biên dịch. Nó đọc mã nguồn dễ hiểu của bạn (`.java`) và chuyển đổi thành mã máy (`.class`) để Hadoop có thể chạy được.
- **Tại sao có nhiều thư mục `classes`?**: Chúng ta tách riêng `classes` (Bài 1) và `classes_retail` (Bài 3) để tránh xung đột mã nguồn. Mỗi bài toán có một cách xử lý dữ liệu khác nhau (dấu cách vs dấu phẩy).

### 2. Vai trò của 3 thành phần chính trong code

Mỗi bài tập MapReduce luôn bao gồm 3 phần không thể thiếu:

- **Mapper**: "Người phân loại" - Đọc dữ liệu thô, cắt nhỏ và dán nhãn (ví dụ: `MILK -> 1`).
- **Reducer**: "Người tổng hợp" - Gom các nhãn giống nhau lại và tính toán (ví dụ: `1+1+1 -> 3`).
- **Driver**: "Người điều hành" - Khai báo với Hadoop rằng cần dùng Mapper nào, Reducer nào và đọc dữ liệu từ đâu.

### 3. Tại sao code ở Ngoài mà chạy ở Trong?

Nhờ cấu hình **Volume** trong Docker, bạn có thể dùng **VS Code** ở máy Windows để viết file `.java` (rất tiện lợi). Khi bạn chạy script, lệnh `javac` **bên trong** Docker sẽ tự động thấy mã mới đó để biên dịch ra file `.class` và thực thi ngay lập tức.
