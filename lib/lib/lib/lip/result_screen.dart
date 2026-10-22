import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'languages.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  double sqMeter = 0;
  TextEditingController vagController = TextEditingController(text: "1");
  TextEditingController daamController = TextEditingController(text: "0");
  int vag = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    List<Position> points = ModalRoute.of(context)!.settings.arguments as List<Position>;
    if (sqMeter == 0) {
      sqMeter = calculateArea(points);
    }
  }

  // Jomi r area ber korar formula (Shoelace)
  double calculateArea(List<Position> points) {
    if (points.length < 3) return 0;
    
    // Lat/Lng ke meter e convert
    double avgLat = points.map((p) => p.latitude).reduce((a,b)=>a+b) / points.length;
    const double earthRadius = 6371000; // meter

    List<Point<double>> meters = points.map((p) {
      double x = (p.longitude * pi / 180) * earthRadius * cos(avgLat * pi / 180);
      double y = (p.latitude * pi / 180) * earthRadius;
      return Point(x, y);
    }).toList();

    double area = 0;
    for (int i = 0; i < meters.length; i++) {
      int j = (i + 1) % meters.length;
      area += meters[i].x * meters[j].y;
      area -= meters[j].x * meters[i].y;
    }
    area = area.abs() / 2;
    return area;
  }

  @override
  Widget build(BuildContext context) {
    double sqFeet = sqMeter * 10.7639;
    double decimal = sqMeter / 40.46;
    double acre = sqMeter / 4046.86;
    
    // West Bengal hisab
    // 1 Katha = 720 sq ft, 1 Bigha = 20 Katha = 14400 sq ft
    double katha = sqFeet / 720;
    double bigha = sqFeet / 14400;
    int bighaInt = bigha.floor();
    double kathaRemain = (bigha - bighaInt) * 20;
    int kathaInt = kathaRemain.floor();
    double chatak = (kathaRemain - kathaInt) * 16;

    // Sotok
    double sotok = decimal;

    double vagJomi = sqMeter / vag;
    double totalDaam = 0;
    if (daamController.text.isNotEmpty) {
      double perDecimalRate = double.tryParse(daamController.text) ?? 0;
      totalDaam = decimal * perDecimalRate;
    }

    return Scaffold(
      appBar: AppBar(title: Text(Lang.t('result_title')), backgroundColor: const Color(0xFF2E7D32)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _card(Lang.t('total_area'), [
              _row(Lang.t('sq_meter'), "${sqMeter.toStringAsFixed(2)}"),
              _row(Lang.t('sq_feet'), "${sqFeet.toStringAsFixed(2)}"),
              _row(Lang.t('decimal'), "${decimal.toStringAsFixed(4)} ${Lang.t('decimal_unit')}"),
              _row(Lang.t('acre'), "${acre.toStringAsFixed(4)}"),
            ]),
            const SizedBox(height: 12),
            _card(Lang.t('bengal_hisab'), [
              _row(Lang.t('bigha'), "$bighaInt ${Lang.t('bigha_unit')} $kathaInt ${Lang.t('katha_unit')} ${chatak.toStringAsFixed(1)} ${Lang.t('chatak_unit')}"),
              _row(Lang.t('katha_total'), "${katha.toStringAsFixed(3)} ${Lang.t('katha_unit')}"),
              _row(Lang.t('sotok_total'), "${sotok.toStringAsFixed(3)} ${Lang.t('sotok_unit')}"),
            ]),
            const SizedBox(height: 12),
            _card(Lang.t('vagavagi'), [
              Row(
                children: [
                  Expanded(child: Text(Lang.t('koy_vag'))),
                  SizedBox(width: 80, child: TextField(controller: vagController, keyboardType: TextInputType.number, onChanged: (v){ setState(() { vag = int.tryParse(v) ?? 1; if(vag==0) vag=1; }); }, decoration: const InputDecoration(border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 8),
              _row("${Lang.t('one_vag')}", "${vagJomi.toStringAsFixed(2)} ${Lang.t('sq_meter')} / ${(decimal/vag).toStringAsFixed(3)} ${Lang.t('decimal_unit')}")
            ]),
            const SizedBox(height: 12),
            _card(Lang.t('daam_hisab'), [
              TextField(controller: daamController, keyboardType: TextInputType.number, onChanged: (_)=>setState((){}), decoration: InputDecoration(labelText: Lang.t('per_decimal_price'), border: const OutlineInputBorder())),
              const SizedBox(height: 8),
              _row(Lang.t('total_price'), "₹ ${totalDaam.toStringAsFixed(2)}", isBold: true),
            ]),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: Text(Lang.t('map_again'))),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Card(elevation: 3, child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))), const Divider(), ...children])));
  }
  Widget _row(String label, String value, {bool isBold=false}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text(value, style: TextStyle(fontWeight: isBold?FontWeight.bold:FontWeight.normal))]));
  }
}
