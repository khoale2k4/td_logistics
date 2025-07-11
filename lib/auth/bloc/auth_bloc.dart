import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_event.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_state.dart';
import 'package:tdlogistic_v2/auth/data/models/user_model.dart';
import 'package:tdlogistic_v2/core/service/secure_storage_service.dart';
import 'package:tdlogistic_v2/core/service/send_location.dart';
import '../data/repositories/auth_repository.dart.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository = AuthRepository();
  final SecureStorageService secureStorageService = SecureStorageService();

  AuthBloc() : super(AuthInitial()) {
    on<SendOtpRequest>(_onSendOtpRequest);
    on<VerifyOtp>(_onVerifyingOtp);
    on<LogoutRequested>(_onLogoutRequested);
    on<StartApp>(_startApp);
    on<Back>((Back event, Emitter<AuthState> emit) async {
      emit(Unauthenticated(event.email, event.phone, "", false));
    });
    on<ToStaff>(_toStaff);
    on<ToCustomer>(_toCus);
    on<StaffLoginRequest>(_onStaffLoginRequest);
    on<StaffForgotPasswordRequest>(_onStaffForgotPasswordRequest);
    on<StaffVerifyOtpForReset>(_onStaffVerifyOtpForReset);
    on<StaffResetPassword>(_onStaffResetPassword);
  }

  Future<void> _startApp(StartApp event, Emitter<AuthState> emit) async {
    try {
      emit(VerifyingOtp());

      SecureStorageService service = SecureStorageService();
      String? token = await service.getToken();
      String? staffId = await service.getStaffId();
      print(token);
      print(staffId);
      if (token != null && !JwtDecoder.isExpired(token)) {
        // print('rolesssss');
        // print(JwtDecoder.decode(token)["roles"]);
        final List<dynamic> roles  = JwtDecoder.decode(token)["roles"];
        print(roles);
        print(roles.contains("SHIPPER"));
        if(roles.contains("SHIPPER")) {
          LocationTrackerService locationTrackerService = LocationTrackerService();
          locationTrackerService.startStatusUpdating(token);
        }
        final user = await authRepository.getUser(token);
        emit(Authenticated(user, token));
      } else {
        emit(Unauthenticated("", "", "Vui lòng đăng nhập để tiếp tục", false));
      }
    } catch (error) {
      print("Error on startApp : ${error.toString()}");
      emit(AuthFailure('Login failed: $error', "", "", false));
    }
  }

  Future<void> _onSendOtpRequest(
      SendOtpRequest event, Emitter<AuthState> emit) async {
    try {
      emit(SendingOtp());
      print("Đang gửi OTP tới email ${event.email}, phone ${event.phone}");
      dynamic otpSent = await authRepository.sendOTP(event.email, event.phone);
      print(otpSent);
      if (otpSent["success"]) {
        emit(SentOtp(event.email, event.phone, "", otpSent["id"]));
      } else {
        emit(AuthFailure(
            'Sai email hoặc số điện thoại', event.email, event.phone, false));
      }
    } catch (error) {
      emit(AuthFailure('Lỗi: $error', event.email, event.phone, false));
    }
  }

  Future<void> _onVerifyingOtp(VerifyOtp event, Emitter<AuthState> emit) async {
    try {
      emit(VerifyingOtp());
      print("Đang xác minh OTP: ${event.id}, ${event.otp}");
      dynamic user = await authRepository.otpVerification(event.id, event.otp);
      if (user["success"]) {
        print("User: $user");
        SecureStorageService secureStorageService = SecureStorageService();
        await secureStorageService.saveToken(user["token"]);
        await secureStorageService.saveStaffId(user["data"].id);
        await secureStorageService.saveCusId(user["data"].id);
        emit(Authenticated(user["data"], user["token"]));
      } else {
        emit(SentOtp(event.email, event.phone, user["message"], event.id));
      }
    } catch (error) {
      emit(AuthFailure('Lỗi: $error', event.email, event.phone, false));
      print('Lỗi auth: $error');
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    SecureStorageService service = SecureStorageService();
    await service.deleteToken();
    await service.deleteStaffId();
    await service.deleteShipperType();
    emit(Unauthenticated("", "", "Đã đăng xuất", false));
  }

  Future<void> _onStaffLoginRequest(
      StaffLoginRequest event, Emitter<AuthState> emit) async {
    emit(StaffLoggining());
    try {
      final loginRs =
          await authRepository.staffLogin(event.username, event.password);
      if (loginRs["success"]) {
        SecureStorageService service = SecureStorageService();
        print(loginRs["data"]);
        final user = await authRepository.getUser(loginRs["token"]);
        print('shipperType');
        print(user?.shipperType);
        if(user?.shipperType == "NT") {
          await service.saveShipperType("NT");
        }
        service.saveToken(loginRs["token"]);
        service.saveStaffId(loginRs["data"]["id"]);
        emit(Authenticated(User.fromJson(loginRs["data"]), loginRs["token"]));
      } else {
        emit(AuthFailure(
            loginRs["message"], event.username, event.password, true));
      }
    } catch (error) {
      print(error);
      emit(Unauthenticated(event.username, event.password, "", true));
    }
  }

  Future<void> _toStaff(ToStaff event, Emitter<AuthState> emit) async {
    emit(Unauthenticated("", "", "", true));
  }

  Future<void> _toCus(ToCustomer event, Emitter<AuthState> emit) async {
    emit(Unauthenticated("", "", "", false));
  }

  Future<void> _onStaffForgotPasswordRequest(
      StaffForgotPasswordRequest event, Emitter<AuthState> emit) async {
    try {
      emit(VerifyingOtp());
      // print("Đang gửi OTP reset password cho staff: ${event.username}, ${event.email}, ${event.phone}");
      dynamic otpSent = await authRepository.sendOTPStaf(event.email);
      // print(otpSent);
      if (otpSent["success"]) {
        emit(StaffForgotPasswordSuccess(event.email, otpSent["id"]));
      } else {
        emit(AuthFailure(
            'Sai thông tin tài khoản', event.email, "", true));
      }
    } catch (error) {
      // emit(AuthFailure('Lỗi: $error', event.username, "", true));
    }
  }

  Future<void> _onStaffVerifyOtpForReset(
      StaffVerifyOtpForReset event, Emitter<AuthState> emit) async {
    try {
      emit(VerifyingOtp());
      print("Đang xác minh OTP reset password: ${event.id}, ${event.otp}");
      dynamic result = await authRepository.otpVerification(event.id, event.otp, isStaff: true);
      await secureStorageService.saveToken(result["token"]);
      if (result["success"]) {
        emit(StaffVerifyOtpForResetSuccess(event.email, event.id));
      } else {
        // emit(StaffForgotPasswordSuccess(event.username, event.email, event.phone, event.id));
      }
    } catch (error) {
      emit(AuthFailure('Lỗi: $error', event.email, "", true));
      print('Lỗi auth: $error');
    }
  }

  Future<void> _onStaffResetPassword(
      StaffResetPassword event, Emitter<AuthState> emit) async {
    try {
      emit(VerifyingOtp());
      
      if (event.newPassword != event.confirmPassword) {
        emit(AuthFailure('Mật khẩu xác nhận không khớp', event.email, "", true));
        return;
      }

      dynamic result = await authRepository.updatePassword(
        (await secureStorageService.getToken())!,
        event.id,
        event.newPassword
      );
      
      // Temporary success for now
      emit(StaffResetPasswordSuccess());
    } catch (error) {
      emit(AuthFailure('Lỗi: $error', event.email, "", true));
    }
  }
}

class UserBloc extends Bloc<AuthEvent, AuthState> {
  final SecureStorageService secureStorageService;
  final AuthRepository authRepository = AuthRepository();

  UserBloc({required this.secureStorageService}) : super(AuthInitial()) {
    on<UpdateInfo>(updateInfo);
  }

  Future<void> updateInfo(event, emit) async {
    try {
      emit(UpdatingInfo());
      final updateInfo = await authRepository.updateInfo(
          (await secureStorageService.getToken())!,
          event.lName,
          event.fName,
          event.email);
      if (updateInfo["success"]) {
        emit(UpdatedInfo());
      } else {
        emit(FailedUpdateInfo(error: updateInfo["message"]));
      }
    } catch (error) {
      print("Lỗi cập nhật thông tin: ${error.toString()}");
      emit(FailedUpdateInfo(error: error.toString()));
    }
  }
}
