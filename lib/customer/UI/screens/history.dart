import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tdlogistic_v2/core/models/order_model.dart';
import 'package:tdlogistic_v2/core/repositories/order_repository.dart';
import 'package:tdlogistic_v2/core/service/secure_storage_service.dart';
import 'package:tdlogistic_v2/customer/UI/screens/contact/chat_box.dart';
import 'package:tdlogistic_v2/customer/UI/screens/map2markers.dart';
import 'package:tdlogistic_v2/customer/UI/screens/map_widget.dart';
import 'package:tdlogistic_v2/customer/bloc/order_bloc.dart';
import 'package:tdlogistic_v2/customer/bloc/order_event.dart';
import 'package:tdlogistic_v2/customer/bloc/order_state.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class History extends StatefulWidget {
  final Function(String, String) sendMessage;
  const History({super.key, required this.sendMessage});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cần cấp quyền vị trí để sử dụng tính năng này')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      // Call API based on the selected tab index
      final status = _getOrderStatusByIndex(_tabController.index);
      // context.read<OrderBlocSearchCus>().add(FetchOrdersByStatus(status));
    }
  }

  String _getOrderStatusByIndex(int index) {
    switch (index) {
      case 0:
        return 'processing';
      case 1:
        return 'shipping';
      case 2:
        return 'delivering';
      case 3:
        return 'cancelled';
      case 4:
        return 'completed';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: mainColor,
        title: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(0),
                      child: Image.asset(
                        'lib/assets/logo.png',
                        height: 75,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
          tabs: [
            Tab(text: context.tr("history.processing")),
            Tab(text: context.tr("history.taking")),
            Tab(text: context.tr("history.delivering")),
            Tab(text: context.tr("history.completed")),
            Tab(text: context.tr("history.cancelled")),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: TabBarView(
        controller: _tabController,
        children: [
          ProcessingOrdersTab(
            sendMessage: widget.sendMessage,
          ),
          TakingOrdersTab(
            sendMessage: widget.sendMessage,
          ),
          DeliveringOrdersTab(
            sendMessage: widget.sendMessage,
          ),
          CompletedOrdersTab(
            sendMessage: widget.sendMessage,
          ),
          CancelledOrdersTab(
            sendMessage: widget.sendMessage,
          ),
        ],
      ),
    );
  }
}

class ProcessingOrdersTab extends StatefulWidget {
  final Function(String, String) sendMessage;
  const ProcessingOrdersTab({super.key, required this.sendMessage});

  @override
  State<ProcessingOrdersTab> createState() => _ProcessingOrdersTabState();
}

class _ProcessingOrdersTabState extends State<ProcessingOrdersTab> {
  List<Order> orders = [];

  int page = 1;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    context.read<ProcessingOrderBloc>().add(StartOrder());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProcessingOrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderLoaded) {
          setState(() {
            isLoadingMore = false;
            if (page == 1) {
              orders = state.orders;
            } else {
              orders.addAll(state.orders);
            }
          });
        }
      },
      child: Column(
        children: [
          Expanded(
            child: OrderListView(
              orders: orders,
              refreshFunc: () async {
                context.read<ProcessingOrderBloc>().add(StartOrder());
                page = 1;
              },
              loadMoreFunc: () async {
                if (!isLoadingMore) {
                  setState(() {
                    isLoadingMore = true;
                  });
                  page++;
                  context
                      .read<ProcessingOrderBloc>()
                      .add(AddOrder(const [], page));
                }
              },
              loading: isLoadingMore,
              sendMessage: widget.sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class TakingOrdersTab extends StatefulWidget {
  final Function(String, String) sendMessage;
  const TakingOrdersTab({super.key, required this.sendMessage});

  @override
  State<TakingOrdersTab> createState() => _TakingOrdersTabState();
}

class _TakingOrdersTabState extends State<TakingOrdersTab> {
  List<Order> orders = [];
  int page = 1;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    context.read<TakingOrderBloc>().add(StartOrder());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TakingOrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderLoaded) {
          setState(() {
            isLoadingMore = false;
            if (page == 1) {
              orders = state.orders;
            } else {
              orders.addAll(state.orders);
            }
          });
        }
      },
      child: Column(
        children: [
          Expanded(
            child: OrderListView(
              orders: orders,
              refreshFunc: () async {
                context.read<TakingOrderBloc>().add(StartOrder());

                page = 1;
              },
              loadMoreFunc: () async {
                if (!isLoadingMore) {
                  setState(() {
                    isLoadingMore = true;
                  });
                  page++;
                  context.read<TakingOrderBloc>().add(AddOrder(const [], page));
                }
              },
              loading: isLoadingMore,
              sendMessage: widget.sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class DeliveringOrdersTab extends StatefulWidget {
  final Function(String, String) sendMessage;
  const DeliveringOrdersTab({super.key, required this.sendMessage});

  @override
  State<DeliveringOrdersTab> createState() => _DeliveringOrdersTabState();
}

class _DeliveringOrdersTabState extends State<DeliveringOrdersTab> {
  List<Order> orders = [];
  int page = 1;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    context.read<DeliveringOrderBloc>().add(StartOrder());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeliveringOrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderLoaded) {
          setState(() {
            isLoadingMore = false;
            if (page == 1) {
              orders = state.orders;
            } else {
              orders.addAll(state.orders);
            }
          });
        }
      },
      child: Column(
        children: [
          Expanded(
            child: OrderListView(
              orders: orders,
              refreshFunc: () async {
                context.read<DeliveringOrderBloc>().add(StartOrder());

                page = 1;
              },
              loadMoreFunc: () async {
                if (!isLoadingMore) {
                  setState(() {
                    isLoadingMore = true;
                  });
                  page++;
                  context
                      .read<DeliveringOrderBloc>()
                      .add(AddOrder(const [], page));
                }
              },
              loading: isLoadingMore,
              sendMessage: widget.sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class CancelledOrdersTab extends StatefulWidget {
  final Function(String, String) sendMessage;
  const CancelledOrdersTab({super.key, required this.sendMessage});

  @override
  State<CancelledOrdersTab> createState() => _CancelledOrdersTabState();
}

class _CancelledOrdersTabState extends State<CancelledOrdersTab> {
  List<Order> orders = [];
  int page = 1;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    context.read<CancelledOrderBloc>().add(StartOrder());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CancelledOrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderLoaded) {
          setState(() {
            isLoadingMore = false;
            if (page == 1) {
              orders = state.orders;
            } else {
              orders.addAll(state.orders);
            }
          });
        }
      },
      child: Column(
        children: [
          Expanded(
            child: OrderListView(
              orders: orders,
              refreshFunc: () async {
                context.read<CancelledOrderBloc>().add(StartOrder());

                page = 1;
              },
              loadMoreFunc: () async {
                if (!isLoadingMore) {
                  setState(() {
                    isLoadingMore = true;
                  });
                  page++;
                  context
                      .read<CancelledOrderBloc>()
                      .add(AddOrder(const [], page));
                }
              },
              loading: isLoadingMore,
              sendMessage: widget.sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class CompletedOrdersTab extends StatefulWidget {
  final Function(String, String) sendMessage;
  const CompletedOrdersTab({super.key, required this.sendMessage});

  @override
  State<CompletedOrdersTab> createState() => _CompletedOrdersTabState();
}

class _CompletedOrdersTabState extends State<CompletedOrdersTab> {
  List<Order> orders = [];
  int page = 1;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    context.read<CompletedOrderBloc>().add(StartOrder());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompletedOrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderLoaded) {
          setState(() {
            isLoadingMore = false;
            if (page == 1) {
              orders = state.orders;
            } else {
              orders.addAll(state.orders);
            }
          });
        }
      },
      child: Column(
        children: [
          Expanded(
            child: OrderListView(
              orders: orders,
              refreshFunc: () async {
                context.read<CompletedOrderBloc>().add(StartOrder());

                page = 1;
              },
              loadMoreFunc: () async {
                if (!isLoadingMore) {
                  setState(() {
                    isLoadingMore = true;
                  });
                  page++;
                  context
                      .read<CompletedOrderBloc>()
                      .add(AddOrder(const [], page));
                }
              },
              loading: isLoadingMore,
              sendMessage: widget.sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderListView extends StatefulWidget {
  final List<Order> orders;
  final Future<void> Function() refreshFunc;
  final Future<void> Function() loadMoreFunc;
  final Function(String, String) sendMessage;
  final bool loading;

  const OrderListView({
    super.key,
    required this.orders,
    required this.refreshFunc,
    required this.loadMoreFunc,
    required this.loading,
    required this.sendMessage,
  });

  @override
  State<OrderListView> createState() => _OrderListViewState();
}

class _OrderListViewState extends State<OrderListView> {
  var secureStorageService = SecureStorageService();
  Position? _currentPosition;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.refreshFunc,
      child: widget.orders.isEmpty
          ? Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Image(
                      image: AssetImage("lib/assets/hoptrong.png"),
                    ),
                    Text(
                      context.tr("history.noOrder"),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 250),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: widget.orders.length + 1,
              itemBuilder: (context, index) {
                if (index == widget.orders.length) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: widget.loading
                          ? null
                          : () {
                              widget.loadMoreFunc();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            widget.loading ? Colors.grey : mainColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: widget.loading
                          ? Text(
                              context.tr("history.loading"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Text(
                              context.tr("history.loadMore"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                } else {
                  final order = widget.orders[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.withOpacity(0.1),
                      child:
                          const Icon(Icons.local_shipping, color: Colors.green),
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
                      context
                          .read<GetImagesBloc>()
                          .add(GetOrderImages(order.id!));
                    },
                  );
                }
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

  String _getLabelText() {
    // switch (selectedFilter) {
    //   case 'name':
    //     return 'Tìm kiếm theo tên người nhận';
    //   case 'location':
    //     return 'Tìm kiếm theo địa điểm người nhận';
    //   case 'phone':
    //     return 'Tìm kiếm theo số điện thoại người nhận';
    //   default:
    //     return 'Tìm kiếm';
    // }
    return "";
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
                  sendAddress: '${order.detailSource ?? ''}, ${order.wardSource ?? ''}, ${order.districtSource ?? ''}, ${order.provinceSource ?? ''}',
                  receiveAddress: '${order.detailDest ?? ''}, ${order.wardDest ?? ''}, ${order.districtDest ?? ''}, ${order.provinceDest ?? ''}',
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
                  sendAddress: '${order.detailSource ?? ''}, ${order.wardSource ?? ''}, ${order.districtSource ?? ''}, ${order.provinceSource ?? ''}',
                  receiveAddress: '${order.detailDest ?? ''}, ${order.wardDest ?? ''}, ${order.districtDest ?? ''}, ${order.provinceDest ?? ''}',
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

  Future<void> _openGoogleMaps(String startAddress, String destinationAddress) async {
    // URL scheme để mở Google Maps
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${Uri.encodeComponent(startAddress)}'
      '&destination=${Uri.encodeComponent(destinationAddress)}'
      '&travelmode=driving'
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở Google Maps')),
      );
    }
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
