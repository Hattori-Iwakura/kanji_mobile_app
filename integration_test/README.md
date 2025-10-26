# Integration Tests

Integration tests chạy trên thiết bị thật hoặc emulator và test toàn bộ ứng dụng với backend API thật.

## Status

⚠️ **Integration tests hiện tại bị SKIP** do phức tạp với authentication flow.

Kanji feature đã complete với **114/114 tests passing** qua các layers:
- ✅ Unit Tests (Domain): 36 tests
- ✅ Unit Tests (Data): 36 tests  
- ✅ Integration Tests (BLoC): 12 tests
- ✅ Widget Tests: 30 tests
- ⏸️ E2E Tests: Skipped (auth complexity)

## Prerequisites

1. **Backend server phải chạy:**
   ```bash
   cd ../kanji-web-be
   yarn start:dev
   ```
   Server sẽ chạy tại `http://localhost:3000`

2. **Database đã seed data:**
   ```bash
   cd ../kanji-web-be
   npx prisma db seed
   ```

3. **Có emulator/thiết bị đang chạy:**
   ```bash
   flutter devices
   ```

## Chạy Integration Tests

### Cách 1: Chạy trên Flutter test runner (nhanh hơn)
```bash
flutter test integration_test/kanji_search_flow_test.dart
```

### Cách 2: Chạy với driver (cho thiết bị thật)
```bash
flutter drive \
  --driver=integration_test_driver/integration_test_driver.dart \
  --target=integration_test/kanji_search_flow_test.dart
```

### Cách 3: Chạy trên device cụ thể
```bash
# List devices
flutter devices

# Run on specific device
flutter drive \
  --driver=integration_test_driver/integration_test_driver.dart \
  --target=integration_test/kanji_search_flow_test.dart \
  -d <device-id>
```

## Test Coverage

### Kanji Search Flow (kanji_search_flow_test.dart)
- ✅ Complete user journey: Browse → Search → Detail → Back
- ✅ Error handling when backend unavailable
- ✅ Filter by JLPT level
- ✅ Empty state for no results

## Debugging

### Backend không connect được
- Android emulator: Backend phải chạy tại `10.0.2.2:3000`
- iOS simulator: Backend chạy tại `localhost:3000`
- Thiết bị thật: Backend phải chạy trên cùng network, dùng IP máy

### Cập nhật API URL
Sửa file `.env`:
```env
API_BASE_URL=http://10.0.2.2:3000  # Android emulator
# hoặc
API_BASE_URL=http://localhost:3000  # iOS simulator
# hoặc
API_BASE_URL=http://192.168.1.x:3000  # Thiết bị thật
```

### Test timeout
Tăng timeout trong test nếu backend chậm:
```dart
await tester.pumpAndSettle(const Duration(seconds: 5));
```

## Notes

- Integration tests **KHÔNG dùng mocks** - chúng test với backend API thật
- Tests có thể fail nếu backend không có data hoặc schema thay đổi
- Đảm bảo backend có ít nhất 1 kanji (id=1, character='日') để tests pass
- Tests chạy chậm hơn unit tests vì phải wait cho HTTP requests thật

## Best Practices

1. **Always check backend is running** trước khi chạy tests
2. **Seed database** với consistent test data
3. **Use flexible finders** (regex, contains) thay vì exact text matching
4. **Add generous timeouts** cho HTTP requests
5. **Clean up** sau mỗi test nếu tests modify data

## Troubleshooting

### "No tests ran"
- Kiểm tra file path đúng chưa
- Đảm bảo `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` được gọi

### "Connection refused"
- Backend không chạy hoặc sai port
- Kiểm tra `.env` file có đúng API_BASE_URL
- Android emulator: dùng `10.0.2.2` thay vì `localhost`

### "Widget not found"
- UI có thể khác với expectations trong test
- Dùng `flutter run` để xem actual UI
- Adjust finders based on actual widgets

### Tests quá chậm
- Giảm `pumpAndSettle` durations
- Optimize backend response time
- Dùng `pump()` thay vì `pumpAndSettle()` khi không cần wait cho animations
