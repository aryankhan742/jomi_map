import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'languages.dart';

class GpsScreen extends StatefulWidget {
  const GpsScreen({super.key});

  @override
  State<GpsScreen> createState() => _GpsScreenState();
}

class _GpsScreenState extends State<GpsScreen> {
  List<Position> points = [];
  StreamSubscription<Position>? positionStream;
  bool isTracking = false;
  double totalDistance = 0;

  // GPS chalu ache kina check
  Future<bool> _checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Lang.t('gps_off'))),
      );
      return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  void startTracking() async {
    bool hasPermission = await _checkPermission();
    if (!hasPermission) return;

    setState(() {
      isTracking = true;
      points = [];
      totalDistance = 0;
    });

    const LocationSettings settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 1, // 1 meter por por point nebe
    );

    positionStream = Geolocator.getPositionStream(locationSettings: settings).listen((Position pos) {
      if (points.isNotEmpty) {
        double dist = Geolocator.distanceBetween(
          points.last.latitude, points.last.longitude,
          pos.latitude, pos.longitude
        );
        // Jodi 1 meter er besi na nore tahole point nobe na
        if (dist < 2) return;
        totalDistance += dist;
      }
      setState(() {
        points.add(pos);
      });
    });
  }

  void stopTracking() {
    positionStream?.cancel();
    setState(() {
      isTracking = false;
    });
    if (points.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Lang.t('need_3_points'))),
      );
      return;
    }
    // Result screen e pathao
    Navigator.pushNamed(context, '/result', arguments: points);
  }

  void clearPoints() {
    positionStream?.cancel();
    setState(() {
      points = [];
      isTracking = false;
      totalDistance = 0;
    });
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Lang.t('gps_title')),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text("${Lang.t('points')}: ${points.length}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text("${Lang.t('distance')}: ${totalDistance.toStringAsFixed(2)} ${Lang.t('meter')}", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.circle, color: isTracking ? Colors.red : Colors.grey, size: 12),
                    const SizedBox(width: 5),
                    Text(isTracking ? Lang.t('tracking_on') : Lang.t('tracking_off')),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: points.isEmpty
                ? Center(child: Text(Lang.t('start_walk'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)))
                : ListView.builder(
                    itemCount: points.length,
                    itemBuilder: (context, i) {
                      return ListTile(
                        leading: CircleAvatar(child: Text("${i + 1}")),
                        title: Text("${points[i].latitude.toStringAsFixed(6)}, ${points[i].longitude.toStringAsFixed(6)}"),
                        subtitle: Text("${Lang.t('accuracy')}: ${points[i].accuracy.toStringAsFixed(1)}m"),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isTracking ? null : startTracking,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text(Lang.t('start'), style: const TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isTracking ? stopTracking : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text(Lang.t('stop_save'), style: const TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(onPressed: clearPoints, icon: const Icon(Icons.delete, color: Colors.red)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
