// lib/customer/UI/screens/profile/info_display_page.dart
import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/core/constant.dart';

class InfoDisplayPage extends StatelessWidget {
  final String title;
  final String content;

  const InfoDisplayPage({
    super.key, 
    required this.title, 
    required this.content
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          content,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}