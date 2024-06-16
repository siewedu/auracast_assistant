import 'dart:typed_data';

import 'package:auracast_assistant/auracast_assistant/types.dart';
import 'package:auracast_assistant/mac_address.dart';
import 'package:auracast_assistant/utils.dart';
import 'package:equatable/equatable.dart';

class ReceiveState extends Equatable {
  const ReceiveState({
    this.sourceId,
    this.source,
  });

  factory ReceiveState.fromBytes(Uint8List bytes) {
    return bytes.isEmpty
        ? const ReceiveState()
        : ReceiveState(
            sourceId: bytes[0],
            source: SourceInfo.fromBytes(bytes.sublist(1)),
          );
  }

  final int? sourceId;
  final SourceInfo? source;

  @override
  List<Object?> get props => [
        sourceId,
        source,
      ];
}

class SourceInfo extends Equatable {
  const SourceInfo({
    required this.addressType,
    required this.sourceAddress,
    required this.advertisingSid,
    required Uint8List broadcastId,
    required this.paSyncState,
    required this.encryption,
    this.badCode,
    required this.subgroups,
  }) : _broadcastId = broadcastId;

  factory SourceInfo.fromBytes(Uint8List bytes) {
    final addressType = AddressType.fromValue(bytes[0]);
    final sourceAddress =
        MacAddress.fromBytes(bytes.sublist(1, 7).reversed.toList());
    final advertisingSid = bytes[7];
    final broadcastId = bytes.sublist(8, 11);
    final paSyncState = PaSyncState.values[bytes[11]];
    final encryption = BigEncryption.values[bytes[12]];
    final badCode =
        encryption == BigEncryption.badCode ? bytes.sublist(13, 29) : null;
    final offset = encryption == BigEncryption.badCode ? 29 : 13;
    final subgroupsBytes = bytes.sublist(offset).toList();
    final subgroups = <BigSubgroup>[];
    final numSubgroups = subgroupsBytes.removeAt(0);
    for (var i = 0; i < numSubgroups; i++) {
      final subgroup =
          BigSubgroup.fromBytes(i, Uint8List.fromList(subgroupsBytes));
      subgroups.add(subgroup);
      subgroupsBytes.removeRange(0, subgroup.length);
    }

    return SourceInfo(
      addressType: addressType,
      sourceAddress: sourceAddress,
      advertisingSid: advertisingSid,
      broadcastId: broadcastId,
      paSyncState: paSyncState,
      encryption: encryption,
      badCode: badCode,
      subgroups: subgroups,
    );
  }

  final AddressType addressType;
  final MacAddress sourceAddress;
  final int advertisingSid;
  final Uint8List _broadcastId;
  final PaSyncState paSyncState;
  final BigEncryption encryption;
  final Uint8List? badCode;
  final List<BigSubgroup> subgroups;

  bool get playing => subgroups.any((group) => group.synced);
  bool get synced => paSyncState == PaSyncState.synced;
  int get broadcastId => _broadcastId.toInteger();
  Uint8List get broadcastIdBytes => _broadcastId;

  @override
  List<Object?> get props => [
        addressType,
        sourceAddress,
        advertisingSid,
        broadcastId,
        paSyncState,
        encryption,
        badCode,
        subgroups,
        _broadcastId,
      ];
}
