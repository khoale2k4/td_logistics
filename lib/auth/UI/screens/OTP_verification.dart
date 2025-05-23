import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_bloc.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_event.dart';
import 'package:tdlogistic_v2/core/constant.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final String phone;
  final String msg;
  final String id;

  const OtpVerificationPage({
    super.key,
    required this.email,
    required this.phone,
    required this.msg,
    required this.id,
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
    context.read<AuthBloc>().add(SendOtpRequest(widget.email, widget.phone));
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isResending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác minh OTP', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          onPressed: () {
            context.read<AuthBloc>().add(Back(widget.email, widget.phone));
          },
          icon: const Icon(Icons.chevron_left, size: 30),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: mainColor),
              const SizedBox(height: 20),
              const Text(
                "Nhập mã OTP đã gửi đến số điện thoại của bạn",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  if (value.length >= 6) {
                    context.read<AuthBloc>().add(VerifyOtp(widget.email, widget.phone, value, widget.id));
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
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                ),
                child: _isResending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Gửi lại OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
