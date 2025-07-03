import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}

class HelpCenterPage extends StatelessWidget {
  HelpCenterPage({super.key});

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<FaqItem> faqItems = [
      FaqItem(
        question: context.tr('help_center.faq1_q'),
        answer: context.tr('help_center.faq1_a'),
      ),
      FaqItem(
        question: context.tr('help_center.faq2_q'),
        answer: context.tr('help_center.faq2_a'),
      ),
      FaqItem(
        question: context.tr('help_center.faq3_q'),
        answer: context.tr('help_center.faq3_a'),
      ),
      FaqItem(
        question: context.tr('help_center.faq4_q'),
        answer: context.tr('help_center.faq4_a'),
      ),
      FaqItem(
        question: context.tr('help_center.faq5_q'),
        answer: context.tr('help_center.faq5_a'),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('help_center.title'),
            style: const TextStyle(color: Colors.white)),
        backgroundColor: mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            context.tr('help_center.faq'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...faqItems.map((item) => _buildFaqTile(item)).toList(),

          const SizedBox(height: 24),
          const Divider(thickness: 1),
          const SizedBox(height: 24),

          Text(
            context.tr('help_center.contact'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildContactMethodsGrid(context),
        ],
      ),
    );
  }

  Widget _buildFaqTile(FaqItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      color: Colors.white,
      child: ExpansionTile(
        title: Text(item.question,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        childrenPadding: const EdgeInsets.all(16).copyWith(top: 0),
        expandedAlignment: Alignment.centerLeft,
        children: [
          Text(item.answer,
              style: TextStyle(
                  fontSize: 15, height: 1.5, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildContactMethodsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildContactCard(
          context: context,
          icon: Icons.facebook,
          titleKey: 'facebook',
          color: Colors.blue.shade800,
          onTap: () => _launchURL('https://m.me/your_facebook_page_username'),
        ),
        _buildContactCard(
          context: context,
          icon: Icons.message,
          titleKey: 'zalo',
          color: Colors.blue.shade600,
          onTap: () => _launchURL('https://zalo.me/your_zalo_phone_number'),
        ),
        _buildContactCard(
          context: context,
          icon: Icons.phone_in_talk_outlined,
          titleKey: 'hotline',
          color: Colors.green,
          onTap: () => _launchURL('tel:19001234'),
        ),
        _buildContactCard(
          context: context,
          icon: Icons.email_outlined,
          titleKey: 'email',
          color: Colors.red.shade700,
          onTap: () => _launchURL('mailto:support@tdlogistics.vn?subject=Hỗ trợ khách hàng'),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required String titleKey,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                context.tr('help_center.' + titleKey),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
