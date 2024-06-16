import 'dart:typed_data';

extension ShiftBytes on Uint8List {
  /// Converts byte array to integer, in case byte array represents integer.
  int toInteger() {
    var sum = 0;
    var shift = 0;

    for (var i = length - 1; i >= 0;) {
      sum += this[i] << shift;
      shift += 8;
      i -= 1;
    }

    return sum;
  }
}
