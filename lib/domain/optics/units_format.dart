/// Formatea distancias como las diría alguien en el set: "35 cm", "1,20 m".
///
/// En fotografía nadie dice "0,35 metros": se dice 35 centímetros.
String formatDistance({
  required double millimetres,
  bool useFeet = false,
  double feetPerMetre = 3.28084,
}) {
  if (!millimetres.isFinite || millimetres > 1e7) return 'INFINITO';
  final metres = millimetres / 1000;

  if (useFeet) {
    final feet = metres * feetPerMetre;
    if (feet < 1) {
      final inches = feet * 12;
      return '${inches.toStringAsFixed(0)} in';
    }
    return '${feet.toStringAsFixed(2)} ft';
  }

  if (metres < 1) {
    return '${(metres * 100).toStringAsFixed(0)} cm';
  }
  return '${metres.toStringAsFixed(2)} m';
}
