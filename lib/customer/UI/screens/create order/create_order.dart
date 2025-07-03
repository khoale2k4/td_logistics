import 'dart:typed_data';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tdlogistic_v2/auth/data/models/user_model.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/core/service/google.dart';
import 'package:tdlogistic_v2/customer/UI/screens/create%20order/add_location.dart';
import 'package:tdlogistic_v2/customer/UI/screens/create%20order/all_locations.dart';
import 'package:tdlogistic_v2/customer/UI/screens/create%20order/clause.dart';
import 'package:tdlogistic_v2/customer/UI/screens/create%20order/insuarance.dart';
import 'package:tdlogistic_v2/customer/UI/screens/create%20order/map_screen.dart';
import 'package:tdlogistic_v2/customer/UI/screens/create%20order/view_insurance.dart';
import 'package:tdlogistic_v2/customer/UI/screens/create%20order/voucher.dart';
import 'package:tdlogistic_v2/customer/UI/widgets/search_bar.dart';
import 'package:tdlogistic_v2/customer/bloc/order_bloc.dart';
import 'package:tdlogistic_v2/customer/bloc/order_event.dart';
import 'package:tdlogistic_v2/customer/bloc/order_state.dart';
import 'package:tdlogistic_v2/customer/data/models/cargo_insurance.dart';
import 'package:tdlogistic_v2/customer/data/models/create_order.dart';
import 'package:tdlogistic_v2/customer/data/models/favorite_location.dart';
import 'package:location/location.dart' as MyLocation;
import 'package:dvhcvn/dvhcvn.dart' as dvhcvn;
import 'package:tdlogistic_v2/customer/data/models/shipping_bill.dart';

class CreateOrder extends StatefulWidget {
  final User user;
  final Function() toHome;
  const CreateOrder({super.key, required this.user, required this.toHome});

  @override
  State<CreateOrder> createState() => _CreateOrderState();
}

class _CreateOrderState extends State<CreateOrder> {
  bool isCalculating = false;
  num fee = 0;
  late User user;

  // Trang nhập thông tin chữ
  TextEditingController _senderAddress =
      TextEditingController(); // Đảm bảo đã khởi tạo
  TextEditingController _senderLocation = TextEditingController();
  final _receiverLocation = TextEditingController();
  final _receiverAddress = TextEditingController();
  bool sendering = false;

  LatLng? _startLatLng;
  LatLng? _endLatLng;

  Future<void> _convertAddresses() async {
    if (_senderLocation.text.isNotEmpty && _receiverLocation.text.isNotEmpty) {
      print(
          "Tìm đường từ ${_senderLocation.text} đến ${_receiverLocation.text}");
      final senderLatLng = await getLatLngFromAddress(_senderLocation.text);
      final receiverLatLng = await getLatLngFromAddress(_receiverLocation.text);

      if (senderLatLng != null && receiverLatLng != null) {
        setState(() {
          _startLatLng = LatLng(senderLatLng['lat']!, senderLatLng['lng']!);
          _endLatLng = LatLng(receiverLatLng['lat']!, receiverLatLng['lng']!);
        });
        print("TÌM THÀNH CÔNG");
      } else {
        print("Không thể lấy tọa độ cho một trong hai địa chỉ.");
      }
    }
  }

  final _senderNameController = TextEditingController();
  final _senderPhoneController = TextEditingController();

  List<Location> favoLocation = [];

  // Validation flags
  bool _validLocation = true;
  bool _validAddress = true;

  bool validateInternationalPhone(String phone) {
    // Loại bỏ tất cả khoảng trắng và ký tự không phải số/dấu +
    final cleanedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Danh sách mã quốc gia phổ biến (có thể mở rộng)
    const countryCodes = {
      'VN': {
        'code': '84',
        'length': 9,
        'minLength': 9,
        'maxLength': 10
      }, // Việt Nam
      'US': {'code': '1', 'length': 10, 'minLength': 10, 'maxLength': 10}, // Mỹ
      'UK': {
        'code': '44',
        'length': 10,
        'minLength': 9,
        'maxLength': 10
      }, // Anh
      'SG': {
        'code': '65',
        'length': 8,
        'minLength': 8,
        'maxLength': 8
      }, // Singapore
      'JP': {
        'code': '81',
        'length': 10,
        'minLength': 9,
        'maxLength': 10
      }, // Nhật
      'KR': {
        'code': '82',
        'length': 9,
        'minLength': 9,
        'maxLength': 10
      }, // Hàn Quốc
    };

    // Kiểm tra số có mã quốc gia (bắt đầu bằng +)
    if (cleanedPhone.startsWith('+')) {
      for (final country in countryCodes.values) {
        final code = country['code'] as String;
        if (cleanedPhone.startsWith('+$code')) {
          final phoneNumber = cleanedPhone.substring(1 + code.length);
          final minLen = country['minLength'] as int;
          final maxLen = country['maxLength'] as int;
          return phoneNumber.length >= minLen &&
              phoneNumber.length <= maxLen &&
              RegExp(r'^\d+$').hasMatch(phoneNumber);
        }
      }
      return false; // Không khớp mã quốc gia nào
    }
    // Kiểm tra số không có mã quốc gia (bắt đầu bằng 0)
    else if (cleanedPhone.startsWith('0')) {
      return RegExp(r'^0\d{9,11}$')
          .hasMatch(cleanedPhone); // Mặc định cho số VN
    }
    // Kiểm tra số có mã quốc gia không có dấu +
    else {
      for (final country in countryCodes.values) {
        final code = country['code'] as String;
        if (cleanedPhone.startsWith(code)) {
          final phoneNumber = cleanedPhone.substring(code.length);
          final minLen = country['minLength'] as int;
          final maxLen = country['maxLength'] as int;
          return phoneNumber.length >= minLen &&
              phoneNumber.length <= maxLen &&
              RegExp(r'^\d+$').hasMatch(phoneNumber);
        }
      }
      return false;
    }
  }

  bool _validateInputs() {
    setState(() {
      _validLocation =
          (_receiverLocation.text != "" && _senderLocation.text != "");
      _validAddress =
          (_receiverAddress.text != "" && _senderAddress.text != "");
    });

    return _validLocation && _validAddress;
  }

  ////////////////////////////////

  // Trang nhập thông tin số
  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _weightController = TextEditingController();
  final TextEditingController _orderDescriptionController =
      TextEditingController();
  final _cashOnDeliveryController = TextEditingController(text: "0");
  final _giftMessageController = TextEditingController();
  final _noteController = TextEditingController();
  int _giftTopic = 0;
  String _selectedGoodsType = "";
  bool _isBulky = false;
  bool _isInsured = false;
  bool _isAGift = false;
  bool _isDoorToDoor = false;
  int _selectedWeightRange = -1;

  bool _isReceiverNameValid = true;
  bool _isReceiverPhoneValid = true;
  bool _isWeightValid = true;
  bool _overMaxWeight = false;
  bool _goodTypeValid = true;

  Future<Map<String, String?>> _pickContact(BuildContext context) async {
    try {
      // Kiểm tra và yêu cầu quyền truy cập danh bạ
      final permissionGranted = await FlutterContacts.requestPermission();
      if (!permissionGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
          content: Text(context.tr('order_pages.create_order.contactPermissionRequired')),
          behavior: SnackBarBehavior.floating,
        ),
        );
        return {};
      }

      // Lấy danh sách liên hệ
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: true,
        sorted: true,
      );

      // Biến để lưu kết quả tìm kiếm
      final searchController = TextEditingController();
      List<Contact> filteredContacts = List.from(contacts);

      // Hiển thị bottom sheet với giao diện cải tiến
      final selectedContact = await showModalBottomSheet<Contact?>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  children: [
                    // Header với nút đóng và tiêu đề
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Chọn liên hệ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    // Thanh tìm kiếm
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm liên hệ...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            filteredContacts = contacts.where((contact) {
                              final name = contact.displayName.toLowerCase();
                              final phone = contact.phones.isNotEmpty
                                  ? contact.phones.first.number.toLowerCase()
                                  : '';
                              return name.contains(value.toLowerCase()) ||
                                  phone.contains(value.toLowerCase());
                            }).toList();
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Danh sách liên hệ
                    Expanded(
                      child: filteredContacts.isEmpty
                          ? const Center(
                              child: Text('Không tìm thấy liên hệ phù hợp'),
                            )
                          : ListView.builder(
                              itemCount: filteredContacts.length,
                              itemBuilder: (context, index) {
                                final contact = filteredContacts[index];
                                return ListTile(
                                  leading: contact.thumbnail != null
                                      ? CircleAvatar(
                                          backgroundImage:
                                              MemoryImage(contact.thumbnail!),
                                        )
                                      : const CircleAvatar(
                                          child: Icon(Icons.person),
                                        ),
                                  title: Text(
                                    contact.displayName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Text(
                                    contact.phones.isNotEmpty
                                        ? contact.phones.first.number
                                        : 'Không có số điện thoại',
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    Navigator.pop(context, contact);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );

      // Trả về thông tin liên hệ đã chọn
      if (selectedContact != null) {
        return {
          'name': selectedContact.displayName,
          'phone': selectedContact.phones.isNotEmpty
              ? selectedContact.phones.first.number
              : null,
        };
      }
    } catch (e) {
      debugPrint('Lỗi khi truy cập danh bạ: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xảy ra lỗi khi truy cập danh bạ'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return {};
  }

  String _selectedDeliveryMethod = 'Giao hàng nhanh';
  List<String> giftTopics = [
    "Ngày quốc tế Phụ nữ 8/3",
    "Ngày của mẹ",
    "Ngày phụ nữ Việt Nam 20/10",
    "Quà sinh nhật",
    "Tết",
    "Valentine",
    "Giáng sinh",
    "Ngày nhà giáo Việt Nam"
  ];

  //////////////////////////////
  final TextEditingController _noteInSController = TextEditingController();
  final List<Uint8List> _images = [];
  bool _isInvoiceEnabled = false;
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _taxCodeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _handleInsuranceForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InsuranceForm(
          initialNote: _noteInSController.text,
          initialImages: _images,
          initialInvoiceEnabled: _isInvoiceEnabled,
          initialCompanyName: _companyNameController.text,
          initialAddress: _addressController.text,
          initialTaxCode: _taxCodeController.text,
          initialEmail: _emailController.text,
        ),
      ),
    );
    if (result == "QUAY VỀ") return;

    if (result != null) {
      _noteInSController.text = result['note'] ?? '';
      _images.clear();
      _images.addAll(result['images'] ?? []);
      _isInvoiceEnabled = result['isInvoiceEnabled'] ?? false;
      _companyNameController.text = result['companyName'] ?? '';
      _addressController.text = result['address'] ?? '';
      _taxCodeController.text = result['taxCode'] ?? '';
      _emailController.text = result['email'] ?? '';
      _isInsured = true;
    } else {
      _isInsured = false;
      _images.clear();
      _noteInSController.clear();
      _isInvoiceEnabled = false;
      _companyNameController.clear();
      _addressController.clear();
      _taxCodeController.clear();
      _emailController.clear();
    }
    setState(() {});
  }

  //////////////////////////////
  String _selectedPaymentMethod = "";
  bool _senderWillPay = true;

  GiftOrder getGift(String msg, String topic) {
    Map<String, String> topic2id = {
      "Ngày phụ nữ Việt Nam 20/10": "3b00c63a-80d6-4ee3-8752-3e04976c117c",
      "Ngày nhà giáo Việt Nam": "3b00c63a-80d6-4ee3-8752-3e04976c117e"
    };
    GiftOrder go = GiftOrder();
    go.topicId = topic2id[topic];
    go.message = msg;
    return go;
  }

  bool _validateNumberInputs() {
    setState(() {
      _isReceiverNameValid = _receiverNameController.text != "";
      _isReceiverPhoneValid =
          validateInternationalPhone(_receiverPhoneController.text);
      _isWeightValid = (_selectedWeightRange != -1 || _isBulky);
      _goodTypeValid = (_selectedGoodsType != null);
    });
    return (_isReceiverNameValid &&
        _isReceiverPhoneValid &&
        _isWeightValid &&
        _goodTypeValid);
  }

  Future<void> calculateFee() async {
    try {
      final senderLL = await getLatLngFromAddress(_senderLocation.text);
      final receiverLL = await getLatLngFromAddress(_receiverLocation.text);
      context.read<OrderBlocFee>().add(CalculateFee(
          cod: int.tryParse(_cashOnDeliveryController.text) ?? 0,
          latDestination: receiverLL!["lat"] ?? 0,
          latSource: senderLL!["lat"] ?? 0,
          longSource: senderLL!["lng"] ?? 0,
          longDestination: receiverLL!["lng"] ?? 0,
          serviceType: _selectedDeliveryMethod ==
                  context.tr("order_pages.order_detail_page.quick_transmit")
              ? "Siêu nhanh"
              : "Siêu rẻ",
          voucherId: voucher));
    } catch (error) {
      print("Lỗi khi tính toán chi phí: ${error.toString()}");
    }
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Không cho phép đóng khi nhấn bên ngoài.
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(context.tr('order_pages.confirm_page.confirm')),
          content: Text(context.tr('order_pages.confirm_page.confirmation')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Đóng popup.
              },
              child: Text(context.tr('order_pages.confirm_page.cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Đóng popup.
                handleNewOrder(context); // Gọi hàm tạo đơn hàng.
              },
              style: ElevatedButton.styleFrom(backgroundColor: mainColor),
              child: Text(context.tr('order_pages.confirm_page.confirm'),
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String? voucher;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _senderNameController.text =
        "${user.firstName ?? ""} ${user.lastName ?? ""}".trim();
    _senderPhoneController.text = user.phoneNumber ?? "";
    _pageController = PageController(initialPage: 1);

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<GetLocationBloc>().add(GetLocations());
    // });
    context.read<GetLocationBloc>().add(GetLocations());
    _initializeData();
    _requestPhonePermission();
  }

  Future<void> _requestPhonePermission() async {
    final status = await Permission.contacts.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cần cấp quyền vị trí để sử dụng tính năng này')),
      );
    }
  }

  Future<void> _initializeData() async {
    try {
      print("Bắt đầu khởi tạo dữ liệu");
      MyLocation.Location myLocation = MyLocation.Location();
      final location = await myLocation.getLocation();
      String? _currentLocation;
      if (location.latitude != null && location.longitude != null) {
        _currentLocation = await convertLatLngToAddress(
            location.latitude!, location.longitude!);
      }
      if (_currentLocation != null) {
        setState(() {
          _senderAddress.text = _currentLocation!;
          _senderLocation.text = _currentLocation;
        });
      }
      print("Hoàn thành khởi tạo dữ liệu");
    } catch (error) {
      print("Lỗi khi khởi tạo dữ liệu: $error"); // In ra lỗi nếu có
    }
  }

  late PageController _pageController;
  final _numberController = TextEditingController();
  int _currentPage = 1;

  String createShareContent() {
    String content = '''
Thông tin người gửi:
- Tên: ${_senderNameController.text}
- SĐT: ${_senderPhoneController.text}
- Địa chỉ: ${_senderAddress.text}
- Vị trí: ${_senderLocation.text}

Thông tin người nhận:
- Tên: ${_receiverNameController.text}
- SĐT: ${_receiverPhoneController.text}
- Địa chỉ: ${_receiverAddress.text}
- Vị trí: ${_receiverLocation.text}

Chi tiết đơn hàng:
- Mô tả: ${_orderDescriptionController.text}
- Trọng lượng: ${_weightController.text} kg
- Phí giao hàng: ${fee} VNĐ
- Loại hàng hóa: ${_selectedGoodsType ?? 'Không có'}
- Dịch vụ: ${_selectedDeliveryMethod}
- Thanh toán khi nhận: ${_cashOnDeliveryController.text} VNĐ
- Ghi chú: ${_noteController.text}

Thông tin quà tặng:
- ${_isAGift ? 'Lời nhắn: ${_giftMessageController.text}\n- Chủ đề: ${giftTopics[_giftTopic]}' : 'Không có'}

Hình thức thanh toán:
- Phương thức: ${_selectedPaymentMethod}
- Người trả phí: ${_senderWillPay ? 'Người gửi' : 'Người nhận'}

Thông tin hóa đơn:
- Công ty: ${_companyNameController.text}
- Địa chỉ: ${_addressController.text}
- Mã số thuế: ${_taxCodeController.text}
- Email: ${_emailController.text}

Số lượng hình ảnh đính kèm: ${_images.length}
  ''';

    return content;
  }

  @override
  void dispose() {
    // Dispose các trang nhập
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();

    _cashOnDeliveryController.dispose();

    _pageController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Map<String, String> getAddress(String address) {
    Map<String, String> rs = {};
    try {
      List<String> part = address.split(", ");
      if (part.length == 2) {
        rs["province"] = part[0];
      } else if (part.length == 3) {
        rs["province"] = part[1];
        rs["district"] = part[0];
      } else if (part.length == 4) {
        rs["province"] = part[2];
        rs["district"] = part[1];
        rs["ward"] = part[0];
      } else {
        int n = part.length;
        rs["province"] = part[n - 2];
        dvhcvn.Level1 lv1 = dvhcvn.level1s
            .where((item) =>
                item.name.toLowerCase().contains(rs["province"]!.toLowerCase()))
            .toList()
            .first;
        rs["province"] = lv1.name;
        rs["district"] = part[n - 3];
        dvhcvn.Level2 lv2 = lv1.children
            .where((item) =>
                item.name.toLowerCase().contains(rs["district"]!.toLowerCase()))
            .first;
        rs["district"] = lv2.name;
        rs["ward"] = part[n - 4];
        dvhcvn.Level3 lv3 = lv2.children
            .where((item) =>
                item.name.toLowerCase().contains(rs["ward"]!.toLowerCase()))
            .first;
        rs["ward"] = lv3.name;
        rs["detail"] = part.sublist(0, n - 4).join(", ");
      }
      return rs;
    } catch (error) {
      print(error.toString());
      return rs;
    }
  }

  String getTypeCode() {
    String type = _selectedGoodsType!;
    if (type == 'Hàng dễ vỡ') return "FRAGILE";
    if (type == "Thực phẩm") return "FOOD";
    if (type == "QUẦN ÁO") return "CLOTHES";
    return "OTHER";
  }

  String toProper(String input) {
    return input
        .toLowerCase() // Chuyển tất cả về chữ thường
        .split(' ') // Tách chuỗi thành danh sách các từ
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '') // Viết hoa chữ cái đầu tiên của mỗi từ
        .join(' '); // Ghép lại thành chuỗi
  }

  Future<void> handleNewOrder(BuildContext context) async {
    try {
      final senderAddress = getAddress(_senderLocation.text);
      final receiverAddress = getAddress(_receiverLocation.text);
      final senderLL = await getLatLngFromAddress(_senderAddress.text);
      final receiverLL = await getLatLngFromAddress(_receiverAddress.text);
      int? cod = int.tryParse(_cashOnDeliveryController.text);
      context.read<CreateOrderBloc>().add(
            CreateOrderEvent(
                CreateOrderObject(
                    cod: (cod == null || cod == 0) ? null : cod,
                    detailDest:
                        //"20 Lý Thái Tổ",
                        receiverAddress["detail"],
                    detailSource:
                        //"Đường tỉnh 52, tổ 6 Khu phố Hiệp Hòa",
                        senderAddress["detail"],
                    districtDest:
                        // "Thành phố Vũng Tàu",
                        receiverAddress["district"],
                    districtSource:
                        // "Huyện Đất Đỏ",
                        senderAddress["district"],
                    mass: (int.tryParse(_weightController.text)),
                    nameReceiver: toProper(_receiverNameController.text),
                    nameSender: toProper(_senderNameController.text),
                    phoneNumberReceiver: _receiverPhoneController.text,
                    phoneNumberSender: _senderPhoneController.text,
                    provinceDest:
                        // "Tỉnh Bà Rịa - Vũng Tàu",
                        receiverAddress["province"],
                    provinceSource:
                        // "Tỉnh Bà Rịa - Vũng Tàu",
                        senderAddress["province"],
                    // sửa loại gửi hàng
                    serviceType: _selectedDeliveryMethod ==
                            context.tr(
                                "order_pages.order_detail_page.quick_transmit")
                        ? "Siêu nhanh"
                        : _selectedDeliveryMethod ==
                                context.tr(
                                    "order_pages.order_detail_page.eco_transmit")
                            ? "Siêu rẻ"
                            : _selectedDeliveryMethod ==
                                    context
                                        .tr("order_pages.order_detail_page.hht")
                                ? "HTT"
                                : _selectedDeliveryMethod ==
                                        context.tr(
                                            "order_pages.order_detail_page.ttk")
                                    ? "TTK"
                                    : "CPN",
                    wardDest:
                        // "Phường Đất Đỏ",
                        receiverAddress["ward"],
                    wardSource:
                        // "Xã Long Mỹ",
                        senderAddress["ward"],
                    deliverDoorToDoor: _isDoorToDoor,
                    fromMass: _selectedWeightRange.toInt() == -1
                        ? null
                        : _selectedWeightRange.toInt() * 5,
                    toMass: _selectedWeightRange.toInt() == -1
                        ? null
                        : (_selectedWeightRange.toInt() + 1) * 5,
                    goodType: getTypeCode(),
                    latDestination: receiverLL!["lat"],
                    latSource: senderLL!["lat"],
                    longDestination: receiverLL["lng"],
                    longSource: senderLL["lng"],
                    receiverWillPay: _senderWillPay,
                    takingDescription: _orderDescriptionController.text,
                    note: _noteController.text,
                    paymentMethod: _selectedPaymentMethod ==
                            context.tr(
                                "order_pages.payment_page.payment_methods.bank_transfer")
                        ? "BY_BANK_TRANSFER"
                        : "BY_CASH",
                    giftOrder: _isAGift
                        ? getGift(
                            _giftMessageController.text, giftTopics[_giftTopic])
                        : null,
                    voucherId: voucher),
                _images,
                _isInsured && _isInvoiceEnabled
                    ? ShippingBill(
                        companyAddress: _addressController.text,
                        companyName: _companyNameController.text,
                        email: _emailController.text,
                        taxCode: _taxCodeController.text,
                      )
                    : null,
                _isInsured
                    ? CargoInsurance(
                        hasDeliveryCare: _isInvoiceEnabled,
                        note: _noteInSController.text,
                      )
                    : null),
          );
    } catch (error) {
      print("Lỗi khi tạo đơn: ${error.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              const SizedBox(height: 50),
              Expanded(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    _buildMain(context),
                    _buildTextInputPage(),
                    _buildNumberInputPage(),
                    _buildPaymentPage(context),
                    _buildConfirmPage(context),
                  ],
                ),
              ),
              _buildNextButton(),
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMain(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          Container(
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              icon: const Icon(Icons.add, color: Colors.green, size: 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title, {
    bool button = false,
    String textButton = "",
    required Function() func, // Thêm tham số func với required
    bool sender = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          if (button) ...[
            Expanded(child: Container()),
            TextButton(
              onPressed: () {
                func(); // Gọi hàm khi nút được nhấn
              },
              child: Text(textButton),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildTextInputPage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      context.tr("order_pages.locations_page.delivery"),
                      func: () {
                        print("OK");
                      },
                      textButton: context.tr("order_pages.locations_page.map"),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MySearchBar(
                                icon: const Icon(
                                  Icons.start,
                                  color: secondColor,
                                ),
                                labelText: context.tr(
                                    "order_pages.locations_page.sender_location"),
                                controller: _senderLocation,
                                onChanged: () {
                                  _senderAddress.text = _senderLocation.text;
                                },
                                onChoose: () {
                                  _convertAddresses();
                                },
                                onTap: () {
                                  sendering = true;
                                },
                                onDelete: () {
                                  setState(() {
                                    _senderAddress.clear();
                                    _senderLocation.clear();
                                    _startLatLng = null;
                                  });
                                },
                              ),
                              MySearchBar(
                                icon: const Icon(Icons.last_page,
                                    color: mainColor),
                                labelText: context.tr(
                                    "order_pages.locations_page.receiver_location"),
                                controller: _receiverLocation,
                                onChanged: () {
                                  _receiverAddress.text =
                                      _receiverLocation.text;
                                },
                                onChoose: () {
                                  _convertAddresses();
                                },
                                onTap: () {
                                  _validLocation = true;
                                  _validAddress = true;
                                  sendering = false;
                                },
                                onDelete: () {
                                  setState(() {
                                    _receiverAddress.clear();
                                    _receiverLocation.clear();
                                    _convertAddresses();
                                    _startLatLng = null;
                                  });
                                },
                              ),
                              if (!_validLocation && !_validAddress)
                                Text(
                                  context.tr(
                                      "order_pages.locations_page.please_enter_address"),
                                  style: const TextStyle(color: Colors.red),
                                )
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              String temp = _senderLocation.text;
                              String temp2 = _senderAddress.text;
                              _senderLocation.text = _receiverLocation.text;
                              _senderAddress.text = _receiverAddress.text;
                              _receiverLocation.text = temp;
                              _receiverAddress.text = temp2;
                              _startLatLng = null;
                              _endLatLng = null;
                              _convertAddresses();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.all(0),
                          ),
                          child: const Icon(
                            Icons.swap_vert,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    BlocBuilder<GetLocationBloc, OrderState>(
                      builder: (context, state) {
                        if (state is FailGettingLocations) {
                          return Text("Lỗi: ${state.error}");
                        } else if (state is GotLocations) {
                          return buildHorizontalLocationList(state.locations);
                        } else {
                          return Text(context.tr(
                              "order_pages.locations_page.fetching_locations"));
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    if (_startLatLng != null && _endLatLng != null)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 400),
                        child: MapScreen(
                          startLocation: _startLatLng ?? const LatLng(0, 1),
                          endLocation: _endLatLng ?? const LatLng(0, 1),
                        ),
                      ),
                    const SizedBox(height: 10),
                    _buildSectionTitle(
                      context.tr(
                          "order_pages.locations_page.favorite_pickup_location"),
                      button: true,
                      textButton: context.tr("order_pages.locations_page.more"),
                      func: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NewLocation(
                                location: "Thêm", isFav: true),
                          ),
                        );
                        if (result == null) return;
                        final latLng = await getLatLngFromAddress(result[3]) ??
                            {"lat": 0, "lng": 0};
                        if (result != null) {
                          setState(() {
                            context.read<GetLocationBloc>().add(
                                  AddLocation(
                                    faLoc: FavoriteLocation(
                                      name: result[0],
                                      phoneNumber: result[1],
                                      description: result[2],
                                      lat: latLng["lat"],
                                      lng: latLng["lng"],
                                    ),
                                  ),
                                );
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              BlocBuilder<GetLocationBloc, OrderState>(
                builder: (context, state) {
                  if (state is FailGettingLocations) {
                    return Text("Lỗi: ${state.error}");
                  } else if (state is GotLocations) {
                    return Container(
                      constraints: BoxConstraints(
                        maxHeight:
                            constraints.maxHeight - 300, // Giới hạn chiều cao
                      ),
                      child: _buildFavoriteLocations(state.favLocations),
                    );
                  } else {
                    return Text(context
                        .tr("order_pages.locations_page.fetching_locations"));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildHorizontalLocationList(List<Location> locations) {
    String getNameLabel(String? type) {
      return (type ?? "???") == "HOME"
          ? "Nhà"
          : (type ?? "???") == "COMPANY"
              ? "Công ty"
              : type!;
    }

    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: locations.length + _buildTrailingButtons(locations).length,
        itemBuilder: (context, index) {
          if (index >= locations.length) {
            return _buildTrailingButtons(locations)[index - locations.length];
          } else {
            final location = locations[index];
            return Row(
              children: [
                Container(
                  margin: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(45),
                    color: Colors.grey.shade300,
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      String address = await convertLatLngToAddress(
                              location.lat!, location.lng!) ??
                          "";

                      setState(() {
                        if (sendering) {
                          _senderLocation.text = address;
                          _senderAddress.text = address;
                        } else {
                          _receiverLocation.text = address;
                          _receiverAddress.text = address;
                        }
                      });
                      _convertAddresses();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(45),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      getNameLabel(location.name),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
              ],
            );
          }
        },
      ),
    );
  }

  List<Widget> _buildTrailingButtons(List<Location> locations) {
    List<Widget> trailingButtons = [];

    // Kiểm tra nếu không có Location nào có type là "HOME", thêm nút "Nhà"
    bool hasHomeLocation = locations.any((location) => location.name == "HOME");
    if (!hasHomeLocation) {
      trailingButtons.add(
        Row(
          children: [
            addButton(
              name: "Nhà",
              icon: const Icon(Icons.add),
              func: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewLocation(location: "Nhà"),
                  ),
                );
                if (result != null) {
                  final latLng = await getLatLngFromAddress(result[1]) ??
                      {"lat": 0, "lng": 0};
                  context.read<GetLocationBloc>().add(AddLocation(
                      loc: Location(
                          name: "HOME",
                          lat: latLng["lat"],
                          lng: latLng["lng"])));
                  // context.read<GetLocationBloc>().add(GetLocations());
                }
              },
            ),
            const SizedBox(width: 5),
          ],
        ),
      );
    }

    // Kiểm tra nếu không có Location nào có type là "COMPANY", thêm nút "Công ty"
    bool hasCompanyLocation =
        locations.any((location) => location.name == "COMPANY");
    if (!hasCompanyLocation) {
      trailingButtons.add(
        Row(
          children: [
            addButton(
              name: "Công ty",
              icon: const Icon(Icons.add),
              func: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const NewLocation(location: "Công ty"),
                  ),
                );
                if (result != null) {
                  final latLng = await getLatLngFromAddress(result[1]) ??
                      {"lat": 0, "lng": 0};
                  context.read<GetLocationBloc>().add(AddLocation(
                      loc: Location(
                          name: "COMPANY",
                          lat: latLng["lat"],
                          lng: latLng["lng"])));
                  // context.read<GetLocationBloc>().add(GetLocations());
                }
              },
            ),
            const SizedBox(width: 5),
          ],
        ),
      );
    }

    // Thêm nút "Thêm"
    trailingButtons.add(
      Row(
        children: [
          addButton(
            name: context.tr("order_pages.locations_page.more"),
            icon: const Icon(Icons.add),
            func: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewLocation(location: "Thêm"),
                ),
              );
              if (result != null) {
                final latLng = await getLatLngFromAddress(result[1]) ??
                    {"lat": 0, "lng": 0};
                if (mounted) {
                  context.read<GetLocationBloc>().add(AddLocation(
                      loc: Location(
                          name: result[0],
                          lat: latLng["lat"],
                          lng: latLng["lng"])));
                  // context.read<GetLocationBloc>().add(GetLocations());
                }
              }
            },
          ),
          const SizedBox(width: 5),
        ],
      ),
    );

    // Thêm nút "Xem tất cả"
    trailingButtons.add(
      Row(
        children: [
          ElevatedButton.icon(
            onPressed: () {
              // Điều hướng đến trang xem tất cả các địa điểm
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllLocationsPage(),
                ),
              );
            },
            icon: const Icon(Icons.location_on, color: Colors.black),
            label: Text(context.tr("order_pages.locations_page.see_all"),
                style: const TextStyle(color: Colors.black)),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(45),
              ),
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
    );

    return trailingButtons;
  }

  Widget addButton(
      {required String name, required Icon icon, required Function() func}) {
    return Container(
      margin: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(45),
        color: Colors.grey.shade300,
      ),
      child: ElevatedButton(
        onPressed: () {
          func();
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(45),
          ),
          elevation: 0,
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 5),
            Text(
              name,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteLocations(List<FavoriteLocation> locations) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        return Card(
          color: Colors.white,
          child: InkWell(
            onTap: () async {
              final address =
                  await convertLatLngToAddress(location.lat!, location.lng!);
              setState(() {
                _receiverNameController.text = location.name ?? '';
                _receiverPhoneController.text = location.phoneNumber ?? '';
                _receiverAddress.text = address ?? '';
              });
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(
                  "${location.name ?? 'Không có tên'}, ${location.phoneNumber ?? 'Không có số điện thoại'}"),
              subtitle: FutureBuilder<String?>(
                future: convertLatLngToAddress(location.lat!, location.lng!),
                builder:
                    (BuildContext context, AsyncSnapshot<String?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Đang tải");
                  } else if (snapshot.hasError) {
                    return Text('Đã xảy ra lỗi: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return const Text('Không tìm thấy địa chỉ');
                  } else {
                    return Text(
                      snapshot.data!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    );
                  }
                },
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final address = await convertLatLngToAddress(
                      location.lat!, location.lng!);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewLocation(
                        location: "Thêm",
                        locationId: location.id!,
                        address: address ?? "",
                        isEdit: true,
                        isFav: true,
                        description: location.description!,
                        name: location.name!,
                        phone: location.phoneNumber!,
                      ),
                    ),
                  );
                  print(result);
                  if (result != null) {
                    final newLatLng = await getLatLngFromAddress(result[3]);
                    if (newLatLng == null) return;
                    setState(() {
                      locations[index] = FavoriteLocation(
                        lat: newLatLng["lat"],
                        lng: newLatLng["lng"],
                        name: result[0],
                        phoneNumber: result[1],
                        description: result[2],
                        id: location.id,
                      );
                    });
                    context
                        .read<GetLocationBloc>()
                        .add(UpdateFavoriteLocation(locations[index]));
                    // await Future.delayed(const Duration(seconds: 1));
                    // context.read<GetLocationBloc>().add(GetLocations());
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required ValueChanged<String?> onChanged,
    required String labelText,
    required Icon icon,
    bool isDes = false,
    bool fromContacts = false,
    bool isSender = true,
    bool addToFavo = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        maxLines: isDes ? 3 : 1,
        decoration: InputDecoration(
          labelText: labelText,
          filled: true,
          fillColor: Colors.white,
          prefixIcon: icon,

          // Thêm icon chỉ báo danh bạ
          suffixIcon: fromContacts
              ? InkWell(
                  onTap: () async {
                    final contact = await _pickContact(context);
                    if (contact != null) {
                      _receiverNameController.text = contact['name'] ?? '';
                      _receiverPhoneController.text = contact['phone'] ?? '';
                    }
                    print("SMTH");
                  },
                  child: const Icon(Icons.contact_page, color: Colors.blue),
                )
              : null,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: secondColor, width: 3),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
        onChanged: onChanged,
        onTap: () {
          setState(() {
            sendering = isSender;
          });
        },
      ),
    );
  }

  Widget _buildDropdown({
    required String labelText,
    required List<String> items,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
    required bool isValid,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: labelText,
          labelStyle: TextStyle(
            color: isValid ? Colors.grey.shade700 : secondColor,
          ),
          errorText: isValid ? null : 'Vui lòng chọn $labelText',
          prefixIcon:
              Icon(icon, color: isValid ? Colors.grey.shade700 : Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: secondColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        hint: Text(
          'Chọn một $labelText',
          style: TextStyle(color: Colors.grey.shade500),
        ),
        dropdownColor: Colors.white,
        iconEnabledColor: secondColor,
        iconSize: 28,
        isExpanded: true,
      ),
    );
  }

  Widget _buildNumberInputPage() {
    _selectedDeliveryMethod =
        context.tr("order_pages.order_detail_page.quick_transmit");
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 50.0, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context.tr("history.recevier"), func: () {
              setState(() {
                _receiverNameController.text = _senderNameController.text;
                _receiverPhoneController.text = _senderPhoneController.text;
              });
            },
                button: true,
                textButton:
                    context.tr("order_pages.order_detail_page.i_am_receiver")),
            const SizedBox(height: 30),
            _buildTextField(
              controller: _receiverNameController,
              labelText:
                  context.tr("order_pages.order_detail_page.receiver_name"),
              onChanged: (value) {},
              icon: const Icon(Icons.person),
            ),
            if (!_isReceiverNameValid)
              Text(context.tr("order_pages.order_detail_page.enter_name"),
                  style: const TextStyle(color: Colors.red)),
            _buildTextField(
                controller: _receiverPhoneController,
                labelText:
                    context.tr("order_pages.order_detail_page.receiver_phone"),
                onChanged: (value) {},
                icon: const Icon(Icons.phone),
                fromContacts: true),
            if (!_isReceiverPhoneValid)
              Text(context.tr("order_pages.order_detail_page.enter_phone"),
                  style: const TextStyle(color: Colors.red)),
            _buildTextField(
              controller: _orderDescriptionController,
              labelText:
                  context.tr("order_pages.order_detail_page.description"),
              onChanged: (value) {},
              icon: const Icon(Icons.note),
              isDes: true,
            ),
            const SizedBox(height: 30),
            Text(
              context.tr("order_pages.order_detail_page.package_info"),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 30),

            // Trường nhập số tiền thu hộ (không cần kiểm tra hợp lệ)
            _buildNumberField(
              controller: _cashOnDeliveryController,
              labelText: context.tr("order_pages.order_detail_page.cod_amount"),
              hintText: context.tr("order_pages.order_detail_page.enter_cod"),
              isEmpty: true,
            ),
            const SizedBox(height: 20),

            // Lưới nút chọn khối lượng
            Text(
              context.tr("order_pages.order_detail_page.weight_range"),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < 8; i++)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedWeightRange = i;
                        _isBulky = false;
                        _weightController.clear();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: _selectedWeightRange == i
                                ? Colors.black
                                : Colors.transparent),
                        borderRadius:
                            BorderRadius.circular(10), // Set border radius here
                      ),
                    ),
                    child: Text(
                      '${i * 5}-${(i + 1) * 5} kg',
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  )
              ],
            ),
            if (!_isWeightValid)
              Text(context.tr("order_pages.order_detail_page.select_weight"),
                  style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 10),
            _buildNumberField(
                controller: _weightController,
                labelText:
                    context.tr("order_pages.order_detail_page.not_obligatory"),
                hintText:
                    context.tr("order_pages.order_detail_page.enter_weight"),
                isEmpty: true,
                onChangedCallback: (value) {
                  setState(() {
                    // Kiểm tra nếu value là chuỗi trống hoặc không thể chuyển thành số
                    if (value == null ||
                        value.isEmpty ||
                        int.tryParse(value) == null) {
                      _selectedWeightRange = -1;
                      _isBulky = false;
                    } else {
                      // Chuyển đổi value thành số nguyên
                      int temp = (int.parse(value) / 5).floor();

                      // Xác định _selectedWeightRange và _isBulky dựa trên giá trị của temp
                      if (temp < 8) {
                        if (int.parse(value) == 0) {
                          _overMaxWeight = true;
                          _selectedWeightRange = -1;
                          _isBulky = false;
                        } else {
                          _selectedWeightRange = temp;
                          _isBulky = false;
                          _overMaxWeight = false;
                        }
                      } else {
                        if (int.parse(value) > 50 || int.parse(value) <= 0) {
                          _overMaxWeight = true;
                          _selectedWeightRange = -1;
                          _isBulky = false;
                        } else {
                          _overMaxWeight = false;
                          _selectedWeightRange = -1;
                          _isBulky = true;
                        }
                      }
                    }
                  });
                }),
            if (_overMaxWeight)
              Text(
                context.tr("order_pages.order_detail_page.select_weight"),
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),

            // Lưới nút chọn loại hàng hoá
            Text(
              context.tr("order_pages.order_detail_page.goods_type"),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var type in [
                  context
                      .tr("order_pages.order_detail_page.good_types.breakable"),
                  context.tr("order_pages.order_detail_page.good_types.food"),
                  context
                      .tr("order_pages.order_detail_page.good_types.clothes"),
                  context.tr("order_pages.order_detail_page.good_types.fresh"),
                  context.tr("order_pages.order_detail_page.good_types.others")
                ])
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedGoodsType = type;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: _selectedGoodsType == type
                                ? Colors.black
                                : Colors.transparent),
                        borderRadius:
                            BorderRadius.circular(10), // Set border radius here
                      ),
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
            if (!_goodTypeValid)
              Text(
                  context.tr("order_pages.order_detail_page.select_goods_type"),
                  style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 20),
            _buildToggleButton(
              title: context.tr("order_pages.order_detail_page.bulky_goods"),
              isSelected: _isBulky,
              callBack: (bool value) {
                setState(() {
                  _weightController.text = "";
                  _isBulky = value;
                  _selectedWeightRange = -1;
                });
              },
              description: context.tr("order_pages.order_detail_page.bg_des"),
            ),
            const SizedBox(height: 20),
            _buildToggleButton(
              title: context.tr("order_pages.order_detail_page.gift_order"),
              isSelected: _isAGift,
              callBack: (bool value) {
                setState(() {
                  _isAGift = value;
                });
              },
              description: context.tr("order_pages.order_detail_page.go_des"),
            ),
            if (_isAGift) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < 8; i++)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _giftTopic = i;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: _giftTopic == i
                                  ? Colors.black
                                  : Colors.transparent),
                          borderRadius: BorderRadius.circular(
                              10), // Set border radius here
                        ),
                      ),
                      child: Text(
                        giftTopics[i],
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    )
                ],
              ),
              _buildTextField(
                  controller: _giftMessageController,
                  labelText:
                      context.tr("order_pages.confirm_page.gift_message"),
                  onChanged: (value) {
                    if (value != null) _giftMessageController.text = value;
                  },
                  icon: const Icon(Icons.message),
                  isDes: true),
            ],

            const SizedBox(height: 20),
            _buildToggleButton(
              title:
                  context.tr("order_pages.order_detail_page.delivery_to_door"),
              isSelected: _isDoorToDoor,
              callBack: (bool value) {
                setState(() {
                  _isDoorToDoor = value;
                });
              },
              description: context.tr("order_pages.order_detail_page.dtd_des"),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: InkWell(
                onTap: _handleInsuranceForm,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      width: _isInsured ? 1 : 0,
                    ),
                    color: Colors.blueGrey.shade50,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _isInsured,
                        onChanged: (bool? value) {
                          _handleInsuranceForm();
                        },
                        checkColor: Colors.white,
                        activeColor: secondColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isInsured
                            ? context.tr(
                                "order_pages.order_detail_page.insurance_added")
                            : context
                                .tr("order_pages.order_detail_page.insurance"),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Dropdown cho phương thức giao
            _buildDropdown(
              items: [
                context.tr("order_pages.order_detail_page.eco_transmit"),
                context.tr("order_pages.order_detail_page.quick_transmit"),
                context.tr("order_pages.order_detail_page.hht"),
                context.tr("order_pages.order_detail_page.cpn"),
                context.tr("order_pages.order_detail_page.ttk")
              ],
              selectedValue: _selectedDeliveryMethod,
              labelText:
                  context.tr("order_pages.order_detail_page.shipping_method"),
              isValid: true,
              icon: Icons.local_shipping,
              onChanged: (value) {
                setState(() {
                  if (value != null) _selectedDeliveryMethod = value;
                });
              },
            ),
            _buildTextField(
                controller: _noteController,
                labelText: context.tr("order_pages.order_detail_page.note"),
                onChanged: (value) {
                  setState(() {});
                },
                icon: const Icon(Icons.pending_actions),
                isDes: true),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String title,
    required bool isSelected,
    required Function(bool) callBack,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Switch(
              value: isSelected,
              activeColor: mainColor,
              onChanged: (value) {
                callBack(value); // Gọi callback với giá trị mới
              },
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          description,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    Function(String? value)? onChangedCallback,
    bool isEmpty = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: (value) {
        if (onChangedCallback == null) return;
        onChangedCallback(value);
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: secondColor, width: 1.5),
        ),
        labelText: labelText,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        errorText: isEmpty ? null : 'Vui lòng nhập $labelText',
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }

  Widget _buildPaymentPage(BuildContext context) {
    _selectedPaymentMethod = _selectedPaymentMethod == ''
        ? context.tr("order_pages.payment_page.payment_methods.cash")
        : _selectedPaymentMethod;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context.tr('order_pages.payment_page.title'),
                func: () {}),
            _buildDropdown(
              items: [
                context.tr(
                    "order_pages.payment_page.payment_methods.bank_transfer"),
                context.tr("order_pages.payment_page.payment_methods.cash"),
                // context.tr("order_pages.payment_page.payment_methods.e_wallet"),
              ],
              selectedValue: _selectedPaymentMethod,
              labelText:
                  context.tr('order_pages.payment_page.payment_method_label'),
              isValid: true,
              icon: Icons.payment,
              onChanged: (value) {
                setState(() {
                  if (value != null) _selectedPaymentMethod = value;
                });
              },
            ),
            const SizedBox(height: 20),
            BlocBuilder<OrderBlocFee, OrderState>(
              builder: (context, state) {
                return _buildInfoRow(
                  context.tr('order_pages.payment_page.temporary_fee'),
                  state is OrderFeeCalculated
                      ? '${state.fee} VND'
                      : state is OrderFeeCalculating
                          ? context
                              .tr('order_pages.payment_page.fee_calculating')
                          : context.tr(
                              'order_pages.payment_page.fee_not_calculated'),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildToggleButton(
              title: context.tr('order_pages.payment_page.sender_pays'),
              isSelected: _senderWillPay,
              callBack: (bool value) {
                setState(() {
                  _senderWillPay = value;
                });
              },
              description: '',
            ),
            const SizedBox(height: 20),
            Text(context.tr(
                'order_pages.payment_page.voucher_selection')), // Thêm nhãn voucher
            _buildVoucherSelection(),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherSelection() {
    return GestureDetector(
      onTap: () async {
        try {
          final rs = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VoucherSelectionPage(),
            ),
          );
          setState(() {
            voucher = rs;
          });
          calculateFee();
        } catch (error) {
          print("Lỗi sau khi chọn voucher: ${error.toString()}");
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.local_offer, color: Colors.red),
              const SizedBox(width: 10),
              Text(
                voucher ??
                    context.tr("order_pages.payment_page.voucher_selection"),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmPage(BuildContext context) {
    return BlocListener<CreateOrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderCreated) {
          // Hiển thị dialog khi tạo đơn hàng thành công
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title:
                    Text(context.tr('order_pages.confirm_page.success_title')),
                content: Text(
                    context.tr('order_pages.confirm_page.success_message')),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Đóng dialog
                      // Có thể thêm navigation về trang chủ hoặc trang đơn hàng ở đây
                    },
                    child: Text(context.tr('common.close')),
                  ),
                ],
              );
            },
          );
        } else if (state is OrderCreateFaild) {
          // Hiển thị dialog khi tạo đơn hàng thất bại
          showDialog(
            context: context,
            barrierDismissible:
                false, // Không cho phép đóng dialog bằng cách chạm bên ngoài
            builder: (BuildContext context) {
              return AlertDialog(
                title:
                    Text(context.tr('order_pages.confirm_page.failure_title')),
                content: Text(
                    '${context.tr('order_pages.confirm_page.failure_message_prefix')}: ${state.error}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.tr('common.retry')),
                  ),
                ],
              );
            },
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Center(
                  child: Text(
                    context.tr("order_pages.confirm_page.page_title"),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildInfoCard(
                  context.tr('order_pages.confirm_page.sender_info'),
                  Icons.person_outline,
                  [
                    _buildInfoRow(
                        context.tr('order_pages.confirm_page.sender_name'),
                        toProper(_senderNameController.text)),
                    _buildInfoRow(
                        context.tr('order_pages.confirm_page.sender_address'),
                        _senderLocation.text),
                    _buildInfoRow(
                        context.tr('order_pages.confirm_page.sender_phone'),
                        _senderPhoneController.text),
                    _buildInfoRow(
                      context.tr('order_pages.confirm_page.sender_note'),
                      (_orderDescriptionController.text.isEmpty
                          ? context.tr('order_pages.confirm_page.no_note')
                          : _orderDescriptionController.text),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  context.tr('order_pages.confirm_page.receiver_info'),
                  Icons.person_pin_circle_outlined,
                  [
                    _buildInfoRow(
                        context.tr('order_pages.confirm_page.receiver_name'),
                        toProper(_receiverNameController.text)),
                    _buildInfoRow(
                        context.tr('order_pages.confirm_page.receiver_address'),
                        _receiverLocation.text),
                    _buildInfoRow(
                        context.tr('order_pages.confirm_page.receiver_phone'),
                        _receiverPhoneController.text),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  context.tr('order_pages.confirm_page.package_info'),
                  Icons.inventory_2_outlined,
                  [
                    _buildInfoRow(
                        context.tr('order_pages.confirm_page.cash_on_delivery'),
                        '${_cashOnDeliveryController.text == "" ? "0" : _cashOnDeliveryController.text} VNĐ'),
                    // _buildInfoRow('Kích thước',
                    //     '${_lengthController.text}x${_widthController.text}x${_heightController.text} cm'),
                    _buildInfoRow(
                        context.tr('order_pages.confirm_page.weight'),
                        _selectedWeightRange != -1
                            ? '${_selectedWeightRange * 5}-${(_selectedWeightRange + 1) * 5} kg'
                            : "> 40 kg"),
                    _buildInfoRow(
                        context.tr('order_pages.confirm_page.goods_type'),
                        _selectedGoodsType),
                    if (_isAGift) ...[
                      _buildInfoRow(
                          context.tr('order_pages.confirm_page.gift_order'),
                          giftTopics[_giftTopic]),
                      _buildInfoRow(
                          context.tr('order_pages.confirm_page.message'),
                          _giftMessageController.text),
                    ]
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  context.tr('order_pages.confirm_page.order_info'),
                  Icons.description_outlined,
                  [
                    _buildInfoRow(
                        context.tr('order_pages.confirm_page.delivery_method'),
                        _selectedDeliveryMethod),
                    _buildInfoRow(
                        context.tr('order_pages.confirm_page.payment_method'),
                        _selectedPaymentMethod),
                    _buildInfoRow(
                        context.tr('order_pages.confirm_page.bulky_order'),
                        _isBulky ? "Có" : "Không"),
                    _buildInfoRow(
                        context.tr('order_pages.confirm_page.description'),
                        (_noteController.text == ""
                            ? "Không có"
                            : _noteController.text)),
                  ],
                ),
                const SizedBox(height: 16),
                if (_isInsured)
                  _buildInfoCard(
                    context.tr('order_pages.confirm_page.insurance'),
                    Icons.perm_contact_calendar_outlined,
                    [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InsuranceDetailsPage(
                                noteController: _noteInSController,
                                images: _images,
                                isInvoiceEnabled: _isInvoiceEnabled,
                                companyNameController: _companyNameController,
                                addressController: _addressController,
                                taxCodeController: _taxCodeController,
                                emailController: _emailController,
                              ),
                            ),
                          );
                        },
                        child: Text(
                            context
                                .tr('order_pages.confirm_page.view_insurance'),
                            style: const TextStyle(
                                fontSize: 16, color: mainColor)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dòng thông báo với từ "điều khoản" nổi bật
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: context.tr('order_pages.confirm_page.terms_agreement'),
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: context
                          .tr('order_pages.confirm_page.terms_highlight'),
                      style: const TextStyle(
                        color: mainColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TermsAndConditionsPage()),
                          );
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              BlocBuilder<CreateOrderBloc, OrderState>(
                builder: (context, state) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: state is OrderCreating
                        ? null
                        : () => _showConfirmationDialog(context),
                    child: state is OrderCreating
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            context.tr(
                                'order_pages.confirm_page.create_order_button'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      color: const Color.fromARGB(255, 253, 225, 228),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: mainColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(
          width: 20,
        ),
        if (_currentPage > 0)
          ElevatedButton(
            onPressed: () {
              if (_currentPage == 1) {
                widget.toHome();
              } else {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor, // Thay đổi màu nền của nút
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Border radius
              ),
            ),
            child: Text(
              context.tr("order_pages.back"),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        if (_currentPage == 4)
          ElevatedButton.icon(
            onPressed: () {
              Share.share(createShareContent());
            },
            icon: const Icon(Icons.share, color: Colors.white),
            label: Text(
              context.tr("order_pages.share"),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor, // Thay đổi màu nền của nút
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 8), // Giảm padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Border radius
              ),
            ),
          ),
        if (_currentPage > 0 && _currentPage < 4)
          ElevatedButton(
            onPressed: () async {
              if (_currentPage == 1) {
                if (!_validateInputs()) return;
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else if (_currentPage == 2) {
                if (!_validateNumberInputs()) return;

                calculateFee();

                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor, // Thay đổi màu nền của nút
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Border radius
              ),
            ),
            child: isCalculating
                ? const CircularProgressIndicator()
                : Text(
                    context.tr("order_pages.continue"),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
        const SizedBox(
          width: 20,
        )
      ],
    );
  }

  void createOrderPopup(BuildContext context, bool isSuccess, String message) {
    // Đảm bảo dialog được gọi sau khi build hoàn tất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(isSuccess
                ? 'Tạo đơn hàng thành công'
                : 'Tạo đơn hàng thất bại!'),
            content: isSuccess
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          spreadRadius: 4,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      radius: 30,
                      child: const Icon(
                        Icons.done_outline_sharp,
                        color: Colors.green,
                        size: 30,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Text(message),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              spreadRadius: 4,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.red.shade100,
                          radius: 30,
                          child: const Icon(
                            Icons.do_not_disturb_outlined,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ), // Hiển thị thông báo lỗi nếu thất bại
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng popup
                },
                child: const Text('Đồng ý'),
              ),
            ],
          );
        },
      );
    });
  }
}
