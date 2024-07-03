import 'dart:async';

import 'package:auracast_assistant/auracast_assistant/receive_state.dart';
import 'package:auracast_assistant/auracast_assistant/receiver.dart';
import 'package:auracast_assistant/auracast_assistant/source.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class AuracastAssistant with ChangeNotifier {
  AuracastAssistant(this._blePlugin);

  List<Receiver> get receivers => _receivers;
  List<AuracastSource> get sources => _sources;
  Receiver? get connectedReceiver =>
      _receivers.firstWhereOrNull((receiver) => receiver.connected);
  bool get scanning => _scanCompleter != null;
  bool get connected => _selectedReceiver?.connected ?? false;

  final FlutterReactiveBle _blePlugin;
  List<Receiver> _receivers = [];
  List<AuracastSource> _sources = [];
  Receiver? _selectedReceiver;
  List<String> get _receieverIds => _receivers.map((e) => e.id).toList();

  Completer<void>? _scanCompleter;
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  StreamSubscription<List<ReceiveState>>? _receieveStateSubscription;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;

  Future<void> init() async {
    final permission = await Permission.bluetoothScan.request();
    if (permission.isGranted) {
      Permission.bluetoothConnect.request();
    }
    _connectionSubscription = _blePlugin.connectedDeviceStream.listen((update) {
      _receivers = _receivers.map((receiver) {
        if (receiver.id == update.deviceId) {
          receiver.connectionState = update.connectionState;
        }
        return receiver;
      }).toList();
      notifyListeners();
    });
  }

  /// Scans for devices that implement the broadcastAudioScanService
  Future<void> scanForReceivers() {
    _scanCompleter = Completer<void>();
    _receivers.clear();
    _scanSubscription = _blePlugin.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
      requireLocationServicesEnabled: false,
    ).listen(
      _addReceiver,
      onDone: _onScanDone,
      onError: _onScanError,
    );

    Timer(const Duration(seconds: 5), _onScanDone);
    notifyListeners();
    return _scanCompleter!.future;
  }

  void stopScan() => _onScanDone();

  /// Connects selected receiever and subscribes to receieve states
  void connectReceiver(Receiver receiver) {
    if (_selectedReceiver?.advertisementData.id == receiver.id &&
        _selectedReceiver?.connected == true) {
      // Already connected to this receiver
      return;
    }

    connectedReceiver?.disconnect();
    _selectedReceiver = receiver..connect();
    _receieveStateSubscription =
        _selectedReceiver?.receiveStates.listen((receiveStates) {
      _sources = receiveStates
          .where((state) => state.source != null)
          .map((state) => AuracastSource.fromReceiveState(state))
          .toList();
      notifyListeners();
    });
  }

  void syncSource(AuracastSource source) =>
      _selectedReceiver?.syncSource(source.broadcastId);

  void unSyncSource(AuracastSource source) =>
      _selectedReceiver?.unSyncSource(source.broadcastId);

  void _addReceiver(DiscoveredDevice device) {
    if (!_receieverIds.contains(device.id)) {
      _receivers.add(Receiver(device, _blePlugin));
    }
    notifyListeners();
  }

  void _onScanDone() {
    _scanSubscription?.cancel();
    _scanCompleter?.complete();
    _scanSubscription = null;
    _scanCompleter = null;
    notifyListeners();
  }

  void _onScanError(Object error) {
    _scanSubscription?.cancel();
    _scanCompleter?.completeError(error);
    _scanSubscription = null;
    _scanCompleter = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _receieveStateSubscription?.cancel();
    _connectionSubscription?.cancel();
    _selectedReceiver?.disconnect();
    super.dispose();
  }
}
