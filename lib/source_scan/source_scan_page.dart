import 'package:auracast_assistant/auracast_assistant/auracast_assistant.dart';
import 'package:auracast_assistant/auracast_assistant/source.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SourceScanPage extends StatelessWidget {
  const SourceScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final assistant = context.watch<AuracastAssistant>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: () => assistant.connectedReceiver?.disconnect(),
        ),
        centerTitle: true,
        title: Text(assistant.connectedReceiver?.advertisementData.name ?? ''),
      ),
      body: ListView.separated(
        itemBuilder: (context, index) => ListTile(
          title: Row(
            children: [
              Text(assistant.sources[index].name),
              const Spacer(),
              Text(assistant.sources[index].state),
            ],
          ),
          onTap: () {
            assistant.sources[index].synced
                ? assistant.unSyncSource(assistant.sources[index])
                : assistant.syncSource(assistant.sources[index]);
          },
        ),
        separatorBuilder: (context, index) => const Divider(),
        itemCount: assistant.sources.length,
      ),
    );
  }
}

extension on AuracastSource {
  String get state {
    if (playing) {
      return 'playing';
    }
    if (synced) {
      return 'synced';
    }
    return '';
  }
}
