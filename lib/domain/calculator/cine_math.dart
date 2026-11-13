import '../core/units.dart';

/// Resultado de una expresión de calculadora de cine.
class CalcResult {
  /// Valor numérico.
  final double value;

  /// Resultado con coma decimal, listo para mostrar.
  final String display;

  /// Cuando el resultado es un tiempo, su equivalencia como fracción 1/x.
  final double? shutterFraction;

  /// Cuando el resultado es un tiempo, cuántos pasos representa **respecto de**
  /// 1/48 s (el 180° a 24 fps). Positivo = más luz (obturación más larga).
  final double? stopsFrom48;

  const CalcResult({
    required this.value,
    required this.display,
    this.shutterFraction,
    this.stopsFrom48,
  });
}

/// Calculadora de cine: evalúa expresiones escritas como en el set.
///
/// Acepta `+ - × ÷`, paréntesis, números decimales, las constantes `pi` y `e`,
/// potencias con `^`, y **fracciones** como `1/48`, `3/2` o `(1/48)/2`.
///
/// Además del valor, si el resultado es un tiempo de exposición, devuelve su
/// fracción equivalente y los pasos que representa respecto de 1/48 s.
class CineMath {
  CineMath._();

  /// Tiempo de referencia: 180° a 24 fps.
  static const double referenceShutterSeconds = 1 / 48;

  /// Evalúa una expresión. Devuelve `null` si no se puede.
  static CalcResult? evaluate(String expression, {bool treatAsTime = false}) {
    final value = _parse(expression);
    if (value == null || !value.isFinite) return null;
    return build(value, treatAsTime: treatAsTime);
  }

  /// Construye el resultado a partir de un valor ya calculado.
  static CalcResult build(double value, {bool treatAsTime = false}) {
    final isTime = treatAsTime || (value > 0 && value < 1);
    if (isTime && value > 0) {
      return CalcResult(
        value: value,
        display: formatNumber(value),
        shutterFraction: _fraction(value),
        stopsFrom48: DMath.log2(value / referenceShutterSeconds),
      );
    }
    return CalcResult(value: value, display: formatNumber(value));
  }

  /// Número sin ceros de más: "48", "4.5", "0.0208".
  static String formatNumber(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e9) {
      return value.toStringAsFixed(0);
    }
    final text = value.toStringAsFixed(4).replaceFirst(RegExp(r'0+$'), '');
    return text.endsWith('.') ? text.substring(0, text.length - 1) : text;
  }

  /// Convierte un tiempo en la fracción más próxima del tipo 1/48.
  static double _fraction(double seconds) {
    final den = 1 / seconds;
    // Ajustamos a la fracción simple más cercana con denominador entero.
    return den.roundToDouble();
  }

  /// Inversa de un número (la tecla 1/x).
  static CalcResult reciprocal(double value) =>
      build(1 / value);

  // ------------------------------------------------------------- parser ---

  static double? _parse(String input) {
    final tokens = _tokenize(input);
    if (tokens == null || tokens.isEmpty) return null;
    final parser = _Parser(tokens);
    final value = parser.parseExpression();
    if (value == null || parser.index != tokens.length) return null;
    return value;
  }

  static List<String>? _tokenize(String input) {
    final s = input
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll(',', '.')
        .replaceAll(' ', '');
    if (s.isEmpty) return null;

    final tokens = <String>[];
    final buffer = StringBuffer();

    void flush() {
      if (buffer.isNotEmpty) {
        tokens.add(buffer.toString());
        buffer.clear();
      }
    }

    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      if ('0123456789.'.contains(c)) {
        buffer.write(c);
      } else if ('+-*/^()'.contains(c)) {
        flush();
        tokens.add(c);
      } else if (RegExp(r'[a-zA-Z]').hasMatch(c)) {
        buffer.write(c);
      } else {
        return null;
      }
    }
    flush();
    return tokens;
  }
}

/// Parser descendente simple: suma/resta → producto/división → potencia → unario.
class _Parser {
  final List<String> tokens;
  int index = 0;

  _Parser(this.tokens);

  String? get _peek => index < tokens.length ? tokens[index] : null;

  double? parseExpression() {
    var left = _parseTerm();
    if (left == null && left != 0) return null;
    while (_peek == '+' || _peek == '-') {
      final op = tokens[index++];
      final right = _parseTerm();
      if (right == null) return null;
      left = op == '+' ? left! + right : left! - right;
    }
    return left;
  }

  double? _parseTerm() {
    var left = _parsePower();
    if (left == null) return null;
    while (_peek == '*' || _peek == '/') {
      final op = tokens[index++];
      final right = _parsePower();
      if (right == null) return null;
      if (op == '/' && right == 0) return null;
      left = op == '*' ? left! * right : left! / right;
    }
    return left;
  }

  double? _parsePower() {
    final base = _parseUnary();
    if (base == null) return null;
    if (_peek == '^') {
      index++;
      final exponent = _parsePower();
      if (exponent == null) return null;
      var result = 1.0;
      for (var i = 0; i < exponent.abs().round(); i++) {
        result *= base;
      }
      return exponent < 0 ? 1 / result : result;
    }
    return base;
  }

  double? _parseUnary() {
    if (_peek == '-') {
      index++;
      final v = _parseUnary();
      return v == null ? null : -v;
    }
    return _parsePrimary();
  }

  double? _parsePrimary() {
    final token = _peek;
    if (token == null) return null;
    if (token == '(') {
      index++;
      final v = parseExpression();
      if (v == null) return null;
      if (_peek != ')') return null;
      index++;
      return v;
    }
    index++;
    if (token == 'pi') return 3.141592653589793;
    if (token == 'e') return 2.718281828459045;
    return double.tryParse(token);
  }
}
