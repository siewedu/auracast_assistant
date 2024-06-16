import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class MacAddress extends Equatable {
  const MacAddress._(Uint8List bytes) : _bytes = bytes;

  factory MacAddress.fromBytes(List<int> bytes) {
    if (bytes.length != 6) {
      throw MacAddressParseException(
        'Invalid MAC address length ${bytes.length}, should be 6 bytes',
      );
    }

    return MacAddress._(Uint8List.fromList(bytes));
  }

  factory MacAddress.parseString(String string) {
    final regex = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
    if (!regex.hasMatch(string)) {
      throw MacAddressParseException('Invalid MAC address format: $string');
    }

    final bytes = Uint8List(6);
    final parts = string.split(RegExp('[:-]'));
    for (var i = 0; i < 6; i++) {
      bytes[i] = int.parse(parts[i], radix: 16);
    }

    return MacAddress._(bytes);
  }

  final Uint8List _bytes;
  Uint8List get bytes => Uint8List.fromList(_bytes);

  @override
  String toString() => _bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join(':')
      .toUpperCase();

  @override
  List<Object?> get props => [_bytes];
}

class MacAddressParseException implements Exception {
  const MacAddressParseException(this.message);

  final String message;

  @override
  String toString() => 'MacAddressParseException: $message';
}
