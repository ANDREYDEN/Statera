import 'dart:math';

String getRandomLetter() {
  int asciiCode = 97 + Random().nextInt(26);
  return String.fromCharCode(asciiCode);
}

String toStringPrice(double value) {
  return "\$${value.toStringAsFixed(2)}";
}