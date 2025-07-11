abstract class AuthEvent {}

class ToStaff extends AuthEvent{}

class SendOtpRequest extends AuthEvent {
  final String email;
  final String phone;

  SendOtpRequest(this.email, this.phone);
}

class VerifyOtp extends AuthEvent {
  final String email;
  final String phone;
  final String otp;
  final String id;

  VerifyOtp(this.email, this.phone, this.otp, this.id);
}

class Back extends AuthEvent {
  final String email;
  final String phone;

  Back(this.email, this.phone);
}

class StaffLoginRequest extends AuthEvent{
  final String username;
  final String password;

  StaffLoginRequest(this.username, this.password);
}

class ToCustomer extends AuthEvent{}

class LogoutRequested extends AuthEvent {}

class StartApp extends AuthEvent{}

class UpdateInfo extends AuthEvent{
  String? fName;
  String? lName;
  String? email;

  UpdateInfo({this.email, this.fName, this.lName});
}

class StaffForgotPasswordRequest extends AuthEvent {
  // final String username;
  final String email;
  // final String phone;

  StaffForgotPasswordRequest(
    // this.username, 
    this.email
    // , this.phone
    );
}

class StaffVerifyOtpForReset extends AuthEvent {
  final String email;
  final String otp;
  final String id;

  StaffVerifyOtpForReset(this.email, this.otp, this.id);
}

class StaffResetPassword extends AuthEvent {
  final String id;
  final String email;
  final String newPassword;
  final String confirmPassword;

  StaffResetPassword(this.id, this.email, this.newPassword, this.confirmPassword);
}
