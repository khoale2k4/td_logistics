import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:url_launcher/url_launcher.dart';

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}

class HelpCenterPage extends StatelessWidget {
  HelpCenterPage({super.key});

  final List<FaqItem> faqItems = [
    FaqItem(
      question: 'Làm thế nào để tạo một đơn hàng mới?',
      answer:
          'Để tạo đơn hàng, bạn vào màn hình chính, nhấn vào nút "Tạo đơn hàng" hoặc chọn mục "Tạo đơn" trong phần tính năng. Sau đó, bạn điền đầy đủ thông tin người gửi, người nhận, và thông tin gói hàng rồi xác nhận.',
    ),
    FaqItem(
      question: 'Làm sao để theo dõi hành trình đơn hàng?',
      answer:
          'Bạn có thể nhập mã vận đơn vào ô "Theo dõi đơn hàng" ở màn hình chính, hoặc vào mục "Lịch sử đơn hàng" và chọn đơn hàng bạn muốn xem chi tiết hành trình.',
    ),
    FaqItem(
      question: 'TDLogistics có nhận vận chuyển những mặt hàng nào?',
      answer:
          'Chúng tôi nhận vận chuyển hầu hết các loại hàng hóa hợp pháp. Tuy nhiên, có một số mặt hàng bị cấm hoặc hạn chế như: chất cấm, vũ khí, động vật sống, hàng hóa dễ cháy nổ... Vui lòng tham khảo chi tiết trong mục "Điều khoản & Giấy tờ".',
    ),
    FaqItem(
      question: 'Chính sách bồi thường thiệt hại như thế nào?',
      answer:
          'TDLogistics có chính sách bồi thường rõ ràng cho các trường hợp mất mát hoặc hư hỏng hàng hóa do lỗi của chúng tôi. Mức bồi thường tùy thuộc vào giá trị hàng hóa và dịch vụ bạn sử dụng. Chi tiết được quy định trong "Điều khoản dịch vụ".',
    ),
    FaqItem(
      question: 'Cước phí vận chuyển được tính như thế nào?',
      answer:
          'Cước phí được tính dựa trên khối lượng thực tế hoặc khối lượng quy đổi từ kích thước (dài x rộng x cao), tùy thuộc vào giá trị nào lớn hơn. Ngoài ra, cước phí còn phụ thuộc vào khoảng cách vận chuyển và loại dịch vụ bạn chọn (nhanh, tiêu chuẩn...).',
    ),
  ];

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trung tâm Trợ giúp',
            style: TextStyle(color: Colors.white)),
        backgroundColor: mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Câu hỏi thường gặp',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...faqItems.map((item) => _buildFaqTile(item)).toList(),

          const SizedBox(height: 24),
          const Divider(thickness: 1),
          const SizedBox(height: 24),

          const Text(
            'Liên hệ với chúng tôi',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildContactMethodsGrid(),
        ],
      ),
    );
  }

  Widget _buildFaqTile(FaqItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      color: Colors.white,
      child: ExpansionTile(
        title: Text(item.question,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        childrenPadding: const EdgeInsets.all(16).copyWith(top: 0),
        expandedAlignment: Alignment.centerLeft,
        children: [
          Text(item.answer,
              style: TextStyle(
                  fontSize: 15, height: 1.5, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildContactMethodsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildContactCard(
          icon: Icons.facebook,
          title: 'Facebook',
          color: Colors.blue.shade800,
          onTap: () => _launchURL(
              'https://m.me/your_facebook_page_username'), // <-- THAY LINK FACEBOOK CỦA BẠN
        ),
        _buildContactCard(
          icon: Icons.message,
          title: 'Zalo',
          color: Colors.blue.shade600,
          onTap: () => _launchURL(
              'https://zalo.me/your_zalo_phone_number'), // <-- THAY SĐT HOẶC ZALO ID CỦA BẠN
        ),
        _buildContactCard(
          icon: Icons.phone_in_talk_outlined,
          title: 'Hotline',
          color: Colors.green,
          onTap: () => _launchURL('tel:19001234'),
        ),
        _buildContactCard(
          icon: Icons.email_outlined,
          title: 'Email',
          color: Colors.red.shade700,
          onTap: () => _launchURL(
              'mailto:support@tdlogistics.vn?subject=Hỗ trợ khách hàng'),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
