# 🧪 Password Management E2E Testing Guide

## ✅ Setup Complete

All password management routes are now configured:
- ✅ `/register` → RegisterPage
- ✅ `/forgot-password` → ForgotPasswordPage  
- ✅ `/change-password` → ChangePasswordPage
- ✅ LoginPage has "Forgot Password?" link
- ✅ LoginPage has "Register" link
- ✅ AppDrawer has "Change Password" menu item

## 🎯 Test Scenarios

### Scenario 1: New User Registration Flow

**Steps:**
1. Open app → Login screen
2. Tap "Don't have an account? Register"
3. Fill form:
   - Account: `newuser123`
   - Email: `newuser@test.com`
   - Password: `TestPass123!`
   - Confirm: `TestPass123!`
4. Tap "Register"

**Expected:**
- ✅ Loading indicator shows
- ✅ Success snackbar appears
- ✅ Navigate back to login
- ✅ Backend logs show user created

**Backend logs to check:**
```
📝 Register DTO received: {
  "account": "newuser123",
  "email": "newuser@test.com",
  "password": "TestPass123!"
}
```

---

### Scenario 2: Login with New Account

**Steps:**
1. On login screen
2. Enter:
   - Account: `newuser123`
   - Password: `TestPass123!`
3. Tap "Login"

**Expected:**
- ✅ Loading indicator
- ✅ Navigate to Home
- ✅ Backend logs show login success

**Backend logs:**
```
🔐 [LOGIN] Attempting login for account: newuser123
✅ [LOGIN] User found: { id: X, account: 'newuser123', email: 'newuser@test.com' }
✅ [LOGIN] Password verified for: newuser123
```

---

### Scenario 3: Change Password (Authenticated)

**Steps:**
1. After login, open drawer menu
2. Tap "Change Password"
3. Fill form:
   - Current Password: `TestPass123!`
   - New Password: `NewPass456!`
   - Confirm: `NewPass456!`
4. Tap "Change Password"

**Expected:**
- ✅ Loading indicator
- ✅ Success snackbar
- ✅ Navigate back
- ✅ Can logout and login with new password

**Backend logs:**
```
POST /api/auth/change-password - 200 OK
```

---

### Scenario 4: Forgot Password Flow

**Steps:**
1. On login screen
2. Tap "Forgot Password?"
3. Enter email: `newuser@test.com`
4. Tap "Send Reset Link"

**Expected:**
- ✅ Loading indicator
- ✅ Success dialog appears:
   ```
   Check Your Email
   
   If an account exists with newuser@test.com,
   you will receive a password reset link.
   
   [OK]
   ```
- ✅ Backend console logs reset token

**Backend logs:**
```
Password reset token for newuser@test.com: <64-char-token>
Reset link: http://localhost:3000/reset-password?token=<token>
```

**Next steps:**
1. Copy token from backend logs
2. Test web landing page:
   - Open: `http://localhost:3000/reset-password?token=<token>`
   - Should see HTML page attempting deep link

---

### Scenario 5: Reset Password (API Test)

**Until deep links are configured, test via Postman/Swagger:**

**Request:**
```bash
POST http://localhost:3000/api/auth/reset-password
Content-Type: application/json

{
  "token": "<paste-token-from-logs>",
  "newPassword": "ResetPass789!"
}
```

**Expected Response:**
```json
{
  "statusCode": 200,
  "data": {
    "success": true,
    "message": "Password has been reset successfully"
  },
  "timestamp": "2025-10-17T..."
}
```

**Verify:**
1. Try login with old password → Should FAIL
2. Try login with new password (`ResetPass789!`) → Should SUCCESS

---

## ❌ Negative Test Cases

### Test 1: Register with Existing Account
**Input:** Account/email already registered  
**Expected:** 400 Bad Request - "Account already exists"

### Test 2: Register with Weak Password
**Input:** Password = `12345`  
**Expected:** Validation error before API call

### Test 3: Login with Wrong Password
**Input:** Correct account, wrong password  
**Expected:**
```
❌ [LOGIN] Password verification failed for: newuser123
401 Unauthorized
```

### Test 4: Change Password - Wrong Current Password
**Input:** Wrong current password  
**Expected:** 401 Unauthorized

### Test 5: Change Password - New Same as Old
**Input:** New password = current password  
**Expected:** 400 Bad Request - "New password must be different"

### Test 6: Reset with Expired Token
**Input:** Token older than 1 hour  
**Expected:** 400 Bad Request - "Token expired"

### Test 7: Reset with Used Token
**Input:** Token already used once  
**Expected:** 400 Bad Request - "Token already used"

---

## 📊 Validation Rules Reference

### Account
- ✅ Min 3 characters
- ✅ Only alphanumeric + underscore
- ✅ Regex: `/^[a-zA-Z0-9_]+$/`

### Email
- ✅ Valid email format
- ✅ Regex: `/^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/`

### Password
- ✅ Min 8 characters
- ✅ At least 1 uppercase letter
- ✅ At least 1 lowercase letter
- ✅ At least 1 number
- ✅ Regex: `/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/`

---

## 🐛 Common Issues & Solutions

### Issue: "User not found" after registration
**Solution:** Check if user was actually created in database:
```sql
SELECT * FROM users WHERE account = 'newuser123';
```

### Issue: "Password verification failed" on first login
**Solution:** Make sure you're using EXACT same password (case-sensitive)

### Issue: Register button does nothing
**Solution:** Check Flutter console for validation errors

### Issue: Can't access Change Password page
**Solution:** Make sure you're logged in (need JWT token)

### Issue: Reset link shows 404
**Solution:** Make sure backend is running and AuthWebController is registered

---

## 📝 Checklist

- [ ] Register new account
- [ ] Login with new account
- [ ] Open drawer menu
- [ ] Navigate to Change Password
- [ ] Change password successfully
- [ ] Logout
- [ ] Login with new password
- [ ] Tap "Forgot Password?"
- [ ] Submit email
- [ ] Check backend logs for token
- [ ] Test reset link in browser
- [ ] Test reset API via Postman
- [ ] Login with reset password
- [ ] Test all negative cases

---

## 🚀 Next Steps

1. **Configure Deep Links** (see `PASSWORD_RESET_TESTING.md`)
2. **Email Service Integration**
3. **Add 2FA Feature**
4. **Profile Management**
5. **Notification System**

---

**Last Updated:** October 17, 2025
