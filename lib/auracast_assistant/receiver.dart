import 'dart:async';
import 'dart:typed_data';

import 'package:auracast_assistant/auracast_assistant/bass/modify_source.dart';
import 'package:auracast_assistant/auracast_assistant/receive_state.dart';
import 'package:auracast_assistant/auracast_assistant/types.dart';
import 'package:auracast_assistant/auracast_assistant/uuids.dart';
import 'package:collection/collection.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:rxdart/subjects.dart';

class Receiver {
  Receiver(this.advertisementData, this._blePlugin) : id = advertisementData.id;
  final String id;
  final DiscoveredDevice advertisementData;
  DeviceConnectionState connectionState = DeviceConnectionState.disconnected;
  List<Service> get services => _services;
  Stream<List<ReceiveState>> get receiveStates => _receiveStates.stream;
  bool get connected => DeviceConnectionState.connected == connectionState;
  bool get connecting => DeviceConnectionState.connecting == connectionState;

  final FlutterReactiveBle _blePlugin;
  List<Service> _services = [];
  final _receiveStates = BehaviorSubject.seeded(<ReceiveState>[]);
  var _receiveStateCharacteristics = <Characteristic>[];
  Characteristic? _scanControlPointCharacteristics;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;

  Stream<ConnectionStateUpdate> connect() {
    if (connectionState == DeviceConnectionState.connected) {
      throw StateError('Already connected');
    }

    final stream = _blePlugin.connectToDevice(
        id: id, connectionTimeout: const Duration(seconds: 10));

    _connectionSubscription = stream.listen((update) {
      connectionState = update.connectionState;
      if (update.connectionState == DeviceConnectionState.connected) {
        _init();
      }
      if (update.connectionState == DeviceConnectionState.disconnected) {
        _receiveStates.add(<ReceiveState>[]);
        _connectionSubscription?.cancel();
        _connectionSubscription = null;
      }
    });

    return stream;
  }

  Future<void> disconnect() async {
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
  }

  void syncSource(int broadcastId) => _setSync(true, broadcastId);

  void unSyncSource(int broadcastId) => _setSync(false, broadcastId);

  void _setSync(bool sync, int broadcastId) {
    final index = _receiveStates.value
        .indexWhere((state) => state.source?.broadcastId == broadcastId);
    if (index == -1) {
      return;
    }
    final subgroups = _receiveStates.value[index].source?.subgroups.map((sg) {
          sg.bisSync = sync
              ? BigSubgroup.bisSyncNoPreference
              : BigSubgroup.bisSyncUnsyncAll;
          return sg;
        }).toList() ??
        [];
    final bytes = ModifySourceOperation(
      sourceId: _receiveStates.value[index].sourceId!,
      paSync: sync ? PaSync.syncWithoutPast : PaSync.noSync,
      subgroups: subgroups.isEmpty
          ? [BigSubgroup(index: 0, bisSync: BigSubgroup.bisSyncNoPreference)]
          : subgroups,
    ).serialize();
    _scanControlPointCharacteristics?.write(bytes);
  }

  Future<void> _init() async {
    await _discoverServices();
    await subscribeReceiveStates();
  }

  Future<void> _discoverServices() async {
    await _blePlugin.discoverAllServices(id);
    _services = await _blePlugin.getDiscoveredServices(id);
  }

  Future<void> subscribeReceiveStates() async {
    final bassService = _services.firstWhereOrNull((service) =>
        service.id.expanded == BleUuid.broadcastAudioScanService.expanded);
    _scanControlPointCharacteristics = bassService?.characteristics
        .firstWhereOrNull((char) =>
            char.id.expanded ==
            BleUuid.broadcastScanControlPointCharacteristic.expanded);
    _receiveStateCharacteristics = bassService?.characteristics
            .where((char) =>
                char.id.expanded == BleUuid.receiveStateCharacteristic.expanded)
            .toList() ??
        [];

    if (_receiveStateCharacteristics.isEmpty) {
      return;
    }

    final receiveStates = <ReceiveState>[];

    for (final (index, char) in _receiveStateCharacteristics.indexed) {
      final data = await char.read();
      receiveStates.add(ReceiveState.fromBytes(Uint8List.fromList(data)));

      char.subscribe().listen((data) {
        final states = _receiveStates.value;
        states[index] = ReceiveState.fromBytes(Uint8List.fromList(data));
        _receiveStates.add(states);
      });
    }
    _receiveStates.add(receiveStates);
  }
}
