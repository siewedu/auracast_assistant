# auracast_assistant

This is a smple application that demonstrates how to implement an Auracast assistant for phones which don't support scanning for Auracast sources. 
The implementation follows the conecpt described in this document https://www.bluetooth.com/wp-content/uploads/2023/03/Developing_Auracast_Receivers-Legacy_Smartphones.pdf

## Getting Started

Start the app and tap on the lens icon to scan for receivers. You might want to afjust the scan filter since currenlty it will only return BLE devices that implemet the Sennheiser service.
```
_blePlugin.scanForDevices(
      withServices: [BleUuid.sennheiserService],
      scanMode: ScanMode.lowLatency,
      requireLocationServicesEnabled: false,
    ).listen(
      _addReceiver,
      onDone: _onScanDone,
      onError: _onScanError,
    );
```
Tap on the scan result to connect to the device. 
The app will show the sources that are listed in the receive states. 
Tap on a source to sync or unsync it. 
