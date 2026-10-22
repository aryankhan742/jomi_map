import 'package:flutter/material.dart';
import 'gps_screen.dart';
import 'subscription_screen.dart';
import 'languages.dart';

void main() => runApp(const MyApp());
class MyApp extends StatefulWidget { const MyApp({super.key}); @override State<MyApp> createState() => _MyAppState(); }
class _MyAppState extends State<MyApp> {
  @override Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: const HomePage());
  }
}
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLang.get('appName')), actions: [
        DropdownButton<String>(value: AppLang.current, items: const [DropdownMenuItem(value:'bn',child:Text('বাংলা')),DropdownMenuItem(value:'en',child:Text('EN')),DropdownMenuItem(value:'hi',child:Text('हिन्दी'))], onChanged: (v){ AppLang.current = v!; (context as Element).markNeedsBuild(); })
      ]),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.asset('assets/icon.png', height: 120),
        const SizedBox(height: 20),
        ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)), icon: const Icon(Icons.my_location), label: Text(AppLang.get('start')), onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const GpsScreen()))),
        const SizedBox(height: 15),
        TextButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const SubscriptionScreen())), child: Text(AppLang.get('pro')))
      ])),
    );
  }
}
