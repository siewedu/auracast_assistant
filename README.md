# auracast_assistant

This is a sample application that demonstrates how to implement an Auracast assistant for phones which don't support scanning for Auracast sources. 
The implementation follows the conecpt described in this document https://www.bluetooth.com/wp-content/uploads/2023/03/Developing_Auracast_Receivers-Legacy_Smartphones.pdf
For more background information on this auracast assisstant implementation please check my talk at the FlutterCon 2024 here https://www.droidcon.com/2024/09/03/bluetooth-le-audio-broadcast-how-to-build-an-auracast-assistant-app-with-flutter/.

## Getting Started

Start the app and tap on the lens icon to scan for receivers.\
Tap on the scan result to connect to the device.\
The app is not handling the BLE pairing. If the receiever requires a pairing to read and write the BASS characteristics, then you might have to do the pairing outside of the app before connecting.\
The app will show the sources that are listed in the receive states.\
Tap on a source to sync or unsync it.
