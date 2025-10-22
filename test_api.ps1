# Test Backend API Script

Write-Host "Testing Backend API at http://localhost:3000"
Write-Host ""

# Test 1: Login
Write-Host "Test 1: Login with existing user..."
$loginBody = @{
    account = "phat"
    password = "Phat@1203"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/login" -Method POST -ContentType "application/json" -Body $loginBody
    Write-Host "Login successful!"
    Write-Host "User: $($response.user.account)"
    $accessToken = $response.accessToken
    $refreshToken = $response.refreshToken
    Write-Host "Access Token obtained"
} catch {
    Write-Host "Login failed: $_"
    exit 1
}

Write-Host ""

# Test 2: Get Profile
Write-Host "Test 2: Get Profile with token..."
try {
    $headers = @{
        Authorization = "Bearer $accessToken"
    }
    $profile = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/profile" -Method GET -Headers $headers
    Write-Host "Profile retrieved successfully!"
    Write-Host "Account: $($profile.account)"
    Write-Host "Email: $($profile.email)"
} catch {
    Write-Host "Get profile failed: $_"
}

Write-Host ""

# Test 3: Refresh Token
Write-Host "Test 3: Refresh Token..."
$refreshBody = @{
    refreshToken = $refreshToken
} | ConvertTo-Json

try {
    $refreshResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/refresh" -Method POST -ContentType "application/json" -Body $refreshBody
    Write-Host "Token refreshed successfully!"
    $accessToken = $refreshResponse.accessToken
} catch {
    Write-Host "Refresh token failed: $_"
}

Write-Host ""

# Test 4: Logout
Write-Host "Test 4: Logout..."
try {
    $headers = @{
        Authorization = "Bearer $accessToken"
    }
    Invoke-RestMethod -Uri "http://localhost:3000/api/auth/logout" -Method POST -Headers $headers | Out-Null
    Write-Host "Logout successful!"
} catch {
    Write-Host "Logout failed: $_"
}

Write-Host ""
Write-Host "Backend API testing completed!"

