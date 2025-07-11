import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_bloc.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_event.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_state.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/auth/UI/screens/staff_reset_password.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final String msg;
  final String id;
  final bool isStaffReset;

  const OtpVerificationPage({
    super.key,
    required this.email,
    required this.msg,
    required this.id,
    this.isStaffReset = false,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    if (widget.msg.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.msg),
            backgroundColor: mainColor,
          ),
        );
      });
    }
  }

  void _resendOtp() async {
    setState(() => _isResending = true);
    if (widget.isStaffReset) {
      context.read<AuthBloc>().add(StaffForgotPasswordRequest(
          // widget.username,
          widget.email
          // , widget.phone
          ));
    } else {
      context.read<AuthBloc>().add(StaffForgotPasswordRequest(widget.email));
    }
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isResending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.isStaffReset
                ? 'Xác minh OTP - Đặt lại mật khẩu'
                : 'Xác minh OTP',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          onPressed: () {
            if (widget.isStaffReset) {
              Navigator.of(context).pop();
            } else {
              // context.read<AuthBloc>().add(Back(widget.email));
            }
          },
          icon: const Icon(Icons.chevron_left, size: 30),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (widget.isStaffReset) {
            if (state is StaffVerifyOtpForResetSuccess) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => StaffResetPasswordPage(
                    email: widget.email,
                    id: state.id
                  ),
                ),
              );
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 80, color: mainColor),
                const SizedBox(height: 20),
                Text(
                  widget.isStaffReset
                      ? "Nhập mã OTP đã gửi đến số điện thoại để đặt lại mật khẩu"
                      : "Nhập mã OTP đã gửi đến số điện thoại của bạn",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged: (value) {
                    if (value.length >= 6) {
                      if (widget.isStaffReset) {
                        context.read<AuthBloc>().add(StaffVerifyOtpForReset(
                            widget.email, value, widget.id));
                      } else {
                        context
                            .read<AuthBloc>()
                            .add(VerifyOtp(widget.email, "", value, widget.id));
                      }
                    }
                  },
                  controller: _otpController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, letterSpacing: 4),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autofocus: true,
                  maxLength: 6,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: 'Nhập mã OTP',
                    prefixIcon: const Icon(Icons.security),
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: mainColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isResending ? null : _resendOtp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: mainColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isResending
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Gửi lại OTP',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
