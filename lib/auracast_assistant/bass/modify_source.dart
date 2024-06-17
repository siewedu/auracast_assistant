import 'dart:typed_data';

import 'package:auracast_assistant/auracast_assistant/types.dart';
import 'package:equatable/equatable.dart';

class ModifySourceOperation extends Equatable {
  const ModifySourceOperation({
    required this.sourceId,
    required this.paSync,
    this.paInterval = const [0xFF, 0xFF],
    this.subgroups = const [],
  });

  final int opCode = 0x03;
  final int sourceId;
  final PaSync paSync;
  final List<int> paInterval;
  final List<BigSubgroup> subgroups;

  Uint8List serialize() {
    final bytes = <int>[
      opCode,
      sourceId,
      paSync.value,
      ...paInterval.sublist(0, 2),
      subgroups.length,
    ];
    for (final subgroup in subgroups) {
      bytes.addAll(subgroup.serialize());
    }

    return Uint8List.fromList(bytes);
  }

  @override
  List<Object?> get props => [
        opCode,
        sourceId,
        paSync,
        paInterval,
        subgroups,
      ];
}
