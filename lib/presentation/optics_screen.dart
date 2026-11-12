import 'package:flutter/material.dart';
import 'dart:math' as math;

class OpticsScreen extends StatefulWidget {
  final String sensorName; // El sensor de origen (A-Cam)

  const OpticsScreen({super.key, required this.sensorName});

  @override
  State<OpticsScreen> createState() => _OpticsScreenState();
}

class _OpticsScreenState extends State<OpticsScreen> {
  // --- ESTADO: LENTE Y DISTANCIA ---
  double focalLengthMm = 50.0; // Lente base en A-Cam
  double distanceMeters = 5.0; // Distancia al sujeto

  // --- ESTADO: SENSORES ---
  late String targetSensorName; // Sensor destino (B-Cam)

  // Base de datos: Tamaños de Sensor (Ancho x Alto en mm)
  final Map<String, Size> sensorSizes = {
    'Full Frame (36x24)': const Size(36.0, 24.0),
    'Súper 35 (24.9x18.7)': const Size(24.9, 18.7), // ARRI Alexa estándar
    'APS-C (23.5x15.6)': const Size(23.5, 15.6), // Sony/Fuji crop
    'Micro 4/3 (17.3x13)': const Size(17.3, 13.0),
  };

  @override
  void initState() {
    super.initState();
    // Por defecto, el sensor destino es diferente al origen para que el cálculo tenga sentido
    targetSensorName = sensorSizes.keys.firstWhere(
      (name) => name != widget.sensorName,
      orElse: () => sensorSizes.keys.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. MATEMÁTICAS DE ORIGEN (A-CAM)
    Size sourceSize = sensorSizes[widget.sensorName] ?? const Size(36.0, 24.0);
    double sensorDiagonal = math.sqrt(
      sourceSize.width * sourceSize.width +
          sourceSize.height * sourceSize.height,
    );

    // Cálculo de FOV (Campo de Visión) en Grados
    // Fórmula: 2 * arctan(sensorDimension / (2 * focalLength))
    double fovHorizontalRad =
        2 * math.atan(sourceSize.width / (2 * focalLengthMm));
    double fovVerticalRad =
        2 * math.atan(sourceSize.height / (2 * focalLengthMm));
    double fovDiagonalDeg =
        (2 * math.atan(sensorDiagonal / (2 * focalLengthMm))) * (180 / math.pi);

    // Cálculo de Dimensiones del Encuadre a la distancia dada
    // Fórmula: 2 * distancia * tan(fovRad / 2)
    double frameWidthMeters =
        2 * distanceMeters * math.tan(fovHorizontalRad / 2);
    double frameHeightMeters =
        2 * distanceMeters * math.tan(fovVerticalRad / 2);

    // 2. MATEMÁTICAS DE DESTINO (B-CAM - LENS MATCHER)
    Size targetSize = sensorSizes[targetSensorName]!;
    double targetDiagonal = math.sqrt(
      targetSize.width * targetSize.width +
          targetSize.height * targetSize.height,
    );
    // Factor de recorte relativo entre los dos sensores
    double cropFactorRelative = targetDiagonal / sensorDiagonal;
    // Lente equivalente = Lente Origen * Factor Relativo
    double equivalentFocalLength = focalLengthMm * cropFactorRelative;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          "ÓPTICA / FOV",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- ILUSTRACIÓN DINÁMICA (FOV VISUALIZER) ---
            Container(
              height: 200,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: CustomPaint(
                painter: FOVPainter(
                  fovHorizontalRad: fovHorizontalRad,
                  distanceMeters: distanceMeters,
                  frameWidthMeters: frameWidthMeters,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- RESULTADOS DEL ENCUADRE (A-CAM) ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    "TAMAÑO DEL ENCUADRE (A la distancia)",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "${frameWidthMeters.toStringAsFixed(2)}m  x  ${frameHeightMeters.toStringAsFixed(2)}m",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Container(height: 1, color: Colors.white24),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat(
                        "FOV HORIZONTAL",
                        "${(fovHorizontalRad * (180 / math.pi)).toStringAsFixed(1)}°",
                      ),
                      _buildMiniStat(
                        "FOV VERTICAL",
                        "${(fovVerticalRad * (180 / math.pi)).toStringAsFixed(1)}°",
                      ),
                      _buildMiniStat(
                        "FOV DIAGONAL",
                        "${fovDiagonalDeg.toStringAsFixed(1)}°",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- CONTROLES DE LENTE Y DISTANCIA ---
            _buildSectionTitle(
              "CONFIGURACIÓN DE A-CAM (${widget.sensorName.split(' ')[0].toUpperCase()})",
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInput(
                    "LENTE (mm)",
                    focalLengthMm,
                    (v) => setState(() => focalLengthMm = v),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildInput(
                    "DISTANCIA (m)",
                    distanceMeters,
                    (v) => setState(() => distanceMeters = v),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // --- LENS MATCHER (EQUIVALENCIA B-CAM) ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                border: Border.all(color: const Color(0xFFFFD700), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "LENS MATCHER (EQUIVALENCIA B-CAM)",
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown(
                    "SENSOR DESTINO (B-CAM)",
                    targetSensorName,
                    sensorSizes.keys.toList(),
                    (v) => setState(() => targetSensorName = v),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "LENTE EQUIVALENTE NECESARIO",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${equivalentFocalLength.toStringAsFixed(1)} mm",
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Factor de Recorte Relativo: ${(1 / cropFactorRelative).toStringAsFixed(2)}x",
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w300,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 8,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildInput(String label, double val, Function(double) onChanged) {
    TextEditingController ctrl = TextEditingController(
      text: val.toInt().toString(),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'monospace',
            ),
            decoration: const InputDecoration(border: InputBorder.none),
            onSubmitted: (v) {
              double? n = double.tryParse(v);
              if (n != null) onChanged(n);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String val,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: val,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E1E1E),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: options
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => onChanged(v!),
            ),
          ),
        ),
      ],
    );
  }
}

// --- PINTOR DE LA ILUSTRACIÓN DINÁMICA (FOV) ---
class FOVPainter extends CustomPainter {
  final double fovHorizontalRad;
  final double distanceMeters;
  final double frameWidthMeters;

  FOVPainter({
    required this.fovHorizontalRad,
    required this.distanceMeters,
    required this.frameWidthMeters,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final bottomY = size.height - 20; // Posición de la cámara (abajo)

    // 1. Dibujar la Cámara (Icono esquemático)
    final cameraPath = Path();
    cameraPath.moveTo(centerX - 10, bottomY);
    cameraPath.lineTo(centerX + 10, bottomY);
    cameraPath.lineTo(centerX + 15, bottomY + 15);
    cameraPath.lineTo(centerX - 15, bottomY + 15);
    cameraPath.close();
    canvas.drawPath(cameraPath, paint);
    canvas.drawCircle(
      Offset(centerX, bottomY),
      3,
      paint..style = PaintingStyle.fill,
    ); // Lente

    // 2. Calcular el Cono de Visión
    // Usamos una escala visual: 1 metro real = X pixeles en pantalla
    // Limitamos la distancia visual máxima para que no se salga del canvas
    double maxVisualDistance = size.height - 40;
    double visualScale = maxVisualDistance / math.max(distanceMeters, 1.0);
    double visualDistance = distanceMeters * visualScale;

    // El ancho visual del cono depende del ángulo FOV
    double visualHalfWidth = visualDistance * math.tan(fovHorizontalRad / 2);
    double topY = bottomY - visualDistance;

    // 3. Dibujar el Cono de Visión (Triángulo)
    final fovPath = Path();
    fovPath.moveTo(centerX, bottomY); // Vértice en la cámara
    fovPath.lineTo(
      centerX - visualHalfWidth,
      topY,
    ); // Esquina superior izquierda
    fovPath.lineTo(centerX + visualHalfWidth, topY); // Esquina superior derecha
    fovPath.close();
    canvas.drawPath(fovPath, paint);
    canvas.drawPath(fovPath, fillPaint); // Relleno transparente

    // 4. Dibujar el Encuadre (Rectángulo en el plano de enfoque)
    canvas.drawLine(
      Offset(centerX - visualHalfWidth, topY),
      Offset(centerX + visualHalfWidth, topY),
      paint..strokeWidth = 3,
    );

    // 5. Dibujar un Sujeto Esquemático (Referencia de escala)
    // La altura del sujeto es proporcional al ancho del encuadre
    double subjectHeight =
        (1.7 / frameWidthMeters) * (visualHalfWidth * 2); // Sujeto de 1.7m
    if (subjectHeight > 0 && subjectHeight < visualDistance) {
      double subjectY =
          topY + (subjectHeight / 2); // Pies del sujeto en el plano
      canvas.drawCircle(
        Offset(centerX, subjectY - subjectHeight + (subjectHeight / 6)),
        subjectHeight / 6,
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      ); // Cabeza
      canvas.drawLine(
        Offset(centerX, subjectY - subjectHeight + (subjectHeight / 3)),
        Offset(centerX, subjectY),
        paint,
      ); // Cuerpo
      canvas.drawLine(
        Offset(centerX - subjectHeight / 4, subjectY - subjectHeight / 2),
        Offset(centerX + subjectHeight / 4, subjectY - subjectHeight / 2),
        paint,
      ); // Brazos
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
