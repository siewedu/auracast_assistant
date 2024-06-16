import 'package:auracast_assistant/auracast_assistant/auracast_assistant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SourceScanPage extends StatelessWidget {
  const SourceScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final assistant = context.watch<AuracastAssistant>();
    final scanning = assistant.scanning;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () => assistant.connectedReceiver?.disconnect(),
          ),
          centerTitle: true,
          title:
              Text(assistant.connectedReceiver?.advertisementData.name ?? ''),
        ),
        body: ListView.separated(
            itemBuilder: (context, index) => ListTile(
                  title: Text(assistant.sources[index].name),
                ),
            separatorBuilder: (context, index) => const Divider(),
            itemCount: assistant.sources.length),
        floatingActionButton: FloatingActionButton(
          onPressed: scanning ? null : assistant.scanForReceivers,
          child: scanning
              ? const CircularProgressIndicator()
              : const Icon(Icons.search),
        ));
  }
}
