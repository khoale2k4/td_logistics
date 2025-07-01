import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_bloc.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_event.dart';
import 'package:tdlogistic_v2/auth/data/models/user_model.dart';
import 'package:tdlogistic_v2/core/constant.dart';
// THÊM CÁC IMPORT CẦN THIẾT CHO VIỆC ĐIỀU HƯỚNG
import 'package:tdlogistic_v2/customer/UI/screens/create%20order/all_locations.dart';
import 'package:tdlogistic_v2/customer/UI/screens/customer_info/edit_profile_page.dart';
import 'package:tdlogistic_v2/customer/UI/screens/customer_info/info_display_page.dart';
import 'package:tdlogistic_v2/customer/UI/screens/history.dart';
import 'package:tdlogistic_v2/customer/UI/screens/create%20order/create_order.dart';

class CustomerInfor extends StatefulWidget {
  final User user;
  // Thêm các callback cần thiết từ trang gốc
  final Function(int) toTab;
  final Function() onCreateOrder;
  final Function(String, String) sendMessage;

  const CustomerInfor({
    super.key,
    required this.onCreateOrder,
    required this.user,
    required this.toTab,
    required this.sendMessage,
  });

  @override
  State<CustomerInfor> createState() => _CustomerInforState();
}

class _CustomerInforState extends State<CustomerInfor> {
  @override
  void initState() {
    super.initState();
  }

  void handleLogoutButton() {
    context.read<AuthBloc>().add(LogoutRequested());
  }

  void _changeLanguage(String langCode) {
    Locale newLocale =
        langCode == 'vi' ? const Locale('vi', '') : const Locale('en', '');
    context.setLocale(newLocale);
    Navigator.pop(context); // Đóng dialog sau khi chọn
  }

  // Xử lý điều hướng cho các thẻ tính năng
  void toFeature(int featureIndex) {
    print("Feature selected: $featureIndex");
    switch (featureIndex) {
      case 1: // Tạo đơn
        widget.onCreateOrder();
        break;
      case 2: // Lịch sử đơn
        // Chuyển qua tab Lịch sử
        widget.toTab(1);
        break;
      case 3: // Địa điểm đã lưu
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AllLocationsPage()));
        break;
      case 5:
        Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const InfoDisplayPage(
                            title: 'Hỗ trợ khách hàng',
                            content:
                                'Thông tin liên hệ hỗ trợ: \n\n- Hotline: 1900 xxxx\n- Email: support@tdlogistic.vn\n- Địa chỉ: ...',
                          )));
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chức năng này sắp ra mắt!')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr("more_tab.title"), // Đổi tiêu đề cho phù hợp
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0, // Bỏ shadow cho liền lạc
        backgroundColor: mainColor,
      ),
      backgroundColor: Colors.grey[100], // Nền xám nhạt
      body: SingleChildScrollView(
        child: Column(
          children: [
            // SECTION 1: USER INFO HEADER
            _buildUserInfoHeader(),

            // SECTION 2: FEATURE CARDS (Lấy từ HomePage)
            _buildEnhancedFeaturesSection(),

            // SECTION 3: ADDITIONAL INFO & SUPPORT LIST
            _buildInfoAndSupportList(),

            // SECTION 4: LOGOUT BUTTON
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: mainColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_circle, color: Colors.white, size: 60),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.user.firstName} ${widget.user.lastName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.user.phoneNumber ?? 'Chưa có SĐT',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(user: widget.user),
                ),
              );
            },
            tooltip: 'Chỉnh sửa thông tin',
          )
        ],
      ),
    );
  }

  Widget _buildEnhancedFeaturesSection() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('home.features'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 0.95,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            children: List.generate(6, (index) {
              // Dữ liệu cho các thẻ tính năng
              final features = [
                {
                  'icon': Icons.add_box_outlined,
                  'name': context.tr('home.feature1')
                },
                {
                  'icon': Icons.history_outlined,
                  'name': context.tr('home.feature2')
                },
                {
                  'icon': Icons.location_on_outlined,
                  'name': context.tr('home.feature3')
                },
                {
                  'icon': Icons.receipt_long_outlined,
                  'name': context.tr('home.feature4')
                },
                {
                  'icon': Icons.help_outline,
                  'name': context.tr('home.feature5')
                },
                {
                  'icon': Icons.calculate_outlined,
                  'name': context.tr('home.feature6')
                },
              ];
              return _buildFeatureCard(
                  index,
                  features[index]['icon'] as IconData,
                  features[index]['name'] as String);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(int index, IconData iconData, String featureName) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double padding = screenWidth * 0.04; // ~16 với màn 400px
    final double iconSize = screenWidth * 0.08; // ~32
    final double fontSize = screenWidth * 0.03; // ~12

    return InkWell(
      onTap: () => toFeature(index + 1),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData, size: iconSize, color: mainColor),
              const SizedBox(height: 12),
              Expanded(
                child: Text(
                  featureName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Danh sách các mục thông tin và hỗ trợ ---
  Widget _buildInfoAndSupportList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.description_outlined,
            title: 'Điều khoản & Giấy tờ',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const InfoDisplayPage(
                            title: 'Điều khoản & Giấy tờ',
                            content:
                                'Nội dung chi tiết về điều khoản và các giấy tờ liên quan sẽ được hiển thị ở đây...',
                          )));
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildInfoTile(
            icon: Icons.gavel_outlined,
            title: 'Quy định & Chính sách',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const InfoDisplayPage(
                            title: 'Quy định & Chính sách',
                            content:
                                'Nội dung chi tiết về các quy định và chính sách của công ty sẽ được hiển thị ở đây...',
                          )));
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildInfoTile(
            icon: Icons.support_agent_outlined,
            title: 'Hỗ trợ khách hàng',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const InfoDisplayPage(
                            title: 'Hỗ trợ khách hàng',
                            content:
                                'Thông tin liên hệ hỗ trợ: \n\n- Hotline: 1900 xxxx\n- Email: support@tdlogistic.vn\n- Địa chỉ: ...',
                          )));
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildInfoTile(
            icon: Icons.language_outlined,
            title: 'Thay đổi ngôn ngữ',
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: const Text('Chọn ngôn ngữ'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                              title: const Text('Tiếng Việt'),
                              onTap: () => _changeLanguage('vi')),
                          ListTile(
                              title: const Text('English'),
                              onTap: () => _changeLanguage('en')),
                        ],
                      ),
                    );
                  });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.logout, color: Colors.red),
          label: Text(
            context.tr("user_info.logout"),
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          onPressed: () => _showLogoutDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 255, 220, 220),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
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
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr("user_info.confirmLogout"),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(context.tr("user_info.deny")),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        handleLogoutButton();
                        Navigator.pop(context);
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: mainColor),
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
