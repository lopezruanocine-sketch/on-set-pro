import 'package:flutter/material.dart';

import '../data/catalogs/codecs.dart';
import '../data/catalogs/film_formats.dart';
import '../domain/storage/storage_engine.dart';
import '../state/shot_state.dart';
import '../theme/app_theme.dart';

/// Data y almacenamiento (digital) o chasis y metraje (fílmicо).
class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  // --- digital ---
  String? codec;
  String? resolution;
  double fps = 24;
  bool byTime = false; // false = tengo GB; true = necesito minutos
  double capacityGb = 512;
  double minutesNeeded = 30;
  double readMBps = 1000;
  double writeMBps = 500;

  // --- fílmico ---
  String? filmFormat;
  double magFeet = 400;
  double consumedFeet = 0;
  double filmFps = 24;

  static const List<double> _commonFps = [23.976, 24, 25, 29.97, 30, 48, 50, 59.94, 60, 120];

  @override
  void initState() {
    super.initState();
    // Arranca con el primer códec del catálogo y su primera resolución, para
    // que la pantalla nunca abra mostrando ceros.
    codec = Codecs.codecNames.isEmpty ? null : Codecs.codecNames.first;
    final resolutions = _resolutions;
    resolution = resolutions.isEmpty ? null : resolutions.first;
    final options = _fpsOptions();
    final shotFps = ShotState.instance.camera == null ? 24.0 : ShotState.instance.fps;
    fps = options.contains(shotFps) ? shotFps : (options.isEmpty ? 24 : options.first);
    filmFormat = ShotState.instance.camera?.filmFormat;
  }

  @override
  Widget build(BuildContext context) {
    final selection = ShotState.instance.camera;
    final isFilm = selection?.isFilm ?? false;

    return Scaffold(
      backgroundColor: OnSetColors.background,
      appBar: AppBar(
        backgroundColor: OnSetColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          isFilm ? 'CHASIS / METRAJE' : 'DATA / ALMACENAMIENTO',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
            fontSize: 14,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: isFilm ? _filmBody(selection?.filmFormat) : _digitalBody(),
      ),
    );
  }

  // ------------------------------------------------------------- digital ---

  String? get _codecName {
    if (codec != null) return codec;
    final names = Codecs.codecNames;
    return names.isEmpty ? null : names.first;
  }

  List<String> get _resolutions {
    final c = _codecName;
    if (c == null) return const [];
    final seen = <String>[];
    for (final r in Codecs.of(c)) {
      if (!seen.contains(r.resolution)) seen.add(r.resolution);
    }
    return seen;
  }

  CodecRate? get _rate {
    final c = _codecName;
    final r = resolution;
    if (c == null || r == null) return null;
    final exact = Codecs.find(c, r, fps);
    if (exact != null) return exact;
    // Si no hay fila exacta, se escala linealmente desde el fps más cercano.
    final candidates = Codecs.of(c).where((x) => x.resolution == r).toList();
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => (a.fps - fps).abs().compareTo((b.fps - fps).abs()));
    final base = candidates.first;
    return CodecRate(
      codec: base.codec,
      resolution: base.resolution,
      fps: fps,
      mbps: base.mbps * fps / base.fps,
      notes: 'calculado desde ${base.fps.toStringAsFixed(0)} fps',
    );
  }

  Widget _digitalBody() {
    final rate = _rate;
    final mbps = rate?.mbps ?? 0;

    final gbPerHour = StorageEngine.gigabytesPerHour(mbps);
    final recording = StorageEngine.recording(
      mbps: mbps,
      capacityGb: capacityGb,
      overhead: 0.05,
    );
    final neededGb = StorageEngine.gigabytesForMinutes(
      mbps: mbps,
      minutes: minutesNeeded,
    );
    final copy = StorageEngine.copyTime(
      gigabytes: byTime ? neededGb : capacityGb,
      readMbps: readMBps,
      writeMbps: writeMBps,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('CÓDEC'),
        _dropdown(
          'FAMILIA',
          _codecName,
          Codecs.codecNames,
          (v) => setState(() {
            codec = v;
            resolution = null;
          }),
        ),
        const SizedBox(height: 12),
        _dropdown(
          'RESOLUCIÓN',
          resolution,
          _resolutions,
          (v) => setState(() => resolution = v),
        ),
        const SizedBox(height: 12),
        _numberDropdown(
          'FPS',
          _fpsOption(fps),
          _fpsOptions(),
          (v) => setState(() => fps = v),
        ),
        if (rate != null) ...[
          const SizedBox(height: 10),
          Text(
            '${rate.mbps.toStringAsFixed(0)} Mbps · '
            '${rate.megabytesPerSecond.toStringAsFixed(1)} MB/s · '
            '${gbPerHour.toStringAsFixed(1)} GB/h'
            '${rate.fps != fps ? ' (escalado)' : ''}',
            style: const TextStyle(fontSize: 10, color: Colors.white54),
          ),
        ],
        const SizedBox(height: 25),
        _toggleRow([
          ('TENGO ESTOS GB', !byTime, () => setState(() => byTime = false)),
          ('NECESITO MINUTOS', byTime, () => setState(() => byTime = true)),
        ]),
        const SizedBox(height: 15),
        if (!byTime)
          _numberInput('CAPACIDAD DEL SOPORTE (GB)', capacityGb, (v) => setState(() => capacityGb = v))
        else
          _numberInput('MINUTOS A GRABAR', minutesNeeded, (v) => setState(() => minutesNeeded = v)),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Column(
            children: [
              Text(
                byTime ? 'ESPACIO NECESARIO' : 'TIEMPO QUE ENTRA',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                byTime
                    ? '${neededGb.toStringAsFixed(1)} GB'
                    : StorageEngine.formatDuration(recording.duration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                byTime
                    ? 'Para ${minutesNeeded.toStringAsFixed(0)} minutos a esta tasa.'
                    : 'Descontando 5 % de overhead del sistema de archivos.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        _sectionTitle('COPIA (DIT)'),
        Row(
          children: [
            Expanded(
              child: _numberDropdown(
                'LECTURA (MB/s)',
                _speedOption(readMBps),
                _speedOptions(),
                (v) => setState(() => readMBps = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _numberDropdown(
                'ESCRITURA (MB/s)',
                _speedOption(writeMBps),
                _speedOptions(),
                (v) => setState(() => writeMBps = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: OnSetColors.surface,
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TIEMPO DE COPIA (25 % de overhead)',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    StorageEngine.formatDuration(copy.duration),
                    style: const TextStyle(
                      color: OnSetColors.brand,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              Text(
                '${copy.effectiveMegabytesPerSecond.toStringAsFixed(0)} MB/s',
                style: const TextStyle(fontSize: 10, color: Colors.white38),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<double> _fpsOptions() {
    final c = _codecName;
    final r = resolution;
    final set = <double>{..._commonFps};
    if (c != null && r != null) {
      for (final rate in Codecs.of(c).where((x) => x.resolution == r)) {
        set.add(rate.fps);
      }
    }
    final list = set.toList()..sort();
    return list;
  }

  double _fpsOption(double value) {
    final options = _fpsOptions();
    return options.contains(value) ? value : options.first;
  }

  static const List<double> _speeds = [130, 250, 500, 1000, 2000, 3000];

  List<double> _speedOptions() => _speeds;

  double _speedOption(double value) => _speeds.contains(value) ? value : 500;

  // ------------------------------------------------------------- fílmico ---

  Widget _filmBody(String? selectedFilm) {
    final formatName = filmFormat ?? selectedFilm ?? FilmFormats.all.first.name;
    final format = FilmFormats.byName(formatName) ?? FilmFormats.all.first;

    final fpm = format.feetPerMinute * (filmFps / 24);
    final remainingFeet = (magFeet - consumedFeet).clamp(0.0, double.infinity);
    final remainingMinutes = fpm <= 0 ? 0.0 : remainingFeet / fpm;
    final totalMinutes = fpm <= 0 ? 0.0 : magFeet / fpm;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Column(
            children: [
              const Text(
                'TIEMPO RESTANTE EN CHASIS',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                StorageEngine.formatDuration(
                  Duration(seconds: (remainingMinutes * 60).round()),
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${remainingFeet.toStringAsFixed(0)} pies restantes · '
                '${fpm.toStringAsFixed(1)} ft/min a ${filmFps.toStringAsFixed(0)} fps',
                style: const TextStyle(fontSize: 10, color: Colors.white54),
              ),
              const SizedBox(height: 6),
              Text(
                'El chasis completo son ${StorageEngine.formatDuration(Duration(seconds: (totalMinutes * 60).round()))}',
                style: const TextStyle(fontSize: 10, color: Colors.white38),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _sectionTitle('FORMATO'),
        _dropdown(
          'FORMATO FÍLMICO',
          formatName,
          FilmFormats.all.map((f) => f.name).toList(),
          (v) => setState(() => filmFormat = v),
        ),
        const SizedBox(height: 10),
        Text(
          '${format.widthMm} × ${format.heightMm} mm · '
          '${format.perfsPerFrame} perfs · CoC ${format.cocMm} mm',
          style: const TextStyle(fontSize: 10, color: Colors.white38),
        ),
        const SizedBox(height: 22),
        _sectionTitle('ESTADO DEL CHASIS'),
        Row(
          children: [
            Expanded(
              child: _numberInput('TAMAÑO (pies)', magFeet, (v) => setState(() => magFeet = v)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _numberInput('CONSUMIDO (pies)', consumedFeet, (v) => setState(() => consumedFeet = v)),
            ),
          ],
        ),
        const SizedBox(height: 15),
        _numberInput('FOTOGRAMAS POR SEGUNDO', filmFps, (v) => setState(() => filmFps = v)),
        const SizedBox(height: 12),
        _magChips(),
      ],
    );
  }

  Widget _magChips() {
    const mags = [100.0, 400.0, 1000.0];
    return Row(
      children: [
        for (final m in mags) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => magFeet = m),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: (magFeet - m).abs() < 0.5
                      ? OnSetColors.surfaceHigh
                      : Colors.transparent,
                  border: Border.all(
                    color: (magFeet - m).abs() < 0.5 ? Colors.white24 : Colors.white10,
                  ),
                ),
                child: Text(
                  '${m.toStringAsFixed(0)} ft',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: (magFeet - m).abs() < 0.5 ? Colors.white : Colors.white38,
                  ),
                ),
              ),
            ),
          ),
          if (m != mags.last) const SizedBox(width: 8),
        ],
      ],
    );
  }

  // ------------------------------------------------------------- widgets ---

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      );

  Widget _toggleRow(List<(String, bool, VoidCallback)> options) {
    return Container(
      height: 45,
      decoration: BoxDecoration(border: Border.all(color: Colors.white24)),
      child: Row(
        children: options
            .map((o) => Expanded(
                  child: GestureDetector(
                    onTap: o.$3,
                    child: Container(
                      color: o.$2 ? OnSetColors.surfaceHigh : Colors.transparent,
                      alignment: Alignment.center,
                      child: Text(
                        o.$1,
                        style: TextStyle(
                          color: o.$2 ? Colors.white : Colors.white38,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String? value,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: OnSetColors.surface,
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : null,
              isExpanded: true,
              hint: const Text('Elegí', style: TextStyle(color: Colors.white38, fontSize: 13)),
              dropdownColor: OnSetColors.surfaceHigh,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: options
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, style: const TextStyle(color: Colors.white, fontSize: 13)),
                      ))
                  .toList(),
              onChanged: (v) => onChanged(v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _numberInput(String label, double value, Function(double) onChanged) {
    return _StorageField(label: label, value: value, onChanged: onChanged);
  }

  Widget _numberDropdown(
    String label,
    double value,
    List<double> options,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: OnSetColors.surface,
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<double>(
              value: options.contains(value) ? value : (options.isEmpty ? null : options.first),
              isExpanded: true,
              dropdownColor: OnSetColors.surfaceHigh,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: options
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e == e.roundToDouble() ? e.toStringAsFixed(0) : e.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ))
                  .toList(),
              onChanged: (v) => onChanged(v!),
            ),
          ),
        ),
      ],
    );
  }
}

class _StorageField extends StatefulWidget {
  final String label;
  final double value;
  final Function(double) onChanged;

  const _StorageField({required this.label, required this.value, required this.onChanged});

  @override
  State<_StorageField> createState() => _StorageFieldState();
}

class _StorageFieldState extends State<_StorageField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value == widget.value.roundToDouble()
        ? widget.value.toInt().toString()
        : widget.value.toString(),
  );

  @override
  void didUpdateWidget(covariant _StorageField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (double.tryParse(_controller.text) != widget.value) {
      _controller.text = widget.value == widget.value.roundToDouble()
          ? widget.value.toInt().toString()
          : widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: OnSetColors.surface,
            border: Border.all(color: Colors.white24),
          ),
          child: TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'monospace'),
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: (v) {
              final n = double.tryParse(v);
              if (n != null) widget.onChanged(n);
            },
          ),
        ),
      ],
    );
  }
}
