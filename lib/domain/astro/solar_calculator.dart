import 'dart:math' as math;

/// Posición del sol en un momento y lugar.
class SunPosition {
  /// Altura sobre el horizonte, en grados. Negativo = sol debajo.
  final double altitudeDegrees;

  /// Acimut desde el norte, en grados (0 = N, 90 = E, 180 = S, 270 = O).
  final double azimuthDegrees;

  /// Si el sol está sobre el horizonte.
  final bool isUp;

  const SunPosition({
    required this.altitudeDegrees,
    required this.azimuthDegrees,
    required this.isUp,
  });

  /// Punto cardinal aproximado del acimut.
  String get cardinal {
    const names = ['N', 'NE', 'E', 'SE', 'S', 'SO', 'O', 'NO'];
    final index = ((azimuthDegrees + 22.5) / 45).floor() % 8;
    return names[index];
  }
}

/// Un evento solar del día.
class SolarEvent {
  final DateTime time;
  final String label;

  const SolarEvent({required this.time, required this.label});
}

/// Ventana de luz útil para rodar.
class LightWindow {
  final String label;
  final DateTime start;
  final DateTime end;

  const LightWindow({required this.label, required this.start, required this.end});

  Duration get duration => end.difference(start);
}

/// Cálculo solar para un día y un lugar.
///
/// Algoritmo estándar de posición solar (fórmulas de NOAA):
/// día juliano → declinación y ecuación del tiempo → ángulo horario →
/// altura y acimut. Precisión típica de ±1 minuto en los eventos del día,
/// suficiente para planificar un rodaje.
class SolarCalculator {
  SolarCalculator._();

  /// Altura del sol (grados) en la que ubicamos cada evento.
  static const double sunriseAltitude = -0.833;
  static const double civilDawnAltitude = -6;
  static const double goldenHourAltitude = 6;

  /// Posición del sol.
  ///
  /// [when] se interpreta como hora UTC. Convertir antes con
  /// `when.toUtc()`, así el resultado no depende de la zona del teléfono.
  static SunPosition position({
    required DateTime when,
    required double latitude,
    required double longitude,
  }) {
    final utc = when.toUtc();
    final days = _daysSinceJ2000(utc);
    final declination = _declination(days);
    final equationOfTime = _equationOfTime(days);

    final minutes = utc.hour * 60 + utc.minute + utc.second / 60;
    var trueSolarTime = minutes + equationOfTime + 4 * longitude;
    trueSolarTime = trueSolarTime % 1440;

    var hourAngle = trueSolarTime / 4 - 180;
    if (hourAngle < -180) hourAngle += 360;

    return _positionFromHourAngle(
      latitude: latitude,
      declination: declination,
      hourAngle: hourAngle,
    );
  }

  static SunPosition _positionFromHourAngle({
    required double latitude,
    required double declination,
    required double hourAngle,
  }) {
    final lat = _rad(latitude);
    final dec = _rad(declination);
    final ha = _rad(hourAngle);

    final sinAltitude =
        math.sin(lat) * math.sin(dec) + math.cos(lat) * math.cos(dec) * math.cos(ha);
    final altitude = math.asin(sinAltitude.clamp(-1.0, 1.0));

    final cosAzimuth =
        (math.sin(dec) - math.sin(altitude) * math.sin(lat)) /
            (math.cos(altitude) * math.cos(lat));
    var azimuth = math.acos(cosAzimuth.clamp(-1.0, 1.0));
    if (math.sin(ha) > 0) {
      azimuth = 2 * math.pi - azimuth;
    }

    return SunPosition(
      altitudeDegrees: _deg(altitude),
      azimuthDegrees: _deg(azimuth),
      isUp: _deg(altitude) > sunriseAltitude,
    );
  }

  /// Hora (en UTC) en la que el sol cruza una altura dada.
  ///
  /// [rising] elige el cruce de la mañana o el de la tarde. Devuelve `null`
  /// si ese día el sol no alcanza esa altura (noche polar o invierno extremo).
  static DateTime? crossing({
    required DateTime day,
    required double latitude,
    required double longitude,
    required double altitude,
    required bool rising,
  }) {
    final utc = day.toUtc();
    final days = _daysSinceJ2000(utc);
    final declination = _declination(days);
    final equationOfTime = _equationOfTime(days);

    final cosHa = (math.sin(_rad(altitude)) - math.sin(_rad(latitude)) * math.sin(_rad(declination))) /
        (math.cos(_rad(latitude)) * math.cos(_rad(declination)));
    if (cosHa > 1 || cosHa < -1) return null;

    // Ángulo horario positivo = sol de la tarde. La mañana es el negativo.
    var hourAngle = -_deg(math.acos(cosHa));
    if (!rising) hourAngle = -hourAngle;

    // Forma cerrada de la NOAA: de ángulo horario a hora UTC del día.
    var minutes = 720 - 4 * (longitude + hourAngle) - equationOfTime;
    minutes = minutes % 1440;
    if (minutes < 0) minutes += 1440;

    final base = DateTime.utc(utc.year, utc.month, utc.day);
    return base.add(Duration(seconds: (minutes * 60).round()));
  }

  /// Amanecer, atardecer y ventanas de luz dorada en hora local.
  static List<SolarEvent> events({
    required DateTime day,
    required double latitude,
    required double longitude,
    required Duration utcOffset,
  }) {
    DateTime? local(DateTime? utc) => utc?.toUtc().add(utcOffset);

    final result = <SolarEvent>[];
    void add(DateTime? utcDate, String label) {
      final t = local(utcDate);
      if (t != null) result.add(SolarEvent(time: t, label: label));
    }

    add(crossing(day: day, latitude: latitude, longitude: longitude, altitude: civilDawnAltitude, rising: false), 'INICIO DEL AZUL');
    add(crossing(day: day, latitude: latitude, longitude: longitude, altitude: sunriseAltitude, rising: false), 'AMANECER');
    add(crossing(day: day, latitude: latitude, longitude: longitude, altitude: goldenHourAltitude, rising: false), 'FIN DE LA DORADA (MAÑANA)');
    add(crossing(day: day, latitude: latitude, longitude: longitude, altitude: goldenHourAltitude, rising: true), 'INICIO DE LA DORADA (TARDE)');
    add(crossing(day: day, latitude: latitude, longitude: longitude, altitude: sunriseAltitude, rising: true), 'ATARDECER');
    add(crossing(day: day, latitude: latitude, longitude: longitude, altitude: civilDawnAltitude, rising: true), 'FIN DEL AZUL');

    result.sort((a, b) => a.time.compareTo(b.time));
    return result;
  }

  /// Ventanas de luz: azul de la mañana, dorada de la mañana, dorada de la
  /// tarde y azul de la tarde.
  static List<LightWindow> windows({
    required DateTime day,
    required double latitude,
    required double longitude,
    required Duration utcOffset,
  }) {
    DateTime? local(DateTime? utc) => utc?.toUtc().add(utcOffset);
    DateTime? c(double alt, bool rising) => local(crossing(
          day: day,
          latitude: latitude,
          longitude: longitude,
          altitude: alt,
          rising: rising,
        ));

    // El cálculo devuelve el cruce de la madrugada con `rising: false`
    // (ángulo horario negativo) y el de la tarde con `rising: true`.
    final dawn = c(civilDawnAltitude, false);
    final sunrise = c(sunriseAltitude, false);
    final morningEnd = c(goldenHourAltitude, false);
    final afternoonStart = c(goldenHourAltitude, true);
    final sunset = c(sunriseAltitude, true);
    final dusk = c(civilDawnAltitude, true);

    final blueAM = (dawn, sunrise);
    final goldenAM = (sunrise, morningEnd);
    final goldenPM = (afternoonStart, sunset);
    final bluePM = (sunset, dusk);

    final list = <LightWindow>[];
    void add(String label, (DateTime?, DateTime?) range) {
      if (range.$1 != null && range.$2 != null) {
        list.add(LightWindow(label: label, start: range.$1!, end: range.$2!));
      }
    }

    add('AZUL DE LA MAÑANA', blueAM);
    add('DORADA DE LA MAÑANA', goldenAM);
    add('DORADA DE LA TARDE', goldenPM);
    add('AZUL DE LA TARDE', bluePM);
    return list;
  }

  // ---------------------------------------------------------- astronomía ---

  static double _daysSinceJ2000(DateTime utc) {
    final base = DateTime.utc(2000, 1, 1, 12);
    final diff = utc.difference(base);
    return diff.inMilliseconds / Duration.millisecondsPerDay;
  }

  static double _declination(double days) {
    final meanLongitude = (280.46646 + 0.98564736 * days) % 360;
    final meanAnomaly = _rad(357.52911 + 0.98560028 * days);
    final lambda = meanLongitude + 1.914602 * math.sin(meanAnomaly) + 0.019993 * math.sin(2 * meanAnomaly) + 0.000289 * math.sin(3 * meanAnomaly);
    final obliquity = 23.439291 - 0.00000036 * days;
    final sinDec = math.sin(_rad(obliquity)) * math.sin(_rad(lambda));
    return _deg(math.asin(sinDec));
  }

  static double _equationOfTime(double days) {
    final meanLongitude = (280.46646 + 0.98564736 * days) % 360;
    final y = math.pow(_rad(obliquityT(days)), 2).toDouble();
    final l0 = _rad(meanLongitude);
    final e = 0.016708634;
    final m = _rad(357.52911 + 0.98560028 * days);
    return 4 * _deg(
      y * math.sin(2 * l0) -
          2 * e * math.sin(m) +
          4 * e * y * math.sin(m) * math.cos(2 * l0) -
          0.5 * y * y * math.sin(4 * l0) -
          1.25 * e * e * math.sin(2 * m),
    );
  }

  static double obliquityT(double days) => 23.439291 - 0.00000036 * days;

  static double _rad(double deg) => deg * math.pi / 180;
  static double _deg(double rad) => rad * 180 / math.pi;
}
