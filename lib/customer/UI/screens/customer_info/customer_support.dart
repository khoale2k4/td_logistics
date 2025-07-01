// lib/customer/UI/screens/profile/customer_support_page.dart
import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerSupportPage extends StatelessWidget {
  const CustomerSupportPage({super.key});

  // Hàm để thực hiện cuộc gọi
  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      print('Could not launch $phoneNumber');
    }
  }

  // Hàm để gửi email
  void _sendEmail(String email) async {
    final Uri launchUri = Uri(
        scheme: 'mailto',
        path: email,
        query: 'subject=Hỗ trợ khách hàng TDLogistics');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      print('Could not launch $email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hỗ trợ khách hàng',
            style: TextStyle(color: Colors.white)),
        backgroundColor: mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildSupportItem(
            icon: Icons.phone_in_talk_outlined,
            title: 'Hotline',
            subtitle: '1900 6362 Viettel Post (Ví dụ)',
            onTap: () => _makePhoneCall('19006362'),
          ),
          _buildSupportItem(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: 'support@tdlogistics.vn',
            onTap: () => _sendEmail('support@tdlogistics.vn'),
          ),
          _buildSupportItem(
            icon: Icons.location_on_outlined,
            title: 'Địa chỉ văn phòng',
            subtitle:
                '83 Đinh Tiên Hoàng, P1, Quận Bình Thạnh, Tp Hồ Chí Minh, Việt Nam',
            onTap: () {
              // Có thể mở bản đồ nếu cần
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 30, color: mainColor),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
