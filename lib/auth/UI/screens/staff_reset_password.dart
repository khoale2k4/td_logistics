import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_bloc.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_event.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_state.dart';
import 'package:tdlogistic_v2/core/constant.dart';

class StaffResetPasswordPage extends StatefulWidget {
  final String email;
  final String id;

  const StaffResetPasswordPage({
    super.key,
    required this.email,
    required this.id,
  });

  @override
  State<StaffResetPasswordPage> createState() => _StaffResetPasswordPageState();
}

class _StaffResetPasswordPageState extends State<StaffResetPasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;

  void _toggleHideNewPassword() {
    setState(() {
      _hideNewPassword = !_hideNewPassword;
    });
  }

  void _toggleHideConfirmPassword() {
    setState(() {
      _hideConfirmPassword = !_hideConfirmPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt lại mật khẩu', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left, size: 30),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is StaffResetPasswordSuccess) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_reset, size: 80, color: mainColor),
                const SizedBox(height: 20),
                const Text(
                  "Nhập mật khẩu mới",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Text(
                //   "Tài khoản: ${widget.username}",
                //   textAlign: TextAlign.center,
                //   style: const TextStyle(fontSize: 14, color: Colors.grey),
                // ),
                // const SizedBox(height: 30),
                TextField(
                  controller: _newPasswordController,
                  obscureText: _hideNewPassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: _toggleHideNewPassword,
                      icon: _hideNewPassword 
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off),
                    ),
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
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _hideConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu mới',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: _toggleHideConfirmPassword,
                      icon: _hideConfirmPassword 
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off),
                    ),
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
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final newPassword = _newPasswordController.text.trim();
                      final confirmPassword = _confirmPasswordController.text.trim();
                      
                      if (newPassword.isEmpty || confirmPassword.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vui lòng điền đầy đủ thông tin'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      
                      if (newPassword != confirmPassword) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mật khẩu xác nhận không khớp'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      
                      if (newPassword.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mật khẩu phải có ít nhất 6 ký tự'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      
                      context.read<AuthBloc>().add(
                        StaffResetPassword(
                          widget.id,
                          widget.email,
                          newPassword,
                          confirmPassword,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: mainColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Đặt lại mật khẩu',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 