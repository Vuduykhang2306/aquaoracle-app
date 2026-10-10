# AquaOracle: ứng dụng di động

Ứng dụng Flutter của hệ thống AquaOracle, dùng để giám sát và dự báo chất
lượng nước ao nuôi thuỷ sản. App đọc dữ liệu cảm biến từ Supabase, vẽ biểu đồ
theo thời gian thực, cảnh báo khi chỉ số vượt ngưỡng, và gọi Gemini để giải
thích kết quả dự báo bằng lời dễ hiểu.

Đề tài dự thi Cuộc thi Sáng tạo Thanh thiếu niên, Nhi đồng năm 2026: đạt Giải
Nhất Cụm 4 và vào Vòng chung kết toàn quốc.

Firmware chạy trên thiết bị: [Esp32_AquaOracle_Programm](https://github.com/Vuduykhang2306/Esp32_AquaOracle_Programm)

## Kiến trúc

```
ESP32 + 4 cảm biến  --HTTPS/JSON mỗi 5 phút-->  Supabase (PostgreSQL, bật RLS)
                                                   |
                                      tầng API trên Vercel (PatchTST)
                                                   |
                                        ứng dụng Flutter  -->  Gemini
```

Các chỉ số đo: nhiệt độ (DS18B20), pH (Analog pH Meter Kit V2), TDS, độ đục.

## Màn hình

Giới thiệu, nhập thông tin ao nuôi, chỉ số thời gian thực, đánh giá tổng quan,
biểu đồ lịch sử, kết quả dự báo, lịch sử đo, chatbot tư vấn.

## Chạy thử

Mã nguồn không chứa khoá nào. Các giá trị được truyền vào lúc build:

```bash
cp dart_define.example.json dart_define.json   # rồi điền giá trị thật
flutter pub get
flutter run --dart-define-from-file=dart_define.json
```

`dart_define.json` đã có trong `.gitignore`, đừng commit file này.

## Ghi chú bảo mật

Các bản trước của repo này hardcode Supabase URL, anon key và Gemini API key
ngay trong `lib/config/app_config.dart`. Tôi đã viết lại lịch sử git bằng
`git filter-repo` để gỡ chúng ra, và toàn bộ khoá cũ đã bị vô hiệu. Giờ cấu
hình được đọc từ `--dart-define`.

Đây cũng là loại lỗi tôi hay đi tìm trong hợp đồng thông minh của người khác,
nên code của chính mình cũng phải được rà như vậy.

## Trạng thái

Cuộc thi đã kết thúc. Supabase project dùng cho bản demo đã bị xoá, nên muốn
chạy lại thì cần một backend mới. Mã nguồn để nguyên để tham khảo.
