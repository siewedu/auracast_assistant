import 'dart:async';
import 'dart:typed_data';

import 'package:auracast_assistant/auracast_assistant/receive_state.dart';
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
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;

  Stream<ConnectionStateUpdate> connect() {
    if (connectionState == DeviceConnectionState.connected) {
      throw StateError('Already connected');
    }

    final stream = _blePlugin.connectToDevice(
        id: id, connectionTimeout: const Duration(seconds: 10));

    _connectionSubscription = stream.listen((update) {
      print('connection state update for $id ${update.connectionState}');
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

  Future<void> _init() async {
    await _discoverServices();
    await subscribeReceiveStates();
  }

  Future<void> _discoverServices() async {
    await _blePlugin.discoverAllServices(id);
    _services = await _blePlugin.getDiscoveredServices(id);
    for (var service in _services) {
      print('Discovered service: ${service.id}');
    }
  }

  Future<void> subscribeReceiveStates() async {
    final bassService = _services.firstWhereOrNull(
        (service) => service.id == BleUuid.broadcastAudioScanService.expanded);
    print('Discovered bass service: ${bassService?.id}');
    final receiveStateCharacteristics = bassService?.characteristics.where(
        (char) => char.id == BleUuid.receiveStateCharacteristic.expanded);

    if (receiveStateCharacteristics == null) {
      print('No receive state characteristics found for $id');
      return;
    }

    final receiveStates = <ReceiveState>[];

    print('discovered ${receiveStateCharacteristics.length} receive states');

    for (final (index, char) in receiveStateCharacteristics.indexed) {
      final data = await char.read();
      receiveStates.add(ReceiveState.fromBytes(Uint8List.fromList(data)));

      char.subscribe().listen((data) {
        final states = _receiveStates.value;
        states[index] = ReceiveState.fromBytes(Uint8List.fromList(data));
        _receiveStates.add(states);
      });
    }
    print('Subscribed to ${receiveStates.length} receive states');
    _receiveStates.add(receiveStates);
  }
}
