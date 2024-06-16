import 'package:auracast_assistant/auracast_assistant/auracast_assistant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReceiverScanPage extends StatelessWidget {
  const ReceiverScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final assistant = context.watch<AuracastAssistant>();
    final receivers = assistant.receivers;
    final scanning = assistant.scanning;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Scan for Receivers'),
        ),
        body: Center(
          child: ListView.separated(
            itemBuilder: (context, index) => ListTile(
              title: Row(
                children: [
                  Text(receivers[index].advertisementData.name),
                  const Spacer(),
                  receivers[index].connecting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator())
                      : const SizedBox.shrink(),
                ],
              ),
              onTap: () {
                assistant.stopScan();
                assistant.connectReceiver(receivers[index]);
              },
            ),
            separatorBuilder: (_, __) => const Divider(),
            itemCount: receivers.length,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: scanning ? null : assistant.scanForReceivers,
          child: scanning
              ? const CircularProgressIndicator()
              : const Icon(Icons.search),
        ));
  }
}
