import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tdlogistic_v2/customer/UI/screens/customer_info/info_display_page.dart'; 

enum DocumentType { text, multiImage, placeholder }

class TermsAndDocumentsPage extends StatelessWidget {
  const TermsAndDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> documents = [
      {
        'title': 'Giấy phép kinh doanh',
        'icon': Icons.business_center_outlined,
        'type': DocumentType.placeholder,
      },
      {
        'title': 'Giới thiệu dịch vụ TDLogistics',
        'icon': Icons.info_outline,
        'type': DocumentType.placeholder,
      },
      {
        'title': 'Giấy phép bưu chính',
        'icon': Icons.mail_outline,
        'type': DocumentType.multiImage,
        'data': [ // Danh sách các URL ảnh
          'https://tdlogistics.net.vn/_next/image?url=%2Flicense%2F0003.jpg&w=3840&q=75',
          'https://tdlogistics.net.vn/_next/image?url=%2Flicense%2F0004.jpg&w=3840&q=75',
          'https://tdlogistics.net.vn/_next/image?url=%2Flicense%2F0005.jpg&w=3840&q=75',
        ],
      },
      {
        'title': 'Điều khoản dịch vụ',
        'icon': Icons.description_outlined,
        'type': DocumentType.text,
        'data': """
ĐIỀU KHOẢN VÀ ĐIỀU KIỆN SỬ DỤNG ỨNG DỤNG TDLOGISTICS
Điều 1. Quy định chung:
Bằng việc tải xuống, cài đặt, và/hoặc sử dụng Ứng dụng TDLogistics (sau đây gọi là "Ứng Dụng") để sử dụng các dịch vụ của Tổng Công ty CP Bưu chính TD, Người sử dụng Ứng dụng (sau đây gọi là "Khách Hàng") đồng ý rằng: Khách hàng đã đọc, đã hiểu và đồng ý với các nội dung trong Điều khoản và điều kiện sử dụng ứng dụng TDLogistics này (sau đây gọi là "Điều Khoản Sử Dụng").
... (Dán toàn bộ nội dung Điều khoản vào đây) ...
        """,
      },
      {
        'title': 'Chính sách bảo mật thông tin',
        'icon': Icons.privacy_tip_outlined,
        'type': DocumentType.text,
        'data': """
Chính sách bảo mật
Cập nhật lần cuối: 08/02/2023
1. Mục đích và phạm vi thu thập
TDLogistics chỉ thu thập các thông tin cá nhân cần thiết như họ tên, số điện thoại, email, vị trí của người dùng nhằm mục đích:
... (Dán toàn bộ nội dung Chính sách bảo mật vào đây) ...
        """,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Điều khoản & Giấy tờ", style: TextStyle(color: Colors.white)),
        backgroundColor: mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        itemCount: documents.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final doc = documents[index];
          return ListTile(
            leading: Icon(doc['icon'] as IconData, color: Colors.grey.shade700),
            title: Text(doc['title'] as String, style: const TextStyle(fontSize: 16)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // --- LOGIC ĐIỀU HƯỚNG DỰA TRÊN LOẠI NỘI DUNG ---
              final type = doc['type'] as DocumentType;
              final title = doc['title'] as String;

              switch (type) {
                case DocumentType.multiImage:
                  final imageUrls = doc['data'] as List<String>;
                  Navigator.push(context, MaterialPageRoute(builder: (_) =>
                    MultiImageDisplayPage(title: title, imageUrls: imageUrls)
                  ));
                  break;
                case DocumentType.text:
                  final content = doc['data'] as String;
                  Navigator.push(context, MaterialPageRoute(builder: (_) =>
                    InfoDisplayPage(title: title, content: content)
                  ));
                  break;
                case DocumentType.placeholder:
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nội dung đang được cập nhật.')),
                  );
                  break;
              }
            },
          );
        },
      ),
    );
  }
}

class MultiImageDisplayPage extends StatefulWidget {
  final String title;
  final List<String> imageUrls;

  const MultiImageDisplayPage({
    super.key,
    required this.title,
    required this.imageUrls,
  });

  @override
  State<MultiImageDisplayPage> createState() => _MultiImageDisplayPageState();
}

class _MultiImageDisplayPageState extends State<MultiImageDisplayPage> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black87,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            itemCount: widget.imageUrls.length,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                // Cho phép người dùng phóng to, thu nhỏ ảnh
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrls[index],
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Center(child: Icon(Icons.error, color: Colors.red)),
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
          // Hiển thị số trang hiện tại
          if (widget.imageUrls.length > 1)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Trang ${_currentPage + 1} / ${widget.imageUrls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
