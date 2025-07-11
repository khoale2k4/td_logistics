import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_bloc.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_event.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/auth/UI/screens/staff_forgot_password.dart';

class StaffLoginPage extends StatefulWidget {
  final String msg;
  final String username;
  final String password;

  const StaffLoginPage({super.key, required this.msg, this.username = "", this.password = ""});

  @override
  State<StaffLoginPage> createState() => _StaffLoginPageState();
}

class _StaffLoginPageState extends State<StaffLoginPage> with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController(text: "");
  final TextEditingController _passwordController = TextEditingController(text: "");
  // final TextEditingController _usernameController = TextEditingController(text: "levodangkhoatg2497");
  // final TextEditingController _passwordController = TextEditingController(text: "xP7gPB");
  bool hidePass = true;
  bool _isForgotPasswordHovered = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  void toggleHidePass(){
    setState(() {
      hidePass = !hidePass;
    });
  }

  @override
  void initState() {
    super.initState();

    if(widget.username != "") _usernameController.text = widget.username;
    if(widget.password != "") _passwordController.text = widget.password;

    // Initialize pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.msg != "") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.msg, style: const TextStyle(color: Colors.black),),
          backgroundColor: Colors.red.shade100,
        ));
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: mainColor
        ),
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(150),
                  bottomRight: Radius.circular(150),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 70.0),
                  child: Column(
                    children: [
                      Image.asset('lib/assets/logo.png', height: 75),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      "XIN CHÀO!...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _usernameController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            enableSuggestions: false,
                            decoration: InputDecoration(
                              hintText: 'Tài khoản',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: hidePass,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                            autocorrect: false,
                            enableSuggestions: false,
                            decoration: InputDecoration(
                              hintText: 'Mật khẩu',
                              prefixIcon: const Icon(Icons.password),
                              suffixIcon: IconButton(
      onPressed: toggleHidePass,
      icon: hidePass?const Icon(Icons.visibility):const Icon(Icons.visibility_off),
    ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                          
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ), // Màu chữ đen
                        ),
                        onPressed: () {
                          final username = _usernameController.text;
                          final password = _passwordController.text;
                          context.read<AuthBloc>().add(
                                StaffLoginRequest(username, password),
                              );
                        },
                        child: const Text('Đăng nhập'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: 45,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isForgotPasswordHovered
                                  ? [
                                      Colors.white.withOpacity(0.3),
                                      Colors.white.withOpacity(0.2),
                                    ]
                                  : [
                                      Colors.white.withOpacity(0.2),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: _isForgotPasswordHovered 
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.3),
                                width: _isForgotPasswordHovered ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(_isForgotPasswordHovered ? 0.15 : 0.1),
                                  blurRadius: _isForgotPasswordHovered ? 12 : 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(25),
                                onTap: () {
                                  _pulseController.repeat();
                                  Future.delayed(const Duration(milliseconds: 300), () {
                                    _pulseController.stop();
                                    _pulseController.reset();
                                  });
                                  
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const StaffForgotPasswordPage(),
                                    ),
                                  );
                                },
                                onHover: (isHovered) {
                                  setState(() {
                                    _isForgotPasswordHovered = isHovered;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        child: Icon(
                                          Icons.lock_reset,
                                          color: Colors.white,
                                          size: _isForgotPasswordHovered ? 20 : 18,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 200),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: _isForgotPasswordHovered ? 15 : 14,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                        child: const Text('Quên mật khẩu?'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ), // Màu chữ đen
                        ),
                        onPressed: () {
                          context.read<AuthBloc>().add(
                                ToCustomer(),
                              );
                        },
                        child: const Text('Về trang khách hàng'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
