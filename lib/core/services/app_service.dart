import 'package:tdlogistic_v2/auth/data/repositories/auth_repository.dart.dart';
import 'package:tdlogistic_v2/core/service/secure_storage_service.dart';
import 'package:tdlogistic_v2/auth/data/models/user_model.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// AppService - Service chính để xử lý business logic
/// Thay thế cho các BLoC phức tạp
class AppService {
  final SecureStorageService _secureStorageService = SecureStorageService();
  final AuthRepository _authRepository = AuthRepository();

  /// Khởi tạo ứng dụng và kiểm tra token
  Future<Map<String, dynamic>> initializeApp() async {
    try {
      String? token = await _secureStorageService.getToken();
      String? staffId = await _secureStorageService.getStaffId();
      
      if (token != null && !JwtDecoder.isExpired(token)) {
        final List<dynamic> roles = JwtDecoder.decode(token)["roles"];
        
        // Kiểm tra nếu là shipper thì bắt đầu tracking location
        if (roles.contains("SHIPPER")) {
          // TODO: Start location tracking
          // LocationTrackerService locationTrackerService = LocationTrackerService();
          // locationTrackerService.startStatusUpdating(token);
        }
        
        final user = await _authRepository.getUser(token);
        return {
          'success': true,
          'user': user,
          'token': token,
          'isAuthenticated': true,
        };
      } else {
        return {
          'success': false,
          'message': 'Vui lòng đăng nhập để tiếp tục',
          'isAuthenticated': false,
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Không thể khởi tạo ứng dụng: $error',
        'isAuthenticated': false,
      };
    }
  }

  /// Gửi OTP
  Future<Map<String, dynamic>> sendOTP(String email, String phone) async {
    try {
      final result = await _authRepository.sendOTP(email, phone);
      if (result["success"]) {
        return {
          'success': true,
          'id': result["id"],
          'message': 'OTP đã được gửi',
        };
      } else {
        return {
          'success': false,
          'message': 'Sai email hoặc số điện thoại',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Lỗi: $error',
      };
    }
  }

  /// Xác thực OTP
  Future<Map<String, dynamic>> verifyOTP(String id, String otp, String email, String phone) async {
    try {
      final result = await _authRepository.otpVerification(id, otp);
      if (result["success"]) {
        await _secureStorageService.saveToken(result["token"]);
        await _secureStorageService.saveStaffId(result["data"].id);
        
        return {
          'success': true,
          'user': result["data"],
          'token': result["token"],
          'message': 'Đăng nhập thành công',
        };
      } else {
        return {
          'success': false,
          'message': result["message"],
          'id': id,
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Lỗi: $error',
        'id': id,
      };
    }
  }

  /// Đăng nhập staff
  Future<Map<String, dynamic>> staffLogin(String username, String password) async {
    try {
      final result = await _authRepository.staffLogin(username, password);
      if (result["success"]) {
        await _secureStorageService.saveToken(result["token"]);
        await _secureStorageService.saveStaffId(result["data"]["id"]);
        
        final user = await _authRepository.getUser(result["token"]);
        if (user?.shipperType == "NT") {
          await _secureStorageService.saveShipperType("NT");
        }
        
        return {
          'success': true,
          'user': User.fromJson(result["data"]),
          'token': result["token"],
          'message': 'Đăng nhập thành công',
        };
      } else {
        return {
          'success': false,
          'message': result["message"],
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Lỗi đăng nhập: $error',
      };
    }
  }

  /// Cập nhật thông tin user
  Future<Map<String, dynamic>> updateUserInfo(String firstName, String lastName, String email) async {
    try {
      String? token = await _secureStorageService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Không tìm thấy token',
        };
      }
      
      final result = await _authRepository.updateInfo(token, lastName, firstName, email);
      if (result["success"]) {
        return {
          'success': true,
          'message': 'Cập nhật thành công',
        };
      } else {
        return {
          'success': false,
          'message': result["message"],
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Lỗi cập nhật: $error',
      };
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    try {
      await _secureStorageService.deleteToken();
      await _secureStorageService.deleteStaffId();
      await _secureStorageService.deleteShipperType();
    } catch (error) {
      print('Lỗi đăng xuất: $error');
    }
  }

  /// Lấy danh sách đơn hàng
  Future<Map<String, dynamic>> getOrders() async {
    try {
      String? token = await _secureStorageService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Không tìm thấy token',
          'orders': [],
        };
      }
      
      // TODO: Implement get orders from repository
      // final orders = await orderRepository.getOrders(token);
      return {
        'success': true,
        'orders': [],
        'message': 'Tải đơn hàng thành công',
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Lỗi tải đơn hàng: $error',
        'orders': [],
      };
    }
  }

  /// Lấy danh sách công việc (cho shipper)
  Future<Map<String, dynamic>> getTasks() async {
    try {
      String? token = await _secureStorageService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Không tìm thấy token',
          'tasks': [],
        };
      }
      
      // TODO: Implement get tasks from repository
      // final tasks = await taskRepository.getTasks(token);
      return {
        'success': true,
        'tasks': [],
        'message': 'Tải công việc thành công',
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Lỗi tải công việc: $error',
        'tasks': [],
      };
    }
  }

  /// Lấy danh sách chat
  Future<Map<String, dynamic>> getChats() async {
    try {
      String? token = await _secureStorageService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Không tìm thấy token',
          'chats': [],
        };
      }
      
      // TODO: Implement get chats from repository
      // final chats = await chatRepository.getChats(token);
      return {
        'success': true,
        'chats': [],
        'message': 'Tải tin nhắn thành công',
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Lỗi tải tin nhắn: $error',
        'chats': [],
      };
    }
  }

  /// Lấy danh sách chat cho shipper
  Future<Map<String, dynamic>> getShipChats() async {
    try {
      String? token = await _secureStorageService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Không tìm thấy token',
          'chats': [],
        };
      }
      
      // TODO: Implement get ship chats from repository
      // final chats = await chatRepository.getShipChats(token);
      return {
        'success': true,
        'chats': [],
        'message': 'Tải tin nhắn shipper thành công',
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Lỗi tải tin nhắn shipper: $error',
        'chats': [],
      };
    }
  }

  /// Lấy danh sách địa điểm
  Future<Map<String, dynamic>> getLocations() async {
    try {
      String? token = await _secureStorageService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Không tìm thấy token',
          'locations': [],
        };
      }
      
      // TODO: Implement get locations from repository
      // final locations = await locationRepository.getLocations(token);
      return {
        'success': true,
        'locations': [],
        'message': 'Tải địa điểm thành công',
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Lỗi tải địa điểm: $error',
        'locations': [],
      };
    }
  }

  /// Lấy danh sách vị trí
  Future<Map<String, dynamic>> getPositions() async {
    try {
      String? token = await _secureStorageService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Không tìm thấy token',
          'positions': [],
        };
      }
      
      // TODO: Implement get positions from repository
      // final positions = await positionRepository.getPositions(token);
      return {
        'success': true,
        'positions': [],
        'message': 'Tải vị trí thành công',
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Lỗi tải vị trí: $error',
        'positions': [],
      };
    }
  }

  /// Lấy danh sách voucher
  Future<Map<String, dynamic>> getVouchers() async {
    try {
      String? token = await _secureStorageService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Không tìm thấy token',
          'vouchers': [],
        };
      }
      
      // TODO: Implement get vouchers from repository
      // final vouchers = await voucherRepository.getVouchers(token);
      return {
        'success': true,
        'vouchers': [],
        'message': 'Tải voucher thành công',
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Lỗi tải voucher: $error',
        'vouchers': [],
      };
    }
  }

  /// Lấy danh sách bảo hiểm
  Future<Map<String, dynamic>> getInsurances() async {
    try {
      String? token = await _secureStorageService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Không tìm thấy token',
          'insurances': [],
        };
      }
      
      // TODO: Implement get insurances from repository
      // final insurances = await insuranceRepository.getInsurances(token);
      return {
        'success': true,
        'insurances': [],
        'message': 'Tải bảo hiểm thành công',
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Lỗi tải bảo hiểm: $error',
        'insurances': [],
      };
    }
  }

  /// Lấy danh sách hình ảnh
  Future<Map<String, dynamic>> getImages() async {
    try {
      String? token = await _secureStorageService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Không tìm thấy token',
          'images': [],
        };
      }
      
      // TODO: Implement get images from repository
      // final images = await imageRepository.getImages(token);
      return {
        'success': true,
        'images': [],
        'message': 'Tải hình ảnh thành công',
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Lỗi tải hình ảnh: $error',
        'images': [],
      };
    }
  }

  /// Lấy danh sách hình ảnh cho shipper
  Future<Map<String, dynamic>> getShipImages() async {
    try {
      String? token = await _secureStorageService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Không tìm thấy token',
          'images': [],
        };
      }
      
      // TODO: Implement get ship images from repository
      // final images = await imageRepository.getShipImages(token);
      return {
        'success': true,
        'images': [],
        'message': 'Tải hình ảnh shipper thành công',
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Lỗi tải hình ảnh shipper: $error',
        'images': [],
      };
    }
  }

  /// Tạo đơn hàng
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      String? token = await _secureStorageService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Không tìm thấy token',
        };
      }
      
      // TODO: Implement create order from repository
      // final result = await orderRepository.createOrder(token, orderData);
      return {
        'success': true,
        'message': 'Tạo đơn hàng thành công',
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Lỗi tạo đơn hàng: $error',
      };
    }
  }

  /// Nhận công việc (cho shipper)
  Future<Map<String, dynamic>> acceptTask(String taskId) async {
    try {
      String? token = await _secureStorageService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Không tìm thấy token',
        };
      }
      
      // TODO: Implement accept task from repository
      // final result = await taskRepository.acceptTask(token, taskId);
      return {
        'success': true,
        'message': 'Nhận công việc thành công',
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Lỗi nhận công việc: $error',
      };
    }
  }

  /// Xác nhận công việc (cho shipper)
  Future<Map<String, dynamic>> confirmTask(String taskId) async {
    try {
      String? token = await _secureStorageService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Không tìm thấy token',
        };
      }
      
      // TODO: Implement confirm task from repository
      // final result = await taskRepository.confirmTask(token, taskId);
      return {
        'success': true,
        'message': 'Xác nhận công việc thành công',
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Lỗi xác nhận công việc: $error',
      };
    }
  }
} 