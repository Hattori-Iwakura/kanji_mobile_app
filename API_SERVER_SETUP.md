# Kanji API Server Setup

Đây là server API mẫu để hỗ trợ ứng dụng Kanji Library Flutter.

## Cách chạy server

### 1. Cài đặt Node.js
- Tải và cài đặt Node.js từ https://nodejs.org
- Kiểm tra: `node --version` và `npm --version`

### 2. Tạo thư mục server
```bash
mkdir kanji-api-server
cd kanji-api-server
```

### 3. Copy files
- Copy nội dung `sample-package.json` thành `package.json`
- Copy nội dung `sample-api-server.js` thành `server.js`

### 4. Cài đặt dependencies
```bash
npm install
```

### 5. Chạy server
```bash
npm start
```

Server sẽ chạy tại: http://localhost:3000

## API Endpoints

- `GET /api/kanji` - Lấy tất cả kanji
- `GET /api/kanji/:id` - Lấy kanji theo ID
- `POST /api/kanji` - Tạo kanji mới
- `PUT /api/kanji/:id` - Cập nhật kanji
- `DELETE /api/kanji/:id` - Xóa kanji

## Test API

Bạn có thể test API bằng cURL hoặc Postman:

```bash
# Lấy tất cả kanji
curl http://localhost:3000/api/kanji

# Tạo kanji mới
curl -X POST http://localhost:3000/api/kanji \
  -H "Content-Type: application/json" \
  -d '{
    "character": "本",
    "meanings": "book, origin",
    "onyomi": "ホン",
    "kunyomi": "もと",
    "stroke_count": 5,
    "jlpt": 5,
    "grade": 1
  }'
```

## Dữ liệu mẫu

Server đã có sẵn 3 kanji mẫu:
- 漢 (Chinese, Han dynasty)
- 字 (character, letter)  
- 学 (study, learning)

## Chạy với Flutter App

1. Khởi động server: `npm start`
2. Khởi động Flutter app: `flutter run`
3. App sẽ tự động kết nối đến API

**Lưu ý:** 
- Nếu chạy trên Android emulator, app sẽ dùng `http://10.0.2.2:3000`
- Nếu chạy trên thiết bị thật, cần đổi IP trong `main.dart` thành IP máy tính của bạn