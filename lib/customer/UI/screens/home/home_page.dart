import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tdlogistic_v2/auth/data/models/user_model.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/core/models/order_model.dart';
import 'package:tdlogistic_v2/core/repositories/order_repository.dart';
import 'package:tdlogistic_v2/core/service/secure_storage_service.dart';
import 'package:tdlogistic_v2/customer/UI/screens/contact/chats_screen.dart';
import 'package:tdlogistic_v2/customer/UI/screens/create%20order/all_locations.dart';
import 'package:tdlogistic_v2/customer/UI/screens/create%20order/create_order.dart';
import 'package:tdlogistic_v2/customer/UI/screens/customer_info/info_display_page.dart';
import 'package:tdlogistic_v2/customer/UI/screens/history.dart';
import 'package:tdlogistic_v2/customer/UI/screens/home/fee_calculating.dart';
import 'package:tdlogistic_v2/customer/UI/screens/map_widget.dart';
import 'package:tdlogistic_v2/customer/bloc/order_bloc.dart';
import 'package:tdlogistic_v2/customer/bloc/order_state.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final User user;
  final Function(int) toFeature;
  final Function(int) toTab;
  final Function(String, String) sendMessage;
  const HomePage(
      {super.key,
      required this.user,
      required this.toFeature,
      required this.toTab,
      required this.sendMessage});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _senderController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final orderRepository = OrderRepository();
  final secureStorageService = SecureStorageService();

  double _logoHeight = 75.0;
  double _logoOpacity = 1.0;
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    print(widget.user.toJson());

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scrollController.addListener(_onScroll);

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _senderController.dispose();
    _receiverController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final double offset = _scrollController.offset;
    const double scrollThreshold = 500.0;

    final double progress = (offset / scrollThreshold).clamp(0.0, 1.0);

    setState(() {
      _logoHeight = 75.0 * (1.0 - progress);
      _logoOpacity = 1.0 - progress;
    });
  }

  void _navigateToCreateOrder() {
    widget.toFeature(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  _buildAnimatedHeader(),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              _buildEnhancedSearchSection(),
                              const SizedBox(height: 25),
                              _buildEnhancedSenderReceiverSection(),
                              const SizedBox(height: 25),
                              _buildEnhancedFeaturesSection(),
                              const SizedBox(height: 25),
                              _buildEnhancedNewsSection(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          _buildFloatingActionButtons(),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0, right: 16.0),
        child: Align(
          alignment: Alignment.topRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFloatingButton(
                icon: Icons.language,
                onPressed: () {
                  _showLanguageDialog(context);
                },
              ),
              const SizedBox(width: 10),
              _buildFloatingButton(
                icon: Icons.chat_bubble_outline,
                onPressed: () {
                  print("Chat button pressed!");

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatListScreen(
                              sendMessage: widget.sendMessage,
                            )),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9), // Nền trắng hơi mờ
        shape: BoxShape.circle, // Hình tròn
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: mainColor, size: 24),
        onPressed: onPressed,
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(context.tr('home.changeLanguage')),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Tiếng Việt'),
                onTap: () {
                  context.setLocale(const Locale('vi', ''));
                },
                leading: Image.asset('lib/assets/feature1.png',
                    width: 30, height: 20, fit: BoxFit.cover),
              ),
              ListTile(
                title: const Text('English'),
                onTap: () {
                  context.setLocale(const Locale('en', ''));
                  Navigator.pop(dialogContext);
                },
                leading: Image.asset('lib/assets/feature1.png',
                    width: 30, height: 20, fit: BoxFit.cover),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedHeader() {
    // print(180.0 - (_scrollController.hasClients ? _scrollController.offset * 0.3 : 0).clamp(0.0, 50.0));
    // print(70.0 - (_scrollController.hasClients ? _scrollController.offset * 0.3 : 0).clamp(0.0, 50.0));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 180.0 -
          (_scrollController.hasClients ? _scrollController.offset * 0.3 : 0)
              .clamp(0.0, 180.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(150),
          bottomRight: Radius.circular(150),
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(
              top: 70.0 -
                  (_scrollController.hasClients
                          ? _scrollController.offset * 0.3
                          : 0)
                      .clamp(0.0, 50.0),
              left: 20,
              right: 20,
              bottom: 10),
          child: Opacity(
            opacity: _logoOpacity,
            child: Container(
              child: Image.asset(
                'lib/assets/logo.png',
                height: _logoHeight,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.track_changes,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                context.tr('home.trackOrder'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: _isSearchFocused
                      ? mainColor.withOpacity(0.3)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: _isSearchFocused ? 15 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Focus(
              onFocusChange: (hasFocus) {
                setState(() => _isSearchFocused = hasFocus);
              },
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: context.tr('home.enterOrderCode'),
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: _performOrderSearch,
                    ),
                  ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _performOrderSearch(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performOrderSearch() async {
    if (_searchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('home.enterOrderCodeWarning')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final token = await secureStorageService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final order = await orderRepository.getOrderByTrackingNumber(
        _searchController.text.trim(),
        token,
      );

      if (!mounted) return;
      print(order["data"][0]);

      _showOrderDetailsBottomSheet(context, Order.fromJson(order["data"][0]));

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => OrderDetailScreen(order: order),
      //   ),
      // );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().contains('404')
              ? context.tr('home.orderNotFound')
              : context.tr('home.searchError') + e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSearchFocused = false);
    }
  }

  Widget _buildEnhancedSenderReceiverSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_shipping,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                context.tr('home.shipmentInfo'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: _navigateToCreateOrder,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.person_outline,
                    context.tr('home.senderInfo'),
                    _senderController.text.isEmpty,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(
                            Icons.arrow_downward,
                            color: mainColor,
                            size: 20,
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                  ),
                  _buildInfoRow(
                    Icons.person,
                    context.tr('home.receiverInfo'),
                    _receiverController.text.isEmpty,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: secondColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: secondColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_box,
                          color: secondColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.tr('home.createOrder'),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 69, 125, 26),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isEmpty) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: mainColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: mainColor, size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isEmpty ? Colors.grey.shade600 : Colors.black87,
              fontSize: 16,
              fontWeight: isEmpty ? FontWeight.normal : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedFeaturesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.apps,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                context.tr('home.features'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 0.9,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            children: List.generate(6, (index) {
              List<String> featureIcons = [
                'lib/assets/feature1.png',
                'lib/assets/feature1.png',
                'lib/assets/feature1.png',
                'lib/assets/feature1.png',
                'lib/assets/feature1.png',
                'lib/assets/feature1.png',
              ];

              List<String> featureNames = [
                context.tr('home.feature1'),
                context.tr('home.feature2'),
                context.tr('home.feature3'),
                context.tr('home.feature4'),
                context.tr('home.feature5'),
                context.tr('home.feature6'),
              ];

              return _buildFeatureCard(
                  index, featureIcons[index], featureNames[index]);
            }),
          ),
        ],
      ),
    );
  }

  void toFeature(int feature) {
    print("feature: " + feature.toString());
    if (feature == 1) {
      _navigateToCreateOrder();
    } else if (feature == 2) {
      widget.toTab(1);
    } else if (feature == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AllLocationsPage(),
        ),
      );
    } else if (feature == 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chức năng hoàn cước sắp ra mắt!')),
      );
    } else if (feature == 5) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const InfoDisplayPage(
                    title: 'Hỗ trợ khách hàng',
                    content:
                        'Thông tin liên hệ hỗ trợ: \n\n- Hotline: 1900 xxxx\n- Email: support@tdlogistic.vn\n- Địa chỉ: ...',
                  )));
    } else if (feature == 6) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FeeCalculationPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chức năng này sắp ra mắt!')),
      );
    }
  }

  Widget _buildFeatureCard(int index, String iconPath, String featureName) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Dựa trên kích thước màn hình
    final double padding = screenWidth * 0.04; // ~16 với màn 400px
    final double iconSize = screenWidth * 0.08; // ~32
    final double fontSize = screenWidth * 0.03; // ~12

    return GestureDetector(
      onTap: () => {toFeature(index + 1)},
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200 + (index * 50)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => toFeature(index + 1),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(padding / 1.5),
                    decoration: BoxDecoration(
                      color: mainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Image.asset(
                      iconPath,
                      width: iconSize,
                      height: iconSize,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.business_center,
                          size: iconSize,
                          color: mainColor,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: padding / 2),
                  Expanded(
                    child: Text(
                      featureName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Icon(
                Icons.newspaper,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                context.tr("home.news"),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        ListView.builder(
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: _buildEnhancedNewsCard(index),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEnhancedNewsCard(int index) {
    List<String> titles = [
      "Ông Nguyễn Thanh Nam có đơn xin từ nhiệm vị trí Chủ tịch Hội đồng quản trị Viettel Post với lý do cá nhân.",
      "Cổ phiếu Viettel Post tăng kịch trần trong phiên chào sàn HOSE",
      "Cổ phiếu VTP (Viettel Post) tăng kịch biên độ trong phiên chào sàn HoSE",
      "Cổ phiếu 'họ Viettel' tăng mạnh trước thềm Viettel Post (VTP) chuyển sàn sang HoSE",
    ];

    List<String> des = [
      "Ngày 17/8 vừa qua, ông Nguyễn Thanh Nam, Chủ tịch Hội đồng quản trị Tổng Công ty cổ phần Bưu chính Viettel (Viettel Post, mã VTP) đã có đơn xin từ nhiệm.",
      "Ngày 12/3/2024, Sở Giao dịch Chứng khoán TP. Hồ Chí Minh tổ chức Lễ trao quyết định niêm yết cho Tổng Công ty Cổ phần Bưu chính Viettel - Viettel Post (Mã chứng khoán: VTP) và đưa vào giao dịch chính thức 121.783.042 cổ phiếu VTP với tổng giá trị niêm yết hơn 1.217 tỷ đồng.",
      "Ngoài VTP tăng kịch biên độ trong phiên giao dịch đầu tiên trên HoSE, các cổ phiếu khác \"họ Viettel\" cũng tăng mạnh.",
      "Ngày mai (12/3), Viettel Post (mã VTP) sẽ chào sàn HoSE với mức giá tham chiếu 65.400 đồng/cổ phiếu. Phiên ngày 11/3, các cổ phiếu \"họ Viettel\" như VGI, CTR, VTK đều tăng mạnh trên HoSE, UPCOM, trong đó, CTR thậm chí tăng kịch trần."
    ];

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          mainColor.withOpacity(0.1),
                          mainColor.withOpacity(0.05)
                        ],
                      ),
                    ),
                    child: Image.asset(
                      'lib/assets/p${index + 1}.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.article,
                          color: mainColor,
                          size: 40,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titles[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        des[index],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "2 giờ trước",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
