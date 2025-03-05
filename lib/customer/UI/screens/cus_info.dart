import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_bloc.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_event.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_state.dart';
import 'package:tdlogistic_v2/auth/data/models/user_model.dart';
import 'package:tdlogistic_v2/core/constant.dart';

class CustomerInfor extends StatefulWidget {
  final User user;
  const CustomerInfor({super.key, required this.user});

  @override
  State<CustomerInfor> createState() => _CustomerInforState();
}

class _CustomerInforState extends State<CustomerInfor> {
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController firstNameController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.user.firstName);
    lastNameController = TextEditingController(text: widget.user.lastName);
    phoneController = TextEditingController(text: widget.user.phoneNumber);
    emailController = TextEditingController(text: widget.user.email);
  }

  void handleLogoutButton() {
    context.read<AuthBloc>().add(LogoutRequested());
  }

  void handleChangeAvatar() {
    print("Changing avatar");
  }

  void _changeLanguage(String langCode) {
    Locale newLocale =
        langCode == 'vi' ? const Locale('vi', '') : const Locale('en', '');
    context.setLocale(newLocale);
  }

  Widget _buildLanguageButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language, color: Colors.white),
      onSelected: (String langCode) {
        _changeLanguage(langCode);
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(value: 'vi', child: Text('Tiếng Việt')),
        const PopupMenuItem(value: 'en', child: Text('English')),
      ],
    );
  }

  Widget _logoutButton() {
    return TextButton(
      onPressed: () {
        _showLogoutDialog(context);
      },
      child: Text(
        context.tr("user_info.logout"),
        style: TextStyle(
            color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr("user_info.greeting"),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [_buildLanguageButton()],
        elevation: 2,
        backgroundColor: mainColor,
      ),
      backgroundColor: Colors.white,
      body: BlocListener<UserBloc, AuthState>(
        listener: (context, state) {
          if (state is UpdatedInfo) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.tr("user_info.successSaveInfo")),
                backgroundColor: secondColor,
              ),
            );
          } else if (state is FailedUpdateInfo) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.tr("user_info.failedSaveInfo")),
                backgroundColor: mainColor,
              ),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: handleChangeAvatar,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 55,
                      backgroundImage: AssetImage("lib/assets/avt.jpg"),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                buildFieldText(context, context.tr("user_info.lastName"),
                    firstNameController),
                const SizedBox(height: 20),
                buildFieldText(context, context.tr("user_info.firstName"),
                    lastNameController),
                const SizedBox(height: 20),
                buildFieldText(
                    context, context.tr("history.phone"), phoneController,
                    enabled: false),
                const SizedBox(height: 20),
                buildFieldText(context, "Email", emailController),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    context.read<UserBloc>().add(
                          UpdateInfo(
                            email: emailController.text,
                            fName: firstNameController.text,
                            lName: lastNameController.text,
                          ),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  child: Text(
                    context.tr("user_info.save"),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
                _logoutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFieldText(
      BuildContext context, String title, TextEditingController controller,
      {bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: title,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Bo tròn góc
          ),
          elevation: 10, // Đổ bóng
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr("user_info.confirmLogout"),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: mainColor, // Dùng màu chính của app
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey, // Màu chữ
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: Text(context.tr("user_info.deny")),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        handleLogoutButton();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor, // Dùng màu chính của app
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        context.tr("user_info.confirm"),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
