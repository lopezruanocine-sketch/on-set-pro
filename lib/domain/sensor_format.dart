import 'dart:math';

class SensorFormat {
  final String name;
  final double widthMm;
  final double heightMm;

  // Constructor de la "molde" del sensor
  const SensorFormat({
    required this.name,
    required this.widthMm,
    required this.heightMm,
  });

  // Calcula la diagonal usando el Teorema de Pitágoras
  double get diagonalMm {
    return sqrt((widthMm * widthMm) + (heightMm * heightMm));
  }

  // Calcula el Círculo de Confusión usando el Estándar de Cine (Zeiss)
  double get cocMm {
    return diagonalMm / 1500.0;
  }

  // --- BASE DE DATOS DE FORMATOS ESTÁNDAR ---
  // (Aquí podemos agregar todas las cámaras que quieras después)
  static const List<SensorFormat> standardFormats = [
    SensorFormat(name: 'Full Frame (35mm Fotográfico)', widthMm: 36.0, heightMm: 24.0),
    SensorFormat(name: 'Super 35 (Cine Estándar)', widthMm: 24.89, heightMm: 18.66),
    SensorFormat(name: 'ARRI Alexa 35', widthMm: 27.99, heightMm: 19.22),
    SensorFormat(name: 'ARRI Alexa Mini LF', widthMm: 36.70, heightMm: 25.54),
    SensorFormat(name: 'RED V-Raptor 8K VV', widthMm: 40.96, heightMm: 21.60),
    SensorFormat(name: 'Super 16mm', widthMm: 12.52, heightMm: 7.41),
    SensorFormat(name: 'Micro 4/3', widthMm: 17.30, heightMm: 13.00),
  ];
}