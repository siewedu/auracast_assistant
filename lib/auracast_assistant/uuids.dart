import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleUuid {
  // Broadcast Audio Scan Service
  static final broadcastAudioScanService = Uuid([0x18, 0x4F]);
  static final broadcastScanControlPointCharacteristic = Uuid([0x2B, 0xC7]);
  static final receiveStateCharacteristic = Uuid([0x2B, 0xC8]);
  // Sennheiser service
  static final sennheiserService = Uuid([0xFC, 0xFE]);
}
