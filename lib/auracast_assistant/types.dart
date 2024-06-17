// Broadcast Audio Scan Service
// https://www.bluetooth.com/specifications/bass-1-0/

import 'dart:typed_data';

import 'package:equatable/equatable.dart';

enum AddressType {
  public(0),
  random(1);

  const AddressType(this.value);

  final int value;

  static AddressType fromValue(int value) {
    return switch (value) {
      0 => AddressType.public,
      1 => AddressType.random,
      _ => throw ArgumentError('Unknown AddressType'),
    };
  }
}

enum PaSync {
  noSync(0),
  syncWithPast(1),
  syncWithoutPast(2);

  const PaSync(this.value);
  final int value;

  static PaSync fromValue(int value) {
    return switch (value) {
      0 => PaSync.noSync,
      1 => PaSync.syncWithPast,
      2 => PaSync.syncWithoutPast,
      _ => throw ArgumentError('Unknown PaSync'),
    };
  }
}

enum PaSyncState {
  notSynced(0),
  syncInfoRequest(1),
  synced(2),
  syncFailed(3),
  noPast(4);

  const PaSyncState(this.value);
  final int value;

  static PaSyncState fromValue(int value) {
    return switch (value) {
      0 => PaSyncState.notSynced,
      1 => PaSyncState.syncInfoRequest,
      2 => PaSyncState.synced,
      3 => PaSyncState.syncFailed,
      4 => PaSyncState.noPast,
      _ => throw ArgumentError('Unknown PaSyncState'),
    };
  }
}

enum BigEncryption {
  notEncrypted(0),
  codeRequired(1),
  decrypting(2),
  badCode(3);

  const BigEncryption(this.value);

  final int value;

  static BigEncryption fromValue(int value) {
    return switch (value) {
      0 => BigEncryption.notEncrypted,
      1 => BigEncryption.codeRequired,
      2 => BigEncryption.decrypting,
      3 => BigEncryption.badCode,
      _ => throw ArgumentError('Unknown BigEncryption'),
    };
  }
}

/// Broadcast Isochronouse Group.
class BigSubgroup extends Equatable {
  BigSubgroup({required this.index, Uint8List? bisSync, this.metaData})
      : bisSync = bisSync ?? bisSyncNoPreference;

  factory BigSubgroup.fromBytes(int index, Uint8List bytes) {
    Uint8List? metaData;
    final metaDataLength = bytes.elementAtOrNull(4);
    if (metaDataLength != null && metaDataLength > 0) {
      metaData = bytes.sublist(5, 5 + metaDataLength);
    }

    return BigSubgroup(
      index: index,
      bisSync: bytes.sublist(0, 4),
      metaData: metaData,
    );
  }

  /// Let's the headphone determine which streams to sync to.
  static final bisSyncNoPreference =
      Uint8List.fromList([0xFF, 0xFF, 0xFF, 0xFF]);

  /// Unsyncs all streams
  static final bisSyncUnsyncAll = Uint8List.fromList([0x00, 0x00, 0x00, 0x00]);

  final int index;
  // Broadcast Isochronous Stream Synchronization Information. It's a bitfield
  // containing the sync state of the possible streams of this subgroup.
  // See bass spec for details.
  Uint8List bisSync;
  Uint8List? metaData;

  int get length => 5 + (metaData?.length ?? 0);
  bool get synced {
    final bisSyncState = bisSync.buffer.asByteData().getUint32(0);

    return bisSyncState != 0xFFFFFFFF && bisSyncState != 0;
  }

  Uint8List serialize() {
    final bytes = <int>[
      ...bisSync,
      metaData?.length ?? 0,
      if (metaData != null) ...metaData!,
    ];

    return Uint8List.fromList(bytes);
  }

  @override
  List<Object?> get props => [index, bisSync, metaData];
}
