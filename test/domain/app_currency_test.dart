import 'package:serum_business/serum_business.dart';
import 'package:test/test.dart';

void main() {
  group('AppCurrency', () {
    test('resuelve códigos ISO sin distinguir mayúsculas', () {
      expect(AppCurrency.fromCode('NIO'), AppCurrency.nio);
      expect(AppCurrency.fromCode('usd'), AppCurrency.usd);
      expect(AppCurrency.fromCode(' eur '), AppCurrency.eur);
    });

    test('usa NIO como fallback para códigos nulos o desconocidos', () {
      expect(AppCurrency.fromCode(null), AppCurrency.nio);
      expect(AppCurrency.fromCode(''), AppCurrency.nio);
      expect(AppCurrency.fromCode('BTC'), AppCurrency.nio);
    });

    test('mantiene códigos únicos en el catálogo', () {
      final codes = AppCurrency.values.map((currency) => currency.code).toSet();
      expect(codes.length, AppCurrency.values.length);
    });
  });
}
