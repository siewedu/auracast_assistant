import 'dart:typed_data';

import 'package:auracast_assistant/auracast_assistant/receive_state.dart';
import 'package:auracast_assistant/mac_address.dart';
import 'package:auracast_assistant/utils.dart';

class AuracastSource {
  const AuracastSource({
    required this.name,
    required this.address,
    required this.advertisingSetId,
    required this.broadcastIdBytes,
    this.syncing = false,
    this.synced = false,
    this.playing = false,
  });

  factory AuracastSource.fromReceiveState(ReceiveState state, [String? name]) {
    final source = state.source;
    if (source == null) {
      throw ArgumentError('ReceiveState does not contain a source');
    }
    return AuracastSource(
      name: name ?? source.sourceAddress.toString(),
      address: source.sourceAddress,
      advertisingSetId: source.advertisingSid,
      broadcastIdBytes: source.broadcastIdBytes,
      synced: source.synced,
      playing: source.playing,
    );
  }

  final String name;
  final MacAddress address;
  final int advertisingSetId;
  final Uint8List broadcastIdBytes;
  final bool syncing;
  final bool synced;
  final bool playing;

  int get broadcastId => broadcastIdBytes.toInteger();
}
