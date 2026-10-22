import 'package:flutter/material.dart';
import 'languages.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Lang.t('subscribe')), backgroundColor: const Color(0xFF2E7D32)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(Lang.t('choose_plan'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _planCard(context, "1 ${Lang.t('month')}", "₹99", "Basic", Colors.green.shade100),
          _planCard(context, "2 ${Lang.t('month')}", "₹199", "Popular", Colors.orange.shade100, isPopular: false),
          _planCard(context, "3 ${Lang.t('month')}", "₹249", "Best Value", Colors.blue.shade100),
          _planCard(context, "6 ${Lang.t('month')}", "₹399", "1 ${Lang.t('month')} ${Lang.t('free')}", Colors.purple.shade100, isPopular: true),
          _planCard(context, Lang.t('lifetime'), "₹999", "Unlimited", Colors.amber.shade100, isLifetime: true),
        ],
      ),
    );
  }

  Widget _planCard(BuildContext context, String duration, String price, String tag, Color color, {bool isPopular=false, bool isLifetime=false}) {
    return Card(
      color: color,
      elevation: isPopular ? 5 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPopular ? const BorderSide(color: Colors.purple, width: 2) : BorderSide.none,
      ),
      child: ListTile(
        leading: Icon(isLifetime ? Icons.all_inclusive : Icons.workspace_premium, size: 40, color: const Color(0xFF2E7D32)),
        title: Row(children: [
          Text("$duration - $price", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          if (isPopular) Container(margin: const EdgeInsets.only(left: 8), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(8)), child: Text(Lang.t('offer'), style: const TextStyle(color: Colors.white, fontSize: 10))),
        ]),
        subtitle: Text(tag),
        trailing: ElevatedButton(
          onPressed: () {
            // Google Play Billing ekhane add hobe
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${Lang.t('buying')} $duration")));
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
          child: Text(Lang.t('buy'), style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
