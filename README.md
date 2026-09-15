# AquaOracle - ứng dụng di động

Ứng dụng Flutter của hệ thống AquaOracle: giám sát và dự báo chất lượng nước ao
nuôi thuỷ sản. Đọc dữ liệu cảm biến từ Supabase, hiển thị biểu đồ thời gian
thực, cảnh báo khi chỉ số vượt ngưỡng, và gọi Gemini để giải thích kết quả dự
báo bằng ngôn ngữ tự nhiên.

Đề tài dự thi Cuộc thi Sáng tạo Thanh thiếu niên, Nhi đồng năm 2026 - Cụm 4:
Giải Nhất, vào Vòng chung kết toàn quốc.

Firmware chạy trên thiết bị: [Esp32_AquaOracle_Programm](https://github.com/Vuduykhang2306/Esp32_AquaOracle_Programm)

## Kiến trúc

```
ESP32 + 4 cảm biến  ──HTTPS/JSON mỗi 5 phút──>  Supabase (PostgreSQL, bật RLS)
                                                        │
                                          tầng API trên Vercel (PatchTST)
                                                        │
                                              ứng dụng Flutter  ──>  Gemini
```

Chỉ số đo: nhiệt độ (DS18B20), pH (Analog pH Meter Kit V2), TDS, độ đục.

## Màn hình

Giới thiệu · nhập thông tin ao nuôi · chỉ số thời gian thực · đánh giá tổng quan
· biểu đồ lịch sử · kết quả dự báo · lịch sử đo · chatbot tư vấn.

## Chạy thử

Ứng dụng không chứa khoá trong mã nguồn. Truyền vào lúc build:

```bash
cp dart_define.example.json dart_define.json   # rồi điền giá trị thật
flutter pub get
flutter run --dart-define-from-file=dart_define.json
```

`dart_define.json` đã nằm trong `.gitignore`. Đừng commit nó.

## Ghi chú bảo mật

Các bản trước của repo này có hardcode Supabase URL, anon key và Gemini API key
thẳng trong `lib/config/app_config.dart`. Lịch sử git đã được viết lại để gỡ bỏ
(`git filter-repo`), và toàn bộ khoá cũ đã bị vô hiệu. Cấu hình hiện đọc từ
`--dart-define`.

Bài học đã ghi lại trong
[smart-contract-security-lab](https://github.com/Vuduykhang2306/smart-contract-security-lab)
- cùng một lỗi mà tôi rà cho hợp đồng thông minh của người khác thì cũng phải rà
cho chính mình.

## Trạng thái

Dự án thi đã kết thúc; Supabase project dùng cho bản demo đã bị xoá, nên ứng
dụng cần một backend mới để chạy lại. Mã nguồn giữ nguyên để tham chiếu.
