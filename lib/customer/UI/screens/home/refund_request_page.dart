import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tdlogistic_v2/core/constant.dart'; // Import file màu sắc của bạn

class RefundRequestPage extends StatefulWidget {
  final String? initialTrackingNumber;

  const RefundRequestPage({super.key, this.initialTrackingNumber});

  @override
  State<RefundRequestPage> createState() => _RefundRequestPageState();
}

class _RefundRequestPageState extends State<RefundRequestPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _trackingController;
  late final TextEditingController _contentController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _trackingController =
        TextEditingController(text: widget.initialTrackingNumber ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _trackingController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('order_pages.refund.success')),
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
        title: Text(context.tr("order_pages.refund.title")),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: GestureDetector(
          onTap: () =>
              FocusScope.of(context).unfocus(), 
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  _buildCardInput(
                    title: context.tr('order_pages.refund.inputTitle'),
                    hint: context.tr('order_pages.refund.inputTitleHint'),
                    icon: Icons.title,
                    controller: _titleController,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? context.tr('order_pages.refund.inputTitleError')
                            : null,
                  ),
                  const SizedBox(height: 16),
                  _buildCardInput(
                    title: context.tr('order_pages.refund.inputTracking'),
                    hint: context.tr('order_pages.refund.inputTrackingHint'),
                    icon: Icons.qr_code,
                    controller: _trackingController,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? context.tr('order_pages.refund.inputTrackingError')
                            : null,
                  ),
                  const SizedBox(height: 16),
                  _buildCardInput(
                    title: context.tr('order_pages.refund.inputContent'),
                    hint: context.tr('order_pages.refund.inputContentHint'),
                    icon: Icons.description_outlined,
                    controller: _contentController,
                    maxLines: 6,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.tr('order_pages.refund.inputContentError');
                      }
                      if (value.length < 20) {
                        return context.tr('order_pages.refund.inputContentShort');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_outlined),
                      label: Text(_isLoading ? context.tr('order_pages.refund.sending') : context.tr('order_pages.refund.sendRequest')),
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: mainColor,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardInput({
    required String title,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          keyboardType:
              maxLines > 1 ? TextInputType.multiline : TextInputType.text,
          decoration: InputDecoration(
            labelText: title,
            hintText: hint,
            prefixIcon: Icon(icon),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
