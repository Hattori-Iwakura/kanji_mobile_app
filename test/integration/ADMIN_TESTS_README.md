# Admin Feature Integration Tests

Comprehensive integration tests for the Admin Dashboard feature.

## Test Coverage

### 1. Admin Authentication Tests (3 tests)
- ✅ **1.1**: Non-admin user cannot access admin endpoints (403 Forbidden)
- ✅ **1.2**: Admin user can access admin endpoints
- ✅ **1.3**: Unauthenticated access denied (401 Unauthorized)

### 2. Dashboard Statistics Tests (4 tests)
- ✅ **2.1**: Get dashboard overview (users, content, activity)
- ✅ **2.2**: Get publish statistics (total, pending, approved by type)
- ✅ **2.3**: Get system health (status, database connection)
- ✅ **2.4**: Statistics consistency check (verify data matches across endpoints)

### 3. Publish Request Management Tests (9 tests)
- ✅ **3.1**: Get all publish requests
- ✅ **3.2**: Filter by status - pending
- ✅ **3.3**: Filter by status - approved
- ✅ **3.4**: Filter by type - quiz
- ✅ **3.5**: Filter by type - list
- ✅ **3.6**: Filter by type - deck
- ✅ **3.7**: Combined filters - pending quizzes
- ✅ **3.8**: Pagination - limit
- ✅ **3.9**: Pagination - offset

### 4. Publish Request Detail Tests (4 tests)
- ✅ **4.1**: Get request detail by ID
- ✅ **4.2**: Request detail has full content (quiz/list/deck specific)
- ✅ **4.3**: Get non-existent request (404 error)
- ✅ **4.4**: Get request with invalid type (error handling)

### 5. Publish Request Review Tests (5 tests)
- ✅ **5.1**: Approve publish request (changes status to approved)
- ✅ **5.2**: Reject publish request (changes status to rejected)
- ✅ **5.3**: Review with custom message
- ✅ **5.4**: Review non-existent request (404 error)
- ✅ **5.5**: Review with invalid status (error handling)

### 6. Admin Workflow Tests (3 tests)
- ✅ **6.1**: Complete admin workflow (dashboard → requests → stats → health)
- ✅ **6.2**: Multiple admin requests in sequence (5 consecutive calls)
- ✅ **6.3**: Error recovery (system works after error)

**Total: 28 integration tests**

## Prerequisites

### Backend Setup
1. **Start backend server:**
   ```bash
   cd kanji-web-be
   npm run start:dev
   ```

2. **Ensure admin account exists:**
   ```bash
   npm run seed
   ```
   
   This creates admin account:
   - Email: `admin@gmail.com`
   - Password: `Admin@12345`
   - Role: `ADMIN`

3. **Verify backend is running:**
   - API: http://localhost:3000/api
   - Swagger: http://localhost:3000/api (for manual testing)

### Test User Setup
The test uses:
- **Admin user**: `admin@gmail.com` / `Admin@12345` (created by seed script)
- **Regular test user**: `test@example.com` / `Test123456` (for non-admin tests)

## Running Tests

### Run all admin tests:
```bash
cd kanji_mobile_app
flutter test test/integration/admin_integration_test.dart
```

### Run with verbose output:
```bash
flutter test test/integration/admin_integration_test.dart --reporter expanded
```

### Run specific test group:
```bash
# Authentication tests only
flutter test test/integration/admin_integration_test.dart --name "Admin Authentication"

# Dashboard tests only
flutter test test/integration/admin_integration_test.dart --name "Dashboard Statistics"

# Review tests only
flutter test test/integration/admin_integration_test.dart --name "Review Tests"
```

### Run single test:
```bash
flutter test test/integration/admin_integration_test.dart --name "1.1"
```

## Test Structure

### File Organization
```
test/
├── helpers/
│   ├── admin_helper.dart           # Admin authentication utilities
│   ├── auth_helper.dart            # General auth utilities
│   ├── test_helper.dart            # Test initialization
│   └── test_config.dart            # Test configuration
└── integration/
    └── admin_integration_test.dart # Admin feature tests
```

### Helper Functions

#### AdminHelper
```dart
// Login as admin
final token = await AdminHelper.loginAsAdmin();

// Setup admin auth (login + set token)
await AdminHelper.setupAdminAuth();

// Verify admin access
final hasAccess = await AdminHelper.verifyAdminAccess();

// Clear admin auth
AdminHelper.clearAdminAuth();
```

#### TestHelper
```dart
// Print section header
TestHelper.printSection('TEST NAME');

// Print step
TestHelper.printStep('Doing something...');

// Print success
TestHelper.printSuccess('Operation successful');

// Print error
TestHelper.printError('Operation failed');
```

## Test Scenarios

### Scenario 1: Admin Dashboard Access
```dart
// 1. Login as admin
await AdminHelper.setupAdminAuth();

// 2. Get dashboard overview
final overview = await adminService.getDashboardOverview();

// 3. Verify data
expect(overview.users.total, greaterThan(0));
expect(overview.content.kanji, greaterThan(0));
```

### Scenario 2: Review Publish Request
```dart
// 1. Get pending requests
final response = await adminService.getPublishRequests(
  status: 'pending',
);

// 2. Pick first request
final request = response.requests.first;

// 3. Approve request
final reviewed = await adminService.reviewPublishRequest(
  id: request.id,
  type: request.type,
  status: 'approved',
  reviewMessage: 'Looks good!',
);

// 4. Verify status changed
expect(reviewed.status, equals('approved'));
```

### Scenario 3: Filter and Pagination
```dart
// 1. Filter by type and status
final response = await adminService.getPublishRequests(
  status: 'pending',
  type: 'quiz',
  limit: 10,
  offset: 0,
);

// 2. Verify filters applied
for (final request in response.requests) {
  expect(request.status, equals('pending'));
  expect(request.type, equals('quiz'));
}

// 3. Get next page
final nextPage = await adminService.getPublishRequests(
  status: 'pending',
  type: 'quiz',
  limit: 10,
  offset: 10,
);
```

## Expected Behavior

### Authentication
- ❌ Non-admin users: **403 Forbidden**
- ❌ Unauthenticated: **401 Unauthorized**
- ✅ Admin users: **200 OK**

### Dashboard Statistics
- Returns aggregated stats: users, content, activity
- Data is consistent across endpoints
- System health reflects actual status

### Publish Requests
- Can filter by: status (pending/approved/rejected)
- Can filter by: type (quiz/list/deck)
- Supports pagination: limit + offset
- Returns detailed content for each type

### Request Review
- Approve: Sets status to "approved", makes content public
- Reject: Sets status to "rejected", keeps content private
- Sets reviewedAt, reviewedBy, reviewMessage
- Cannot review non-existent requests (404)

## Troubleshooting

### Backend Not Running
```
Error: Failed to load dashboard: Connection refused
```
**Solution**: Start backend server
```bash
cd kanji-web-be
npm run start:dev
```

### Admin Account Not Found
```
Error: Authentication failed. Please ensure test user exists: admin@gmail.com
```
**Solution**: Run seed script
```bash
cd kanji-web-be
npm run seed
```

### 403 Forbidden Error
```
Error: Admin access required
```
**Solution**: Ensure using admin@gmail.com account, not test@example.com

### Test Data Issues
```
No pending requests available for test
```
**Note**: This is expected if all requests are already reviewed. Tests handle this gracefully.

### Network Timeout
```
Error: DioException [connection timeout]
```
**Solution**: 
1. Check backend is running
2. Increase timeout in `.env` file
3. Check localhost connection

## Test Data Management

### Seed Script Creates:
- 3 admin accounts (including admin@gmail.com)
- 1 test user (nhatnsm1225@gmail.com)
- 100 kanji (15 mandatory + 85 random)
- JLPT system lists (N5-N1)
- 3 sample flashcard decks
- Various review states

### Test Isolation:
- Tests use admin@gmail.com account (created by seed)
- Tests don't modify critical system data
- Reviewed requests remain in database for inspection
- Each test group can run independently

## CI/CD Integration

### GitHub Actions Example:
```yaml
name: Admin Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install backend dependencies
        run: |
          cd kanji-web-be
          npm install
      
      - name: Run migrations
        run: |
          cd kanji-web-be
          npx prisma migrate deploy
      
      - name: Seed database
        run: |
          cd kanji-web-be
          npm run seed
      
      - name: Start backend
        run: |
          cd kanji-web-be
          npm run start:dev &
          sleep 10
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      
      - name: Install Flutter dependencies
        run: |
          cd kanji_mobile_app
          flutter pub get
      
      - name: Run admin integration tests
        run: |
          cd kanji_mobile_app
          flutter test test/integration/admin_integration_test.dart
```

## Related Documentation

- **Admin API Documentation**: `kanji-web-be/src/modules/admin/README.md`
- **Auth Tests**: `test/integration/auth_integration_test.dart`
- **Test Helpers**: `test/helpers/test_helper.dart`
- **Backend Implementation Plan**: `kanji-web-be/IMPLEMENTATION_PLAN.md`

## Status

✅ **Complete** - All 28 tests implemented and passing
- Authentication: 3/3 ✅
- Dashboard: 4/4 ✅
- Request Management: 9/9 ✅
- Request Details: 4/4 ✅
- Request Review: 5/5 ✅
- Workflow: 3/3 ✅

Last updated: October 28, 2025
