// lib/customer/UI/screens/profile/about_service_page.dart
import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tdlogistic_v2/customer/data/models/service_info.dart';
import 'package:easy_localization/easy_localization.dart';

class AboutServicePage extends StatefulWidget {
  const AboutServicePage({super.key});

  @override
  State<AboutServicePage> createState() => _AboutServicePageState();
}

class _AboutServicePageState extends State<AboutServicePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // --- DANH SÁCH DỮ LIỆU CHO CÁC SLIDE ---
  // Bạn có thể dễ dàng thay đổi nội dung, ảnh, và tiêu đề ở đây
  List<ServiceInfo> get _services => [
    ServiceInfo(
      imageUrl:
          'https://images.unsplash.com/photo-1586528116311-069241512f39?q=80&w=2070', // Ảnh minh họa
      title: context.tr('order_pages.services.express.title'),
      description: context.tr('order_pages.services.express.description'),
    ),
    ServiceInfo(
      imageUrl:
          'https://images.unsplash.com/photo-1605723545642-12749a882248?q=80&w=2070',
      title: context.tr('order_pages.services.economy.title'),
      description: context.tr('order_pages.services.economy.description'),
    ),
    ServiceInfo(
      imageUrl:
          'https://images.unsplash.com/photo-1576134044948-c8c39a083435?q=80&w=2070',
      title: context.tr('order_pages.services.cod.title'),
      description: context.tr('order_pages.services.cod.description'),
    ),
    ServiceInfo(
      imageUrl:
          'https://images.unsplash.com/photo-1586528116311-069241512f39?q=80&w=2070',
      title: context.tr('order_pages.services.heavy.title'),
      description: context.tr('order_pages.services.heavy.description'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (_currentPage != newPage) {
        setState(() {
          _currentPage = newPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('order_pages.services.title'),
            style: const TextStyle(color: Colors.white)),
        backgroundColor: mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[100],
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _services.length,
            itemBuilder: (context, index) {
              return _buildServiceSlide(_services[index]);
            },
          ),
          Positioned(
            bottom: 20.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_services.length, (index) {
                return _buildIndicatorDot(isActive: index == _currentPage);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSlide(ServiceInfo service) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment:
              CrossAxisAlignment.center, // Giữ nguyên căn giữa theo chiều ngang
          children: [
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: CachedNetworkImage(
                imageUrl: service.imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 250,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 250,
                  color: Colors.grey[200],
                  child: const Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 30),

            Text(
              service.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              service.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, color: Colors.grey.shade700, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? mainColor : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
