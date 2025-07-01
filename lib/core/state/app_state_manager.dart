import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/auth/data/models/user_model.dart';
import 'package:tdlogistic_v2/core/service/secure_storage_service.dart';
import 'package:tdlogistic_v2/core/services/app_service.dart';

/// AppStateManager - Quản lý state toàn cục của ứng dụng
/// Thay thế cho các BLoC phức tạp bằng setState đơn giản
class AppStateManager extends ChangeNotifier {
  // Services
  final SecureStorageService _secureStorageService = SecureStorageService();
  final AppService _appService = AppService();
  
  // Auth state
  User? _currentUser;
  String? _authToken;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isStaff = false;
  
  // OTP state
  String? _otpId;
  String _otpEmail = '';
  String _otpPhone = '';
  
  // Order state
  List<dynamic> _orders = [];
  List<dynamic> _pendingOrders = [];
  List<dynamic> _processingOrders = [];
  List<dynamic> _completedOrders = [];
  List<dynamic> _cancelledOrders = [];
  List<dynamic> _takingOrders = [];
  List<dynamic> _deliveringOrders = [];
  
  // Task state (for shipper)
  List<dynamic> _tasks = [];
  List<dynamic> _pendingTasks = [];
  
  // Chat state
  List<dynamic> _chats = [];
  List<dynamic> _messages = [];
  List<dynamic> _shipChats = [];
  List<dynamic> _shipMessages = [];
  
  // Location state
  List<dynamic> _locations = [];
  List<dynamic> _positions = [];
  
  // Voucher state
  List<dynamic> _vouchers = [];
  
  // Insurance state
  List<dynamic> _insurances = [];
  
  // Images state
  List<dynamic> _images = [];
  List<dynamic> _shipImages = [];
  
  // Getters
  User? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _authToken != null && _currentUser != null;
  bool get isCustomer => _currentUser?.roles == null;
  bool get isShipper => _currentUser?.roles != null && 
      _currentUser!.roles!.any((role) => role.value == 'SHIPPER');
  bool get isStaff => _isStaff;
  
  // OTP getters
  String? get otpId => _otpId;
  String get otpEmail => _otpEmail;
  String get otpPhone => _otpPhone;
  
  // Order getters
  List<dynamic> get orders => _orders;
  List<dynamic> get pendingOrders => _pendingOrders;
  List<dynamic> get processingOrders => _processingOrders;
  List<dynamic> get completedOrders => _completedOrders;
  List<dynamic> get cancelledOrders => _cancelledOrders;
  List<dynamic> get takingOrders => _takingOrders;
  List<dynamic> get deliveringOrders => _deliveringOrders;
  
  // Task getters
  List<dynamic> get tasks => _tasks;
  List<dynamic> get pendingTasks => _pendingTasks;
  
  // Chat getters
  List<dynamic> get chats => _chats;
  List<dynamic> get messages => _messages;
  List<dynamic> get shipChats => _shipChats;
  List<dynamic> get shipMessages => _shipMessages;
  
  // Location getters
  List<dynamic> get locations => _locations;
  List<dynamic> get positions => _positions;
  
  // Voucher getters
  List<dynamic> get vouchers => _vouchers;
  
  // Insurance getters
  List<dynamic> get insurances => _insurances;
  
  // Images getters
  List<dynamic> get images => _images;
  List<dynamic> get shipImages => _shipImages;
  
  /// Khởi tạo ứng dụng
  Future<void> initializeApp() async {
    _setLoading(true);
    try {
      final result = await _appService.initializeApp();
      if (result['success']) {
        _currentUser = result['user'];
        _authToken = result['token'];
        _clearError();
      } else {
        _setError(result['message']);
      }
    } catch (error) {
      _setError('Không thể khởi tạo ứng dụng: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Gửi OTP
  Future<bool> sendOTP(String email, String phone) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _appService.sendOTP(email, phone);
      if (result['success']) {
        _otpId = result['id'];
        _otpEmail = email;
        _otpPhone = phone;
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (error) {
      _setError('Lỗi gửi OTP: $error');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Xác thực OTP
  Future<bool> verifyOTP(String id, String otp, String email, String phone) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _appService.verifyOTP(id, otp, email, phone);
      if (result['success']) {
        _currentUser = result['user'];
        _authToken = result['token'];
        _clearOtpData();
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (error) {
      _setError('Lỗi xác thực OTP: $error');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Đăng nhập staff
  Future<bool> staffLogin(String username, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _appService.staffLogin(username, password);
      if (result['success']) {
        _currentUser = result['user'];
        _authToken = result['token'];
        _isStaff = true;
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (error) {
      _setError('Lỗi đăng nhập: $error');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Chuyển sang đăng nhập staff
  void switchToStaff() {
    _isStaff = true;
    _clearError();
    notifyListeners();
  }
  
  /// Chuyển sang đăng nhập customer
  void switchToCustomer() {
    _isStaff = false;
    _clearError();
    notifyListeners();
  }
  
  /// Đăng xuất
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _appService.logout();
      _currentUser = null;
      _authToken = null;
      _isStaff = false;
      _clearAllData();
    } catch (error) {
      _setError('Lỗi đăng xuất: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Cập nhật thông tin user
  Future<bool> updateUserInfo(String firstName, String lastName, String email) async {
    _setLoading(true);
    try {
      final result = await _appService.updateUserInfo(firstName, lastName, email);
      if (result['success']) {
        if (_currentUser != null) {
          _currentUser!.firstName = firstName;
          _currentUser!.lastName = lastName;
          _currentUser!.email = email;
        }
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (error) {
      _setError('Lỗi cập nhật thông tin: $error');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Load orders
  Future<void> loadOrders() async {
    _setLoading(true);
    try {
      final result = await _appService.getOrders();
      if (result['success']) {
        _orders = result['orders'] ?? [];
        _categorizeOrders();
      } else {
        _setError(result['message']);
      }
    } catch (error) {
      _setError('Lỗi tải đơn hàng: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Load tasks (for shipper)
  Future<void> loadTasks() async {
    _setLoading(true);
    try {
      final result = await _appService.getTasks();
      if (result['success']) {
        _tasks = result['tasks'] ?? [];
        _categorizeTasks();
      } else {
        _setError(result['message']);
      }
    } catch (error) {
      _setError('Lỗi tải công việc: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Load chats
  Future<void> loadChats() async {
    _setLoading(true);
    try {
      final result = await _appService.getChats();
      if (result['success']) {
        _chats = result['chats'] ?? [];
      } else {
        _setError(result['message']);
      }
    } catch (error) {
      _setError('Lỗi tải tin nhắn: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Load ship chats
  Future<void> loadShipChats() async {
    _setLoading(true);
    try {
      final result = await _appService.getShipChats();
      if (result['success']) {
        _shipChats = result['chats'] ?? [];
      } else {
        _setError(result['message']);
      }
    } catch (error) {
      _setError('Lỗi tải tin nhắn shipper: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Load locations
  Future<void> loadLocations() async {
    _setLoading(true);
    try {
      final result = await _appService.getLocations();
      if (result['success']) {
        _locations = result['locations'] ?? [];
      } else {
        _setError(result['message']);
      }
    } catch (error) {
      _setError('Lỗi tải địa điểm: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Load positions
  Future<void> loadPositions() async {
    _setLoading(true);
    try {
      final result = await _appService.getPositions();
      if (result['success']) {
        _positions = result['positions'] ?? [];
      } else {
        _setError(result['message']);
      }
    } catch (error) {
      _setError('Lỗi tải vị trí: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Load vouchers
  Future<void> loadVouchers() async {
    _setLoading(true);
    try {
      final result = await _appService.getVouchers();
      if (result['success']) {
        _vouchers = result['vouchers'] ?? [];
      } else {
        _setError(result['message']);
      }
    } catch (error) {
      _setError('Lỗi tải voucher: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Load insurances
  Future<void> loadInsurances() async {
    _setLoading(true);
    try {
      final result = await _appService.getInsurances();
      if (result['success']) {
        _insurances = result['insurances'] ?? [];
      } else {
        _setError(result['message']);
      }
    } catch (error) {
      _setError('Lỗi tải bảo hiểm: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Load images
  Future<void> loadImages() async {
    _setLoading(true);
    try {
      final result = await _appService.getImages();
      if (result['success']) {
        _images = result['images'] ?? [];
      } else {
        _setError(result['message']);
      }
    } catch (error) {
      _setError('Lỗi tải hình ảnh: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Load ship images
  Future<void> loadShipImages() async {
    _setLoading(true);
    try {
      final result = await _appService.getShipImages();
      if (result['success']) {
        _shipImages = result['images'] ?? [];
      } else {
        _setError(result['message']);
      }
    } catch (error) {
      _setError('Lỗi tải hình ảnh shipper: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Create order
  Future<bool> createOrder(Map<String, dynamic> orderData) async {
    _setLoading(true);
    try {
      final result = await _appService.createOrder(orderData);
      if (result['success']) {
        // Reload orders after creating
        await loadOrders();
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (error) {
      _setError('Lỗi tạo đơn hàng: $error');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Accept task (for shipper)
  Future<bool> acceptTask(String taskId) async {
    _setLoading(true);
    try {
      final result = await _appService.acceptTask(taskId);
      if (result['success']) {
        // Reload tasks after accepting
        await loadTasks();
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (error) {
      _setError('Lỗi nhận công việc: $error');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Confirm task (for shipper)
  Future<bool> confirmTask(String taskId) async {
    _setLoading(true);
    try {
      final result = await _appService.confirmTask(taskId);
      if (result['success']) {
        // Reload tasks after confirming
        await loadTasks();
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (error) {
      _setError('Lỗi xác nhận công việc: $error');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }
  
  void _clearOtpData() {
    _otpId = null;
    _otpEmail = '';
    _otpPhone = '';
  }
  
  void _clearAllData() {
    _orders = [];
    _pendingOrders = [];
    _processingOrders = [];
    _completedOrders = [];
    _cancelledOrders = [];
    _takingOrders = [];
    _deliveringOrders = [];
    _tasks = [];
    _pendingTasks = [];
    _chats = [];
    _messages = [];
    _shipChats = [];
    _shipMessages = [];
    _locations = [];
    _positions = [];
    _vouchers = [];
    _insurances = [];
    _images = [];
    _shipImages = [];
    _clearOtpData();
    notifyListeners();
  }
  
  /// Phân loại đơn hàng theo trạng thái
  void _categorizeOrders() {
    _pendingOrders = _orders.where((order) => order['status'] == 'PENDING').toList();
    _processingOrders = _orders.where((order) => order['status'] == 'PROCESSING').toList();
    _completedOrders = _orders.where((order) => order['status'] == 'COMPLETED').toList();
    _cancelledOrders = _orders.where((order) => order['status'] == 'CANCELLED').toList();
    _takingOrders = _orders.where((order) => order['status'] == 'TAKING').toList();
    _deliveringOrders = _orders.where((order) => order['status'] == 'DELIVERING').toList();
  }
  
  /// Phân loại công việc theo trạng thái
  void _categorizeTasks() {
    _pendingTasks = _tasks.where((task) => task['status'] == 'PENDING').toList();
  }
} 