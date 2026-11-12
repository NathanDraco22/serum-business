import 'package:serum_business/serum_business.dart';
import 'package:test/test.dart';

void main() {
  tearDown(() {
    NumberFormatter.configureCurrencyResolver(null);
  });

  group('NumberFormatter currency resolver', () {
    test('usa NIO como fallback antes de registrar un resolver', () {
      expect(NumberFormatter.currency, AppCurrency.nio);
      expect(NumberFormatter.convertToMoneyLike(15050), 'C\$150.50');
      expect(NumberFormatter.convertToMoneyLike(0), 'C\$0.00');
    });

    test('consulta la moneda actual en cada formateo', () {
      var current = AppCurrency.nio;
      NumberFormatter.configureCurrencyResolver(() => current);

      expect(NumberFormatter.convertToMoneyLike(245000), 'C\$2,450.00');

      current = AppCurrency.usd;
      expect(NumberFormatter.convertToMoneyLike(245000), 'US\$2,450.00');

      current = AppCurrency.eur;
      expect(NumberFormatter.convertToMoneyLike(245000), '€2,450.00');
    });

    test('permite forzar un símbolo sin alterar el resolver', () {
      NumberFormatter.configureCurrencyResolver(() => AppCurrency.usd);

      expect(
        NumberFormatter.convertToMoneyLike(15050, symbol: 'C\$'),
        'C\$150.50',
      );
      expect(NumberFormatter.convertToMoneyLike(15050), 'US\$150.50');
    });

    test('formatea negativos con el signo antes del símbolo', () {
      NumberFormatter.configureCurrencyResolver(() => AppCurrency.usd);

      expect(NumberFormatter.convertToMoneyLike(-2500), '-US\$25.00');
      expect(NumberFormatter.convertToMoneyLike(-150000), '-US\$1,500.00');
    });

    test('agrega signo explícito solo a positivos', () {
      NumberFormatter.configureCurrencyResolver(() => AppCurrency.nio);

      expect(NumberFormatter.convertToMoneyLikeSigned(15000), '+C\$150.00');
      expect(NumberFormatter.convertToMoneyLikeSigned(-15000), '-C\$150.00');
      expect(NumberFormatter.convertToMoneyLikeSigned(0), 'C\$0.00');
    });

    test('formatea compacto con la moneda vigente', () {
      NumberFormatter.configureCurrencyResolver(() => AppCurrency.nio);

      expect(NumberFormatter.convertToMoneyLikeCompact(150000), 'C\$1.5K');
    });

    test('permite formatear con una moneda explícita para previews', () {
      expect(
        NumberFormatter.convertToMoneyLikeWith(AppCurrency.mxn, 123456),
        'MX\$1,234.56',
      );
    });

    test('limpia el resolver y vuelve al fallback', () {
      NumberFormatter.configureCurrencyResolver(() => AppCurrency.eur);
      expect(NumberFormatter.currency, AppCurrency.eur);

      NumberFormatter.configureCurrencyResolver(null);
      expect(NumberFormatter.currency, AppCurrency.nio);
    });
  });
}
