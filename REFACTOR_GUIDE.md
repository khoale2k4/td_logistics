# Hướng Dẫn Refactor Code TD Logistics

## Tổng Quan

Dự án đã được refactor từ BLoC pattern sang setState pattern để dễ đọc và maintain hơn. Thay vì sử dụng 25+ BLoC providers phức tạp, chúng ta giờ đây sử dụng:

1. **AppStateManager** - Quản lý state toàn cục
2. **AppService** - Xử lý business logic
3. **Provider** - Dependency injection đơn giản

## Cấu Trúc Mới

### 1. AppStateManager (`lib/core/state/app_state_manager.dart`)

```dart
class AppStateManager extends ChangeNotifier {
  // State variables
  User? _currentUser;
  String? _authToken;
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _authToken != null && _currentUser != null;
  bool get isCustomer => _currentUser?.roles == null;
  bool get isShipper => _currentUser?.roles != null && 
      _currentUser!.roles!.any((role) => role.value == 'SHIPPER');
  
  // Methods
  Future<void> initializeApp() async { ... }
  Future<bool> sendOTP(String email, String phone) async { ... }
  Future<bool> verifyOTP(String id, String otp, String email, String phone) async { ... }
  Future<bool> staffLogin(String username, String password) async { ... }
  Future<void> logout() async { ... }
  Future<bool> updateUserInfo(String firstName, String lastName, String email) async { ... }
  Future<void> loadOrders() async { ... }
  Future<void> loadTasks() async { ... }
  Future<void> loadChats() async { ... }
  Future<void> loadLocations() async { ... }
  Future<void> loadVouchers() async { ... }
}
```

### 2. AppService (`lib/core/services/app_service.dart`)

```dart
class AppService {
  final SecureStorageService _secureStorageService = SecureStorageService();
  final AuthRepository _authRepository = AuthRepository();
  
  // Business logic methods
  Future<Map<String, dynamic>> initializeApp() async { ... }
  Future<Map<String, dynamic>> sendOTP(String email, String phone) async { ... }
  Future<Map<String, dynamic>> verifyOTP(String id, String otp, String email, String phone) async { ... }
  Future<Map<String, dynamic>> staffLogin(String username, String password) async { ... }
  Future<void> logout() async { ... }
  Future<Map<String, dynamic>> updateUserInfo(String firstName, String lastName, String email) async { ... }
  Future<Map<String, dynamic>> getOrders() async { ... }
  Future<Map<String, dynamic>> getTasks() async { ... }
  Future<Map<String, dynamic>> getChats() async { ... }
  Future<Map<String, dynamic>> getLocations() async { ... }
  Future<Map<String, dynamic>> getVouchers() async { ... }
}
```

### 3. App Widget (`lib/app/app_refactored.dart`)

```dart
class MyApp extends StatefulWidget {
  final int start;
  
  const MyApp({super.key, required this.start});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppStateManager _appStateManager;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _appStateManager,
      child: MaterialApp(
        home: Consumer<AppStateManager>(
          builder: (context, appState, child) {
            return _buildHomeScreen(appState);
          },
        ),
      ),
    );
  }
  
  Widget _buildHomeScreen(AppStateManager appState) {
    if (appState.isLoading) return const SplashScreen();
    if (!appState.isAuthenticated) return _buildLoginScreen(appState);
    
    final user = appState.currentUser!;
    if (appState.isCustomer) return _buildCustomerScreen(user, appState);
    if (appState.isShipper) return _buildShipperScreen(user, appState);
    
    return const HomePage();
  }
}
```

## Cách Sử Dụng

### 1. Truy Cập State Trong Widget

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateManager>(
      builder: (context, appState, child) {
        if (appState.isLoading) {
          return CircularProgressIndicator();
        }
        
        if (appState.isAuthenticated) {
          return Text('Xin chào ${appState.currentUser?.firstName}');
        }
        
        return Text('Vui lòng đăng nhập');
      },
    );
  }
}
```

### 2. Gọi Actions

```dart
class LoginWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateManager>(
      builder: (context, appState, child) {
        return ElevatedButton(
          onPressed: () async {
            final success = await appState.sendOTP('email@example.com', '0123456789');
            if (success) {
              // Handle success
            } else {
              // Handle error - error message is in appState.errorMessage
            }
          },
          child: Text('Gửi OTP'),
        );
      },
    );
  }
}
```

### 3. Load Data

```dart
class OrdersWidget extends StatefulWidget {
  @override
  _OrdersWidgetState createState() => _OrdersWidgetState();
}

class _OrdersWidgetState extends State<OrdersWidget> {
  @override
  void initState() {
    super.initState();
    // Load orders when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppStateManager>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateManager>(
      builder: (context, appState, child) {
        return ListView.builder(
          itemCount: appState.orders.length,
          itemBuilder: (context, index) {
            final order = appState.orders[index];
            return ListTile(
              title: Text(order['title']),
              subtitle: Text(order['status']),
            );
          },
        );
      },
    );
  }
}
```

## Lợi Ích Của Cấu Trúc Mới

### 1. **Dễ Đọc**
- Không còn 25+ BLoC providers trong một file
- Logic được tách biệt rõ ràng: State Management, Business Logic, UI
- Code ngắn gọn và dễ hiểu hơn

### 2. **Dễ Maintain**
- Thay đổi logic chỉ cần sửa trong AppService
- Thay đổi state chỉ cần sửa trong AppStateManager
- Không cần tạo nhiều file BLoC riêng biệt

### 3. **Hiệu Suất**
- Ít overhead hơn so với BLoC
- setState đơn giản và nhanh hơn
- Không cần nhiều event/state classes

### 4. **Dễ Debug**
- State được tập trung trong một nơi
- Dễ dàng track changes với notifyListeners()
- Error handling tập trung

## Migration Guide

### Từ BLoC Sang setState

**Trước (BLoC):**
```dart
BlocProvider(
  create: (context) => AuthBloc()..add(StartApp()),
),
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is Authenticated) {
      return HomePage();
    }
    return LoginPage();
  },
),
```

**Sau (setState):**
```dart
ChangeNotifierProvider.value(
  value: _appStateManager,
  child: Consumer<AppStateManager>(
    builder: (context, appState, child) {
      if (appState.isAuthenticated) {
        return HomePage();
      }
      return LoginPage();
    },
  ),
),
```

### Từ Event Sang Method Call

**Trước (BLoC):**
```dart
context.read<AuthBloc>().add(SendOtpRequest(email: email, phone: phone));
```

**Sau (setState):**
```dart
await context.read<AppStateManager>().sendOTP(email, phone);
```

## TODO List

1. **Hoàn thiện AppService**
   - Implement các method còn thiếu (getOrders, getTasks, etc.)
   - Thêm error handling chi tiết
   - Thêm retry logic

2. **Cập nhật UI Components**
   - Refactor các widget để sử dụng AppStateManager
   - Thêm loading states
   - Thêm error handling UI

3. **Testing**
   - Viết unit tests cho AppService
   - Viết widget tests cho UI components
   - Viết integration tests

4. **Performance Optimization**
   - Implement caching cho data
   - Optimize rebuilds với Provider
   - Add pagination cho lists

## Kết Luận

Cấu trúc mới này giúp code dễ đọc, dễ maintain và hiệu suất tốt hơn. Thay vì phức tạp với BLoC pattern, chúng ta sử dụng setState đơn giản với Provider để quản lý state toàn cục. 