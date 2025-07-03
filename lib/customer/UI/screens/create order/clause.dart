import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:easy_localization/easy_localization.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  Map<String, dynamic> _getDoc(BuildContext context) {
    return {
      'title': context.tr('order_pages.documents.policy'),
      'data': context.tr('order_pages.documents.policyContent'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final doc = _getDoc(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(doc["title"]??"", style: const TextStyle(color: Colors.white)),
        backgroundColor: mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          doc["data"]??"",
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
