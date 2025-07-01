import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/core/repositories/order_repository.dart';
import 'package:tdlogistic_v2/core/service/google.dart';
import 'package:tdlogistic_v2/core/service/secure_storage_service.dart';
import 'package:tdlogistic_v2/customer/UI/widgets/search_bar.dart';
import 'package:tdlogistic_v2/customer/data/models/calculate_fee_payload.dart';

class FeeCalculationPage extends StatefulWidget {
  const FeeCalculationPage({super.key});

  @override
  State<FeeCalculationPage> createState() => _FeeCalculationPageState();
}

class _FeeCalculationPageState extends State<FeeCalculationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers cho các ô nhập liệu
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _weightController = TextEditingController();
  final _lengthController = TextEditingController();
  // final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final OrderRepository orderRepository = OrderRepository();
  final SecureStorageService secureStorageService = SecureStorageService();

  // Lưu trữ thông tin địa điểm chi tiết
  // PlaceDetail? _originPlace;
  // PlaceDetail? _destinationPlace;

  // Các trạng thái khác
  String _selectedService = 'standard';
  bool _isLoading = false;
  double? _calculatedFee;

  Future<void> _calculateFee() async {
    if (_formKey.currentState!.validate()) {
      // Kiểm tra xem người dùng đã chọn địa chỉ từ gợi ý chưa
      // if (_originPlace == null || _destinationPlace == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Vui lòng chọn điểm đi và điểm đến từ danh sách gợi ý!'), backgroundColor: Colors.red),
      //   );
      //   return;
      // }

      try {
        setState(() {
          _isLoading = true;
          _calculatedFee = null;
        });

        final senderLL = await getLatLngFromAddress(_originController.text);
        final receiverLL =
            await getLatLngFromAddress(_destinationController.text);
        final token = await secureStorageService.getToken();
        final fee = await orderRepository.calculateFee(
            token!,
            CalculateFeePayLoad(
                latDestination: receiverLL!["lat"],
                latSource: senderLL!["lat"],
                longDestination: receiverLL["lng"],
                longSource: senderLL["lng"],
                serviceType:
                    _selectedService != "standard" ? "Siêu nhanh": "Siêu rẻ"));

        print(fee["data"]);
        setState(() {
          _calculatedFee = (fee["data"]["value"] as num).toDouble();
          _isLoading = false;
        });
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        print("Lỗi tính phí " + error.toString());
      }
    }
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _weightController.dispose();
    _lengthController.dispose();
    // _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tra cứu cước phí"),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- VÙNG NHẬP LIỆU ĐỊA CHỈ ---
              const Text("Thông tin vận chuyển",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              MySearchBar(
                  controller: _originController,
                  labelText: 'Điểm đi',
                  icon: const Icon(Icons.location_on_outlined),
                  onChanged: () {},
                  onChoose: () {},
                  onTap: () {},
                  onDelete: () => {} //setState(() => _originPlace = null),
                  // onPlaceSelected: (place) => setState(() => _originPlace = place),
                  ),
              const SizedBox(height: 16),
              MySearchBar(
                  controller: _destinationController,
                  labelText: 'Điểm đến',
                  icon: const Icon(Icons.flag_outlined),
                  onChanged: () {},
                  onTap: () {},
                  onChoose: () {},
                  onDelete: () => {} //setState(() => _destinationPlace = null),
                  // onPlaceSelected: (place) => setState(() => _destinationPlace = place),
                  ),
              const SizedBox(height: 24),

              // --- VÙNG NHẬP LIỆU THÔNG TIN GÓI HÀNG ---
              // const Text("Thông tin gói hàng",
              //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              // const SizedBox(height: 16),
              // TextFormField(
              //   controller: _weightController,
              //   decoration: const InputDecoration(
              //       labelText: 'Khối lượng (kg)', border: OutlineInputBorder()),
              //   keyboardType:
              //       const TextInputType.numberWithOptions(decimal: true),
              //   validator: (value) => (value == null || value.isEmpty)
              //       ? 'Vui lòng nhập khối lượng'
              //       : null,
              // ),
              // Bạn có thể thêm các ô cho kích thước ở đây
              const SizedBox(height: 24),

              // --- VÙNG CHỌN DỊCH VỤ ---
              const Text("Dịch vụ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Tiêu chuẩn'),
                    selected: _selectedService == 'standard',
                    onSelected: (selected) =>
                        setState(() => _selectedService = 'standard'),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Nhanh'),
                    selected: _selectedService == 'express',
                    onSelected: (selected) =>
                        setState(() => _selectedService = 'express'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- NÚT TÍNH CƯỚC ---
              ElevatedButton.icon(
                icon: _isLoading
                    ? const SizedBox.shrink()
                    : const Icon(Icons.calculate_outlined),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Tra cứu cước phí'),
                onPressed: _isLoading ? null : _calculateFee,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),

              // --- HIỂN THỊ KẾT QUẢ ---
              if (_calculatedFee != null)
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text("Cước phí dự kiến",
                            style:
                                TextStyle(fontSize: 16, color: Colors.black54)),
                        const SizedBox(height: 8),
                        Text(
                          "${_calculatedFee!.toStringAsFixed(0)} VNĐ",
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: mainColor),
                        ),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
