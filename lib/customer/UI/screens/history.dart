import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/core/models/order_model.dart';
import 'package:tdlogistic_v2/core/repositories/order_repository.dart';
import 'package:tdlogistic_v2/core/service/secure_storage_service.dart';
import 'package:tdlogistic_v2/customer/UI/screens/contact/chat_box.dart';
import 'package:tdlogistic_v2/customer/UI/screens/map_widget.dart';
import 'package:tdlogistic_v2/customer/bloc/order_bloc.dart';
import 'package:tdlogistic_v2/customer/bloc/order_event.dart';
import 'package:tdlogistic_v2/customer/bloc/order_state.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryPage extends StatefulWidget {
  final Function(String, String) sendMessage;
  final Function() onCreateOrder;

  const HistoryPage({
    super.key,
    required this.sendMessage,
    required this.onCreateOrder,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // --- Quản lý trạng thái cho UI ---
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Trạng thái bộ lọc
  String? _selectedStatus;
  String _searchQuery = '';
  int page = 1;
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedDateFilterLabel = 'Tất cả thời gian';

  // Services & Data
  final OrderRepository orderRepository = OrderRepository();
  final SecureStorageService secureStorageService = SecureStorageService();
  List<Order> _orders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _fetchOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (!status.isGranted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cần cấp quyền vị trí để sử dụng tính năng này')),
      );
    }
  }

  // --- Hàm gọi dữ liệu đã được hoàn thiện ---
  Future<void> _fetchOrders() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    // Logic phỏng đoán tìm kiếm
    String? searchPhone, searchName, searchTracking;
    if (_searchQuery.isNotEmpty) {
      final isPhoneNumber = RegExp(r'^[0-9]{9,11}$').hasMatch(_searchQuery);
      final isTrackingCode =
          RegExp(r'^[A-Z_a-z]+[0-9]+$').hasMatch(_searchQuery);
      if (isPhoneNumber)
        searchPhone = _searchQuery;
      else if (isTrackingCode)
        searchTracking = _searchQuery;
      else
        searchName = _searchQuery;
    }

    try {
      final token = await secureStorageService.getToken();
      final customerId = await secureStorageService.getStaffId();
      final status = _selectedStatus == null
          ? ""
          : (_selectedStatus == "cancelled"
              ? "CANCEL"
              : _selectedStatus?.toUpperCase());

      final response = await orderRepository.getOrders(
        token!,
        customerId!,
        page: page,
        status: status ?? "",
        phone: searchPhone,
        name: searchName,
        tracking: searchTracking,
        startDate: _startDate?.toString(), // <-- THAM SỐ MỚI
        endDate: _endDate?.toString(),     // <-- THAM SỐ MỚI
      );

      if (mounted && response["success"] == true) {
        final List<dynamic> rawOrders = response["data"] as List;
        final List<Order> fetchedOrders =
            rawOrders.map((orderData) => Order.fromJson(orderData)).toList();
        setState(() => _orders = fetchedOrders);
      } else {
        print("API Error: ${response['message']}");
      }
    } catch (error) {
      print("Lỗi fetch order: " + error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _searchQuery = query);
      _fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr("history.title"),
            style: const TextStyle(color: Colors.white)),
        backgroundColor: mainColor,
        actions: [
          Tooltip(
            message: context.tr("history.createOrder"),
            child: IconButton(
              icon: const Icon(Icons.add_circle_outline,
                  color: Colors.white, size: 28),
              onPressed: () => widget.onCreateOrder(),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildFilterAndSearchControls(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildOrderList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSearchControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm đơn hàng...',
              prefixIcon: const Icon(Icons.search), // Bỏ PopupMenuButton
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today_outlined),
                onPressed: _showDateFilterOptions,
                tooltip: "Lọc theo thời gian",
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 12),
          _buildActiveDateFilter(),
          const SizedBox(height: 8),
          _buildStatusFilterChips(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildActiveDateFilter() {
    if (_startDate == null && _endDate == null) return const SizedBox.shrink();
    return Chip(
      label: Text(_selectedDateFilterLabel,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: secondColor,
      deleteIcon: const Icon(Icons.close, size: 18, color: Colors.white),
      onDeleted: () {
        setState(() {
          _startDate = null;
          _endDate = null;
          _selectedDateFilterLabel = 'Tất cả thời gian';
        });
        _fetchOrders();
      },
    );
  }

  Widget _buildStatusFilterChips() {
    final statuses = {
      null: context.tr("history.all"),
      'processing': context.tr("history.processing"),
      'taking': context.tr("history.taking"),
      'delivering': context.tr("history.delivering"),
      'received': context.tr("history.completed"),
      'cancelled': context.tr("history.cancelled"),
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: _selectedStatus == entry.key,
              onSelected: (selected) {
                setState(() => _selectedStatus = entry.key);
                _fetchOrders();
              },
              backgroundColor: Colors.grey[200],
              selectedColor: mainColor.withOpacity(0.1),
              labelStyle: TextStyle(
                color:
                    _selectedStatus == entry.key ? mainColor : Colors.black,
              ),
              shape: StadiumBorder(
                  side: BorderSide(
                      color: _selectedStatus == entry.key
                          ? mainColor.withOpacity(0.1)
                          : Colors.grey.shade300)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderList() {
    if (_orders.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("lib/assets/hoptrong.png", width: 150),
            const SizedBox(height: 16),
            Text(context.tr("history.noOrder"),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withOpacity(0.1),
                  child: const Icon(Icons.local_shipping, color: Colors.green),
                ),
                title: Text(
                  order.trackingNumber ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                subtitle: _buildOrderDetails(order),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                tileColor: Colors.white,
                onTap: () {
                  _showOrderDetailsBottomSheet(context, order);
                  context.read<GetImagesBloc>().add(GetOrderImages(order.id!));
                },
              ),
              SizedBox(height: 5),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderDetails(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4.0),
        Row(
          children: [
            const Icon(Icons.person, size: 16.0, color: Colors.grey),
            const SizedBox(width: 4.0),
            Text(
                '${context.tr("history.recevier")}: ${order.nameReceiver ?? ''}'),
          ],
        ),
        const SizedBox(height: 4.0),
        Row(
          children: [
            const Icon(Icons.phone, size: 16.0, color: Colors.grey),
            const SizedBox(width: 4.0),
            Text(
                '${context.tr("history.phone")}: ${order.phoneNumberReceiver ?? ''}'),
          ],
        ),
        const SizedBox(height: 4.0),
        Row(
          children: [
            const Icon(Icons.location_on, size: 16.0, color: Colors.grey),
            const SizedBox(width: 4.0),
            Expanded(
              child: Text(
                '${context.tr("history.address")}: ${order.detailDest ?? ''}, ${order.districtDest ?? ''}, ${order.provinceDest ?? ''}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDateFilterOptions() {
    // Code hiển thị bottom sheet để chọn ngày (không đổi)
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: <Widget>[
            _buildDateFilterTile('Hôm nay', _applyDateFilterForToday),
            _buildDateFilterTile('Hôm qua', _applyDateFilterForYesterday),
            _buildDateFilterTile(
                '3 ngày qua', () => _applyDateFilterForLastDays(3)),
            _buildDateFilterTile(
                '7 ngày qua', () => _applyDateFilterForLastDays(7)),
            _buildDateFilterTile(
                '1 tháng qua', () => _applyDateFilterForLastMonths(1)),
            _buildDateFilterTile(
                '1 năm qua', () => _applyDateFilterForLastYears(1)),
            _buildDateFilterTile(
                '3 năm qua', () => _applyDateFilterForLastYears(3)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.date_range_outlined),
              title: const Text('Chọn khoảng thời gian...'),
              onTap: _pickDateRange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateFilterTile(String title, VoidCallback onTap) {
    // Code không đổi
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _applyDateFilter(String label, DateTime start, DateTime end) {
    // Code không đổi
    setState(() {
      _selectedDateFilterLabel = label;
      _startDate = DateTime(start.year, start.month, start.day);
      _endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);
    });
    _fetchOrders();
  }

  // Các hàm logic ngày tháng không đổi
  void _applyDateFilterForToday() {
    final now = DateTime.now();
    _applyDateFilter('Hôm nay', now, now);
  }

  void _applyDateFilterForYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    _applyDateFilter('Hôm qua', yesterday, yesterday);
  }

  void _applyDateFilterForLastDays(int days) {
    final now = DateTime.now();
    _applyDateFilter(
        '$days ngày qua', now.subtract(Duration(days: days - 1)), now);
  }

  void _applyDateFilterForLastMonths(int months) {
    final now = DateTime.now();
    _applyDateFilter('$months tháng qua',
        DateTime(now.year, now.month - months, now.day), now);
  }

  void _applyDateFilterForLastYears(int years) {
    final now = DateTime.now();
    _applyDateFilter(
        '$years năm qua', DateTime(now.year - years, now.month, now.day), now);
  }

  Future<void> _pickDateRange() async {
    if (Navigator.canPop(context)) Navigator.pop(context);
    DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        locale: context.locale);
    if (picked != null) {
      final label =
          '${DateFormat.yMd().format(picked.start)} - ${DateFormat.yMd().format(picked.end)}';
      _applyDateFilter(label, picked.start, picked.end);
    }
  }

  void _showOrderDetailsBottomSheet(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20.0)), // Bo góc trên
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context)
                .viewInsets
                .bottom, // Tránh che UI khi bàn phím bật
          ),
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thanh kéo để đóng
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Tiêu đề
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${context.tr("history.orderDetail")} ${order.trackingNumber ?? ''}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: mainColor, // Dùng màu chủ đạo của app
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),

                // Chi tiết đơn hàng
                _buildOrderDetailTile(context.tr("history.sender"),
                    order.nameSender, Icons.person),
                _buildOrderDetailTile(context.tr("history.senderPhone"),
                    order.phoneNumberSender, Icons.phone),
                _buildOrderDetailTile(
                  context.tr("history.senderAddress"),
                  '${order.provinceSource ?? ''}, ${order.districtSource ?? ''}, ${order.wardSource ?? ''}, ${order.detailSource ?? ''}',
                  sendAddress:
                      '${order.detailSource ?? ''}, ${order.wardSource ?? ''}, ${order.districtSource ?? ''}, ${order.provinceSource ?? ''}',
                  receiveAddress:
                      '${order.detailDest ?? ''}, ${order.wardDest ?? ''}, ${order.districtDest ?? ''}, ${order.provinceDest ?? ''}',
                  Icons.location_on,
                ),
                const Divider(),
                _buildOrderDetailTile(context.tr("history.recevier"),
                    order.nameReceiver, Icons.person),
                _buildOrderDetailTile(context.tr("history.receiverPhone"),
                    order.phoneNumberReceiver, Icons.phone),
                _buildOrderDetailTile(
                  context.tr("history.receiverAddress"),
                  '${order.provinceDest ?? ''}, ${order.districtDest ?? ''}, ${order.wardDest ?? ''}, ${order.detailDest ?? ''}',
                  sendAddress:
                      '${order.detailSource ?? ''}, ${order.wardSource ?? ''}, ${order.districtSource ?? ''}, ${order.provinceSource ?? ''}',
                  receiveAddress:
                      '${order.detailDest ?? ''}, ${order.wardDest ?? ''}, ${order.districtDest ?? ''}, ${order.provinceDest ?? ''}',
                  Icons.location_on,
                ),
                const Divider(),
                _buildOrderDetailTile(
                    context.tr("history.weight"),
                    '${order.mass?.toStringAsFixed(2) ?? '0'} kg',
                    Icons.line_weight),
                _buildOrderDetailTile(
                    context.tr("history.fee"),
                    '${order.fee?.toStringAsFixed(0) ?? '0'} VNĐ',
                    Icons.attach_money),
                _buildOrderDetailTile(
                  context.tr("history.paymentStatus"),
                  order.paid!
                      ? context.tr("history.paid")
                      : context.tr("history.notPaid"),
                  Icons.info,
                ),
                const Divider(),

                // Hành trình đơn hàng
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr("history.orderJourney"),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: secondColor, // Màu nhấn nhẹ nhàng hơn
                        ),
                      ),
                      if (order.statusCode != "PROCESSING" &&
                          order.statusCode != "TAKING")
                        TextButton(
                          child:
                              const Text("Xem", style: TextStyle(fontSize: 16)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TaskRouteWidget(orderId: order.id!)),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                if (order.journies != null) _buildJourneyList(order.journies!),
                _buildImageSignatureSection(order),

                // Nút thao tác
                if (order.statusCode != "RECEIVED")
                  _buildCancelSubmitButton(order),

                _buildChatShareRow(context, order),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSignatureSection(Order order) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              context.tr("history.images&signature"),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 8), // Khoảng cách giữa tiêu đề và nội dung
          BlocBuilder<GetImagesBloc, OrderState>(
            builder: (context, state) {
              if (state is GettingImages) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is GotImages) {
                final sendImages = state.sendImages;
                final receiveImages = state.receiveImages;
                final sendSignature = state.sendSignature;
                final receiveSignature = state.receiveSignature;

                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hiển thị hình gửi
                      _buildImageGrid(
                          context.tr("history.sendImage"), sendImages),

                      const SizedBox(height: 16), // Khoảng cách giữa các phần

                      // Hiển thị hình nhận
                      _buildImageGrid(
                          context.tr("history.receiveImage"), receiveImages),

                      const SizedBox(height: 16), // Khoảng cách giữa các phần

                      // Hiển thị chữ ký
                      _buildSignatureSection(
                          context.tr("history.sendSignature"), sendSignature),
                      const SizedBox(height: 8),
                      _buildSignatureSection(
                          context.tr("history.receiveSignature"),
                          receiveSignature),
                    ],
                  ),
                );
              } else if (state is FailedImage) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Lỗi khi lấy hình: ${state.error}",
                    style: const TextStyle(color: mainColor),
                  ),
                );
              }
              return const Text('Không tìm thấy ảnh hoặc chữ ký.');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(String title, List<Uint8List> images) {
    if (images.isEmpty) {
      return Text('$title: ${context.tr("history.noImages")}');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: images.isNotEmpty ? 100 : 20,
          child: images.isNotEmpty
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImage(
                              image: images[index],
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            images[index],
                            fit: BoxFit.fitWidth,
                            width: 200,
                            height: 200,
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Text(context.tr("history.noImages")),
        ),
      ],
    );
  }

  Widget _buildSignatureSection(String title, Uint8List? signature) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        signature != null
            ? GestureDetector(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImage(
                        image: signature,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    signature,
                    height: 100,
                    fit: BoxFit.contain, // Đảm bảo chữ ký không bị cắt
                  ),
                ),
              )
            : Text(context.tr("history.noSignature")),
      ],
    );
  }

  Widget _buildOrderDetailTile(String title, String? value, IconData icon,
      {String sendAddress = "", String receiveAddress = ""}) {
    return icon == Icons.location_on
        ? InkWell(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => Map2Markers(
              //       startAddress: sendAddress,
              //       endAddress: receiveAddress,
              //     ),
              //   ),
              // );
              _openGoogleMaps(sendAddress, receiveAddress);
              print(sendAddress);
              print(receiveAddress);
            },
            child: ListTile(
              leading: Icon(icon, color: Colors.green),
              title: Text(
                "$title (${context.tr("history.clickMe")})",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(value ?? 'Chưa có thông tin'),
            ))
        : ListTile(
            leading: Icon(icon,
                color: (value == "Chưa thanh toán" || value == "Not Paid"
                    ? Colors.red
                    : Colors.green)),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(value ?? 'Chưa có thông tin'),
          );
  }

  Widget _buildJourneyList(List<Journies> journeys) {
    if (journeys.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('Chưa có hành trình nào.'),
      );
    }

    return ListView.builder(
      shrinkWrap: true, // Để ListView nằm gọn trong Modal
      physics:
          const NeverScrollableScrollPhysics(), // Tắt cuộn riêng cho ListView này
      itemCount: journeys.length,
      itemBuilder: (context, index) {
        final journey = journeys[index];
        return _buildJourneyTile(
            journey.message!, DateTime.tryParse(journey.time!));
      },
    );
  }

  Widget _buildJourneyTile(String message, DateTime? timestamp) {
    return ListTile(
      leading: const Icon(Icons.circle, color: Colors.green, size: 15),
      title: Text(message),
      subtitle: Text(
        timestamp != null
            ? '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}'
            : 'Không rõ thời gian',
      ),
    );
  }

  Widget _buildCancelSubmitButton(Order order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      child: Row(
        children: [
          // Nút "Từ chối"
          Expanded(
            child: ElevatedButton(
              onPressed: (order.statusCode == "PROCESSING" ||
                      order.statusCode == "TAKING")
                  ? () {
                      _showCancellationDialog(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Từ chối",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nút "Đã nhận"
          Expanded(
            child: ElevatedButton(
              onPressed: (order.statusCode == "DELIVERING")
                  ? () {
                      _showRatingDialog(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade100,
                foregroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Đã nhận",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatShareRow(BuildContext context, Order order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      child: Row(
        children: [
          // Nút Chat
          Expanded(
            child: ElevatedButton.icon(
              onPressed: (order.statusCode != "PROCESSING")
                  ? () async {
                      try {
                        OrderRepository orderRepository = OrderRepository();
                        final data = (await orderRepository.getShipperOrders(
                            (await secureStorageService.getToken())!,
                            order.id!))["data"];
                        if (data == null) return;

                        final theirName = data["fullname"];
                        final theirPhone = data["phoneNumber"];
                        final receiverId = data["id"];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              theirName: theirName,
                              theirPhone: theirPhone,
                              receiverId: receiverId,
                              sendMessage: widget.sendMessage,
                            ),
                          ),
                        );
                      } catch (error) {
                        print(error.toString());
                      }
                    }
                  : null,
              icon: const Icon(Icons.chat, color: Colors.white),
              label: Text(context.tr("history.chatWithShipper")),
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nút Chia sẻ
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Share.share("abcde"),
              icon: const Icon(Icons.share, color: Colors.blue),
              label: const Text("Chia sẻ"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade100,
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancellationDialog(BuildContext context) {
    String? selectedReason;
    TextEditingController otherReasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Lý Do Hủy Đơn Hàng',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Không còn nhu cầu'),
                    leading: Radio<String>(
                      value: 'Không còn nhu cầu',
                      groupValue: selectedReason,
                      onChanged: (value) {
                        setState(() {
                          selectedReason = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Sản phẩm không đúng mô tả'),
                    leading: Radio<String>(
                      value: 'Sản phẩm không đúng mô tả',
                      groupValue: selectedReason,
                      onChanged: (value) {
                        setState(() {
                          selectedReason = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Khác'),
                    leading: Radio<String>(
                      value: 'Khác',
                      groupValue: selectedReason,
                      onChanged: (value) {
                        setState(() {
                          selectedReason = value;
                        });
                      },
                    ),
                  ),
                  if (selectedReason == 'Khác')
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextField(
                        controller: otherReasonController,
                        decoration: InputDecoration(
                          hintText: 'Nhập lý do khác',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              child: const Text(
                'Gửi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRatingDialog(BuildContext context) {
    double rating = 0.0;
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đánh Giá Đơn Hàng'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Phần để chọn rating
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.yellow,
                          size: 40,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  // Phần để nhập bình luận
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập bình luận của bạn',
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Gửi'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openGoogleMaps(
      String startAddress, String destinationAddress) async {
    // URL scheme để mở Google Maps
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1'
        '&origin=${Uri.encodeComponent(startAddress)}'
        '&destination=${Uri.encodeComponent(destinationAddress)}'
        '&travelmode=driving');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở Google Maps')),
      );
    }
  }
}

// --- TÁI CẤU TRÚC: TÁCH ITEM RA WIDGET RIÊNG ---
class OrderListItem extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderListItem({super.key, required this.order, required this.onTap});

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'processing':
        return Colors.blue;
      case 'taking':
        return Colors.orange;
      case 'delivering':
        return Colors.deepPurple;
      case 'received':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'processing':
        return Icons.pending_actions;
      case 'taking':
        return Icons.inventory_2_outlined;
      case 'delivering':
        return Icons.local_shipping_outlined;
      case 'received':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor:
                _getStatusColor(order.statusCode).withOpacity(0.15),
            child: Icon(_getStatusIcon(order.statusCode),
                color: _getStatusColor(order.statusCode)),
          ),
          title: Text(order.trackingNumber ?? 'N/A',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                    Icons.person_outline, "Gửi:", order.nameSender ?? ''),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.person, "Nhận:", order.nameReceiver ?? ''),
                const SizedBox(height: 4),
                _buildInfoRow(
                    Icons.calendar_month_outlined,
                    "Ngày tạo:",
                    order.createdAt != null
                        ? DateFormat('dd/MM/yyyy HH:mm')
                            .format(DateTime.parse(order.createdAt!))
                        : 'N/A'),
              ],
            ),
          ),
          isThreeLine: true,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16.0, color: Colors.grey.shade600),
        const SizedBox(width: 8.0),
        Text(label,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
        const SizedBox(width: 4.0),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final Uint8List image;

  FullScreenImage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Nền đen để làm nổi bật ảnh

      appBar: AppBar(
        backgroundColor: Colors.transparent, // Thanh app trong suốt

        elevation: 0, // Chưa có bóng đổ

        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 40),
          onPressed: () {
            Navigator.of(context).pop(); // Đóng màn hình khi nhấn nút X
          },
        ),
      ),

      body: Center(
        child: InteractiveViewer(
          child: Image.memory(image), // Hiển thị ảnh toàn màn hình
        ),
      ),
    );
  }
}
