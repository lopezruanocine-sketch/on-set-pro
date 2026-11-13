import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/domain/calculator/cine_math.dart';

void main() {
  group('aritmética', () {
    test('suma y resta', () {
      expect(CineMath.evaluate('2+3')!.value, 5);
      expect(CineMath.evaluate('10-4')!.value, 6);
    });

    test('multiplicación y división', () {
      expect(CineMath.evaluate('6*7')!.value, 42);
      expect(CineMath.evaluate('9/3')!.value, 3);
      expect(CineMath.evaluate('6×7')!.value, 42);
    });

    test('divide por cero sin romper', () {
      expect(CineMath.evaluate('1/0'), isNull);
    });

    test('respeta la precedencia', () {
      expect(CineMath.evaluate('2+3*4')!.value, 14);
      expect(CineMath.evaluate('(2+3)*4')!.value, 20);
    });

    test('potencias', () {
      expect(CineMath.evaluate('2^3')!.value, 8);
      expect(CineMath.evaluate('2^-1')!.value, closeTo(0.5, 1e-9));
    });

    test('números negativos y decimales con coma', () {
      expect(CineMath.evaluate('-5+8')!.value, 3);
      expect(CineMath.evaluate('1,5*2')!.value, 3);
    });

    test('rechaza lo que no es una cuenta', () {
      expect(CineMath.evaluate(''), isNull);
      expect(CineMath.evaluate('2+'), isNull);
      expect(CineMath.evaluate('(2+3'), isNull);
      expect(CineMath.evaluate('abc'), isNull);
    });
  });

  group('formatos de cine', () {
    test('1/48 da el valor, la fracción y su relación con 1/48', () {
      final r = CineMath.evaluate('1/48', treatAsTime: true)!;
      expect(r.value, closeTo(0.020833, 1e-6));
      expect(r.shutterFraction, 48);
      expect(r.stopsFrom48, closeTo(0, 1e-9));
    });

    test('1/96 deja la imagen un paso más corta que 1/48', () {
      final r = CineMath.evaluate('1/96', treatAsTime: true)!;
      expect(r.shutterFraction, 96);
      expect(r.stopsFrom48, closeTo(-1, 1e-9));
    });

    test('1/24 es un paso más de luz que 1/48', () {
      final r = CineMath.evaluate('1/24', treatAsTime: true)!;
      expect(r.shutterFraction, 24);
      expect(r.stopsFrom48, closeTo(1, 1e-9));
    });

    test('1/25 está casi un paso por encima de 1/48', () {
      final r = CineMath.evaluate('1/25', treatAsTime: true)!;
      expect(r.stopsFrom48, closeTo(0.942, 0.01));
    });

    test('una cuenta normal no se trata como tiempo', () {
      final r = CineMath.evaluate('2+3')!;
      expect(r.shutterFraction, isNull);
      expect(r.display, '5');
    });

    test('la inversa vuelve a la fracción', () {
      final r = CineMath.reciprocal(48);
      expect(r.value, closeTo(0.020833, 1e-6));
      expect(r.shutterFraction, 48);
    });

    test('formatea sin ceros de más', () {
      expect(CineMath.formatNumber(48), '48');
      expect(CineMath.formatNumber(4.5), '4.5');
      expect(CineMath.formatNumber(0.02083), '0.0208');
    });
  });
}
