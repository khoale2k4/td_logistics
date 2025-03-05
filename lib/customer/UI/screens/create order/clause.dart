import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/core/constant.dart';

class TermsAndConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Điều khoản & Điều kiện', style: TextStyle(color: Colors.white),),
        backgroundColor: mainColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 16),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Điều khoản & Điều kiện sử dụng - TDLogistics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: secondColor),
        ),
        SizedBox(height: 8),
        Text(
          'Chào mừng Quý Khách hàng đến với nền tảng TDLogistics. Trước khi sử dụng, vui lòng đọc kỹ Điều khoản sử dụng.',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Việc tiếp tục sử dụng dịch vụ trên ứng dụng TDLogistics đồng nghĩa với việc Quý Khách hàng đồng ý với các điều khoản và chính sách của chúng tôi.',
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 8),
        Text(
          'TDLogistics bảo lưu quyền được điều chỉnh, sửa đổi hoặc bổ sung bất kỳ điều khoản nào của Điều khoản sử dụng mà không cần báo trước.',
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 8),
        Text(
          'Khách hàng có trách nhiệm kiểm tra thường xuyên để cập nhật những thay đổi mới nhất về điều khoản sử dụng.',
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 8),
        TextButton(
          onPressed: () {},
          child: Text(
            'Xem chi tiết điều khoản',
            style: TextStyle(fontSize: 14, color: mainColor, decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }
}
