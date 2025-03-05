import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/core/constant.dart';

class InsuranceDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết bảo hiểm', style: TextStyle(color: Colors.white),),
        backgroundColor: mainColor, // Màu sắc theo ứng dụng
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 16),
            _buildInfoTile('Loại bảo hiểm', 'Bảo hiểm đơn hàng vận chuyển'),
            _buildInfoTile('Số hợp đồng', 'BH-20240228-12345'),
            _buildInfoTile('Ngày hiệu lực', '01/03/2024'),
            _buildInfoTile('Ngày hết hạn', '01/03/2025'),
            _buildInfoTile('Số tiền bảo hiểm', '500,000,000 VND'),
            _buildInfoTile('Trạng thái', 'Đang hiệu lực', color: Colors.green),
            SizedBox(height: 16),
            _buildDescription(),
            Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Yêu cầu bồi thường', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bảo hiểm đơn hàng vận chuyển',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: secondColor),
        ),
        SizedBox(height: 8),
        Text(
          'Giải pháp tài chính khi hàng hóa gặp rủi ro thiệt hại/mất cắp do thiên tai, cháy nổ, tai nạn, trộm cướp.',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        'Quý khách hàng vui lòng gửi yêu cầu bồi thường trong vòng 01 giờ kể từ khi kết thúc vận chuyển để được giải quyết quyền lợi bảo hiểm.',
        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.red),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 16, color: color ?? Colors.black)),
        ],
      ),
    );
  }
}
