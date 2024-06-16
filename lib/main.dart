import 'package:auracast_assistant/auracast_assistant/auracast_assistant.dart';
import 'package:auracast_assistant/receiver_scan/receiver_scan_page.dart';
import 'package:auracast_assistant/source_scan/source_scan_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
        create: (_) => AuracastAssistant(FlutterReactiveBle())..init())
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auracast Assistant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final connected =
        context.select((AuracastAssistant assistant) => assistant.connected);
    return connected ? const SourceScanPage() : const ReceiverScanPage();
  }
}
