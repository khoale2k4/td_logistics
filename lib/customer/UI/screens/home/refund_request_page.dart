import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/core/constant.dart'; // Import file màu sắc của bạn

class RefundRequestPage extends StatefulWidget {
  // Thêm tham số này để có thể truyền mã vận đơn vào từ trang trước
  final String? initialTrackingNumber;

  const RefundRequestPage({super.key, this.initialTrackingNumber});

  @override
  State<RefundRequestPage> createState() => _RefundRequestPageState();
}

class _RefundRequestPageState extends State<RefundRequestPage> {
  // Key để quản lý và kiểm tra trạng thái của Form
  final _formKey = GlobalKey<FormState>();

  // Controllers để lấy dữ liệu từ các ô nhập liệu
  late final TextEditingController _titleController;
  late final TextEditingController _trackingController;
  late final TextEditingController _contentController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controllers
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    // Gán mã vận đơn ban đầu nếu được truyền vào
    _trackingController = TextEditingController(text: widget.initialTrackingNumber ?? '');
  }

  @override
  void dispose() {
    // Luôn dispose controllers khi widget bị hủy để tránh rò rỉ bộ nhớ
    _titleController.dispose();
    _trackingController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi người dùng nhấn nút "Gửi yêu cầu"
  Future<void> _submitForm() async {
    // Kiểm tra xem tất cả các trường đã hợp lệ chưa
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Lấy dữ liệu từ controllers
      final title = _titleController.text;
      final trackingNumber = _trackingController.text;
      final content = _contentController.text;

      print('Đang gửi yêu cầu hoàn cước:');
      print('Tiêu đề: $title');
      print('Mã vận đơn: $trackingNumber');
      print('Nội dung: $content');

      // --- TODO: GỌI API GỬI YÊU CẦU CỦA BẠN Ở ĐÂY ---
      // Ví dụ: await refundRepository.submitRequest(
      //   title: title,
      //   trackingNumber: trackingNumber,
      //   content: content,
      // );

      // Giả lập việc gọi API mất 2 giây
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isLoading = false);
      
      if (!mounted) return;

      // Hiển thị thông báo thành công và quay lại trang trước
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gửi yêu cầu hoàn cước thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yêu cầu Hoàn cước"),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Trường Tiêu đề ---
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  hintText: 'Ví dụ: Yêu cầu hoàn cước đơn hàng hỏng',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Trường Mã vận đơn ---
              TextFormField(
                controller: _trackingController,
                decoration: const InputDecoration(
                  labelText: 'Mã vận đơn',
                  hintText: 'Nhập mã vận đơn của đơn hàng',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code_scanner),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập mã vận đơn';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Trường Nội dung chi tiết ---
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung chi tiết',
                  hintText: 'Vui lòng mô tả rõ vấn đề bạn gặp phải...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true, // Giúp label hiển thị đẹp hơn
                ),
                maxLines: 6, // Cho phép nhập nhiều dòng
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng mô tả chi tiết vấn đề';
                  }
                  if(value.length < 20) {
                    return 'Nội dung cần chi tiết hơn (ít nhất 20 ký tự)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // --- Nút Gửi yêu cầu ---
              ElevatedButton.icon(
                icon: _isLoading 
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(_isLoading ? 'Đang gửi...' : 'Gửi Yêu Cầu'),
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}