# Complete Backend API Test

Write-Host "=== Backend API Test Suite ===" -ForegroundColor Cyan
Write-Host ""

# Create test user
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$account = "testuser$timestamp"
$email = "test$timestamp@example.com"
$password = "Test@123456"

# Test 1: Register
Write-Host "[1/5] Testing Register..." -ForegroundColor Yellow
$registerBody = @{
    account = $account
    email = $email
    password = $password
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/register" -Method POST -ContentType "application/json" -Body $registerBody
    Write-Host "PASS - User registered (ID: $($registerResponse.data.user.id))" -ForegroundColor Green
    $userId = $registerResponse.data.user.id
    $accessToken = $registerResponse.data.accessToken
} catch {
    Write-Host "FAIL - $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Test 2: Login
Write-Host "[2/5] Testing Login..." -ForegroundColor Yellow
$loginBody = @{
    account = $email
    password = $password
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/login" -Method POST -ContentType "application/json" -Body $loginBody
    Write-Host "PASS - Login successful" -ForegroundColor Green
    $accessToken = $loginResponse.data.accessToken
} catch {
    Write-Host "FAIL - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Get Profile
Write-Host "[3/5] Testing Get Profile..." -ForegroundColor Yellow
try {
    $headers = @{
        Authorization = "Bearer $accessToken"
    }
    $profileResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/profile" -Method GET -Headers $headers
    Write-Host "PASS - Profile retrieved (Email: $($profileResponse.data.email))" -ForegroundColor Green
} catch {
    Write-Host "FAIL - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 4: Update Profile
Write-Host "[4/5] Testing Update Profile..." -ForegroundColor Yellow
$updateBody = @{
    name = "Test User $timestamp"
} | ConvertTo-Json

try {
    $headers = @{
        Authorization = "Bearer $accessToken"
    }
    $updateResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/profile" -Method PATCH -Headers $headers -ContentType "application/json" -Body $updateBody
    Write-Host "PASS - Profile updated (Name: $($updateResponse.data.name))" -ForegroundColor Green
} catch {
    Write-Host "FAIL - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 5: Logout (if endpoint exists)
Write-Host "[5/5] Testing Logout..." -ForegroundColor Yellow
try {
    $headers = @{
        Authorization = "Bearer $accessToken"
    }
    $logoutResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/logout" -Method POST -Headers $headers
    Write-Host "PASS - Logout successful" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host "SKIP - Logout endpoint not implemented" -ForegroundColor Gray
    } else {
        Write-Host "FAIL - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Test Suite Complete ===" -ForegroundColor Cyan
