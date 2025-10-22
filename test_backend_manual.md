# Manual Backend Testing Guide

## Backend đang chạy tại: http://localhost:3000

## Test Cases

### 1. Register New User
```bash
# Windows PowerShell
$body = @{
    account = "testuser_$(Get-Date -Format 'HHmmss')"
    email = "test$(Get-Date -Format 'HHmmss')@example.com"
    password = "Test@123456"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:3000/api/auth/register" -Method POST -ContentType "application/json" -Body $body
```

### 2. Login
```bash
$body = @{
    account = "testuser"
    password = "Test@123456"
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "http://localhost:3000/api/auth/login" -Method POST -ContentType "application/json" -Body $body
$json = $response.Content | ConvertFrom-Json
$token = $json.accessToken
echo "Access Token: $token"
```

### 3. Get Profile (with token)
```bash
Invoke-WebRequest -Uri "http://localhost:3000/api/auth/profile" -Method GET -Headers @{Authorization="Bearer $token"}
```

### 4. Logout
```bash
Invoke-WebRequest -Uri "http://localhost:3000/api/auth/logout" -Method POST -Headers @{Authorization="Bearer $token"}
```

### 5. Refresh Token
```bash
$body = @{
    refreshToken = $json.refreshToken
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:3000/api/auth/refresh" -Method POST -ContentType "application/json" -Body $body
```

### 6. Forgot Password
```bash
$body = @{
    email = "test@example.com"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:3000/api/auth/forgot-password" -Method POST -ContentType "application/json" -Body $body
```

## Flutter App Testing

App đang chạy trên emulator. Test các flow:

1. **Register Flow**
   - Mở app → Tap "Register"
   - Nhập: account, email, password, confirm password
   - Tap "Register" button
   - Kiểm tra: Chuyển đến HomePage

2. **Login Flow**
   - Mở app → LoginPage
   - Nhập: account/email và password
   - Tap "Login" button
   - Kiểm tra: Chuyển đến HomePage

3. **Logout Flow**
   - Ở HomePage → Tap Profile tab
   - Tap "Logout" button
   - Kiểm tra: Quay lại LoginPage

4. **Forgot Password Flow**
   - LoginPage → Tap "Forgot Password?"
   - Nhập email
   - Tap "Reset Password" button
   - Kiểm tra: Hiện success message

5. **Token Persistence**
   - Login vào app
   - Close app hoàn toàn
   - Mở lại app
   - Kiểm tra: Vẫn ở HomePage (không cần login lại)

6. **Error Handling**
   - Thử login với sai password
   - Thử register với account đã tồn tại
   - Thử login khi backend offline
   - Kiểm tra: Hiện error message phù hợp
