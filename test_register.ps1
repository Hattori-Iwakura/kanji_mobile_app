# Test Register First

Write-Host "Testing Registration..."

$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$account = "testuser$timestamp"
$email = "test$timestamp@example.com"
$password = "Test@123456"

# RegisterDto requires all 3 fields even though account is not used
$registerBody = @{
    account = $account
    email = $email
    password = $password
} | ConvertTo-Json

try {
    Write-Host "Registering user: $account ($email)"
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/register" -Method POST -ContentType "application/json" -Body $registerBody
    Write-Host "Registration successful!"
    Write-Host "User ID: $($response.data.user.id)"
    Write-Host "Account: $($response.data.user.account)"
    Write-Host "Email: $($response.data.user.email)"
    Write-Host ""
    
    # Now try to login with this user (use email as account)
    Write-Host "Testing login with new user..."
    $loginBody = @{
        account = $email
        password = $password
    } | ConvertTo-Json
    
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/login" -Method POST -ContentType "application/json" -Body $loginBody
    Write-Host "Login successful!"
    Write-Host "Full Login Response:"
    $loginResponse | ConvertTo-Json -Depth 5
    
} catch {
    Write-Host "Failed: $_"
    Write-Host "Error Details: $($_.Exception.Response)"
}
