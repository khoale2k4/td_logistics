import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class InsuranceDetailsPage extends StatelessWidget {
  final TextEditingController noteController;
  final List<Uint8List> images;
  final bool isInvoiceEnabled;
  final TextEditingController companyNameController;
  final TextEditingController addressController;
  final TextEditingController taxCodeController;
  final TextEditingController emailController;

  InsuranceDetailsPage({
    required this.noteController,
    required this.images,
    required this.isInvoiceEnabled,
    required this.companyNameController,
    required this.addressController,
    required this.taxCodeController,
    required this.emailController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr("order_pages.insurance.title")),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Note Section
            Text(
              context.tr("order_pages.insurance.enterNote"),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              noteController.text.isNotEmpty
                  ? noteController.text
                  : context.tr("common.noData"),
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(height: 30),

            // Images Section
            Text(
              context.tr("history.images&signature"),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            images.isNotEmpty
                ? Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: images
                        .map((image) => Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ))
                        .toList(),
                  )
                : Text(
                    context.tr("history.noImages"),
                    style: const TextStyle(color: Colors.grey),
                  ),
            const Divider(height: 30),

            // Invoice Information Section
            Text(
              context.tr("order_pages.insurance.invoice"),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            isInvoiceEnabled
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                          context.tr("order_pages.insurance.companyName"), companyNameController.text),
                      _buildDetailRow(context.tr("history.address"), addressController.text),
                      _buildDetailRow(context.tr("order_pages.insurance.taxCode"), taxCodeController.text),
                      _buildDetailRow(context.tr("order_pages.insurance.companyEmail"), emailController.text),
                    ],
                  )
                : Text(
                    context.tr("order_pages.insurance.noInvoiceRequired"),
                    style: const TextStyle(color: Colors.grey),
                  ),
            const Divider(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Expanded(
              child: Text(
                value.isNotEmpty ? value : context.tr("common.noData"),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
