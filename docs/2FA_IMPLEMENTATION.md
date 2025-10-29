# 2FA (Two-Factor Authentication) Implementation

## Tổng quan
Đã implement đầy đủ tính năng 2FA cho auth feature theo Clean Architecture, bao gồm:
- Setup 2FA với QR code
- Enable/Disable 2FA
- Verify 2FA code khi login
- Gửi OTP qua email
- Quản lý backup codes

## Cấu trúc Files

### Domain Layer
```
lib/features/auth/domain/
├── entities/
│   ├── user.dart (đã có field isTwoFactorEnabled)
│   └── two_factor_setup.dart (NEW)
├── repositories/
│   └── auth_repository.dart (updated with 2FA methods)
└── usecases/
    ├── setup_2fa.dart (NEW)
    ├── enable_2fa.dart (NEW)
    ├── disable_2fa.dart (NEW)
    ├── send_email_otp.dart (NEW)
    └── login.dart (updated to support twoFactorCode)
```

### Data Layer
```
lib/features/auth/data/
├── models/
│   └── two_factor_setup_model.dart (NEW)
├── datasources/
│   └── auth_remote_data_source.dart (updated with 2FA API calls)
└── repositories/
    └── auth_repository_impl.dart (updated with 2FA implementations)
```

### Presentation Layer
```
lib/features/auth/presentation/
├── bloc/
│   ├── auth_bloc.dart (updated with 2FA event handlers)
│   ├── auth_event.dart (added 4 new 2FA events)
│   └── auth_state.dart (added 5 new 2FA states)
└── pages/
    ├── two_factor_setup_page.dart (NEW)
    ├── two_factor_verify_page.dart (NEW)
    ├── two_factor_settings_page.dart (NEW)
    └── login_page.dart (updated to handle TwoFactorRequired)
```

## API Endpoints

### 1. POST /auth/2fa/setup
**Protected**: ✅ JWT Required
- **Description**: Generate 2FA secret và QR code
- **Response**:
```json
{
  "secret": "BASE32_SECRET",
  "qrCodeUrl": "otpauth://totp/...",
  "backupCodes": ["code1", "code2", ...]
}
```

### 2. POST /auth/2fa/enable
**Protected**: ✅ JWT Required
- **Description**: Enable 2FA sau khi verify code
- **Body**: `{ "code": "123456" }`
- **Response**: User object với `isTwoFactorEnabled: true`

### 3. POST /auth/2fa/disable
**Protected**: ✅ JWT Required
- **Description**: Disable 2FA (cần password + code)
- **Body**: `{ "password": "...", "code": "123456" }`
- **Response**: User object với `isTwoFactorEnabled: false`

### 4. POST /auth/2fa/send-email-otp
**Protected**: ✅ JWT Required
- **Description**: Gửi OTP code qua email
- **Response**: Success message

### 5. POST /auth/login (Updated)
**Public**: ❌
- **Description**: Login với email/password, hỗ trợ 2FA code
- **Body**: 
```json
{
  "email": "user@example.com",
  "password": "password",
  "twoFactorCode": "123456" // optional
}
```
- **Response**: User + JWT token

## UseCases

### 1. Setup2FA
```dart
final result = await setup2FA();
// Returns: Either<Failure, TwoFactorSetup>
```

### 2. Enable2FA
```dart
final result = await enable2FA(code);
// Returns: Either<Failure, User>
```

### 3. Disable2FA
```dart
final result = await disable2FA(password: password, code: code);
// Returns: Either<Failure, User>
```

### 4. SendEmailOTP
```dart
final result = await sendEmailOTP();
// Returns: Either<Failure, void>
```

### 5. Login (Updated)
```dart
final result = await login(email, password, twoFactorCode: code);
// Returns: Either<Failure, User>
```

## BLoC Events & States

### Events
```dart
Setup2FAEvent()
Enable2FAEvent(String code)
Disable2FAEvent(String password, String code)
SendEmailOTPEvent()
LoginEvent(String email, String password, {String? twoFactorCode}) // Updated
```

### States
```dart
TwoFactorRequired(String email, String password) // Trigger 2FA verify page
TwoFactorSetupSuccess(TwoFactorSetup setup) // Display QR code
TwoFactorEnabled(User user) // 2FA enabled successfully
TwoFactorDisabled(User user) // 2FA disabled successfully
EmailOTPSent() // OTP sent via email
```

## UI Pages

### 1. TwoFactorSetupPage
**Route**: Manual navigation from settings
**Features**:
- Display QR code để scan
- Show secret key để nhập thủ công
- Input field cho verification code
- Display backup codes với copy functionality
- Enable 2FA button

**Flow**:
1. Trigger `Setup2FAEvent` khi page load
2. Hiển thị QR code và secret
3. User nhập code từ authenticator app
4. Trigger `Enable2FAEvent` để activate

### 2. TwoFactorVerifyPage
**Route**: Tự động navigate từ LoginPage khi `TwoFactorRequired`
**Features**:
- Input field cho 6-digit code
- Option gửi OTP qua email
- Help instructions

**Flow**:
1. Nhận email + password từ LoginPage
2. User nhập 2FA code
3. Trigger `LoginEvent` với twoFactorCode
4. Navigate to home nếu success

### 3. TwoFactorSettingsPage
**Route**: Manual navigation từ profile/settings
**Features**:
- Display 2FA status (enabled/disabled)
- Button để enable/disable 2FA
- Information về 2FA benefits
- Disable confirmation dialog

**Flow Enable**:
1. Navigate to `TwoFactorSetupPage`
2. Complete setup process
3. Return với result

**Flow Disable**:
1. Show confirmation dialog
2. Input password + code
3. Trigger `Disable2FAEvent`

### 4. LoginPage (Updated)
**Updates**:
- Listen cho `TwoFactorRequired` state
- Navigate to `TwoFactorVerifyPage` khi 2FA required
- Pass email + password cho verify page

## Dependencies

### Đã thêm vào pubspec.yaml:
```yaml
qr_flutter: ^4.1.0  # Hiển thị QR code
```

## Testing Flow

### 1. Enable 2FA
1. Login vào app
2. Vào Settings/Profile
3. Chọn "Xác thực 2 bước"
4. Click "Bật xác thực 2 bước"
5. Scan QR code bằng Google Authenticator
6. Nhập code 6 số
7. Lưu backup codes
8. Click "Kích hoạt 2FA"
9. ✅ 2FA enabled

### 2. Login với 2FA
1. Logout
2. Login với email + password
3. App tự động navigate to verify page
4. Nhập code từ authenticator app
5. ✅ Login success

### 3. Login với Email OTP
1. Logout
2. Login với email + password
3. Click "Gửi mã qua email"
4. Check email để lấy OTP
5. Nhập OTP code
6. ✅ Login success

### 4. Disable 2FA
1. Vào Settings/Profile
2. Chọn "Xác thực 2 bước"
3. Click "Tắt xác thực 2 bước"
4. Nhập password
5. Nhập code từ authenticator
6. Confirm
7. ✅ 2FA disabled

## Security Features

✅ **QR Code Generation**: Tự động tạo OTPAuth URL
✅ **Backup Codes**: Mã backup để phòng mất thiết bị
✅ **Email OTP**: Alternative method nếu không có authenticator app
✅ **Password Required**: Cần password để disable 2FA
✅ **Code Verification**: Validate code trước khi enable/disable
✅ **JWT Protected**: Tất cả 2FA endpoints cần authentication

## Notes

1. **Authenticator Apps**: Tương thích với Google Authenticator, Authy, Microsoft Authenticator, etc.
2. **Backup Codes**: Mỗi code chỉ dùng được 1 lần, lưu ở nơi an toàn
3. **Email OTP**: Alternative method cho users không có authenticator app
4. **Security**: 2FA tăng cường bảo mật đáng kể, recommend cho tất cả users
5. **UX**: Flow được thiết kế smooth với clear instructions

## Future Enhancements

- [ ] SMS OTP support
- [ ] Biometric fallback
- [ ] Trusted devices (skip 2FA for 30 days)
- [ ] Push notifications for verification
- [ ] Recovery options nếu mất tất cả access methods
- [ ] Admin force 2FA for all users option

---

**Implementation Date**: October 27, 2025
**Status**: ✅ Complete & Ready for Testing
