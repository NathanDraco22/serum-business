import 'package:intl/intl.dart';

import '../domain/models/app_setting/app_currency.dart';

/// Función que devuelve la moneda vigente en el estado global de la app.
typedef CurrencyResolver = AppCurrency Function();

/// Formateador puro de montos.
///
/// Vive en `serum_business` y no conoce Cubits ni `GetIt`. La capa de
/// aplicación registra un [CurrencyResolver] una sola vez y lo limpia en
/// `close()`; el formatter consulta la moneda actual en cada operación.
class NumberFormatter {
  static final NumberFormat _decimal = NumberFormat.decimalPattern('en_US')
    ..minimumFractionDigits = 2
    ..maximumFractionDigits = 2;

  static CurrencyResolver? _currencyResolver;
  static String? _currencyFormatSymbol;
  static NumberFormat? _currencyFormatInstance;

  /// Registra la función que devuelve la moneda actual. Se invoca una sola
  /// vez desde el Cubit global o desde el composition root.
  static void configureCurrencyResolver(CurrencyResolver? resolver) {
    _currencyResolver = resolver;
  }

  /// Moneda vigente. Si aún no se registró un resolver (arranque, tests o
  /// error de inicialización), retorna el fallback seguro [AppCurrency.nio].
  static AppCurrency get currency =>
      _currencyResolver?.call() ?? AppCurrency.nio;

  static String get currencySymbol => currency.symbol;

  static NumberFormat get currencyFormat {
    final symbol = currencySymbol;
    if (_currencyFormatInstance == null || _currencyFormatSymbol != symbol) {
      _currencyFormatSymbol = symbol;
      _currencyFormatInstance = NumberFormat.currency(
        locale: 'en_US',
        symbol: symbol,
        decimalDigits: 2,
      );
    }
    return _currencyFormatInstance!;
  }

  /// Formatea centavos a moneda con el símbolo global.
  ///
  /// [symbol] permite forzar un símbolo puntual (por ejemplo, en una vista
  /// previa de configuración) sin alterar el resolver global.
  static String convertToMoneyLike(int valueInCents, {String? symbol}) {
    final effectiveSymbol = symbol ?? currencySymbol;
    final value = valueInCents / 100;
    final sign = value < 0 ? '-' : '';
    return '$sign$effectiveSymbol${_decimal.format(value.abs())}';
  }

  /// Formatea centavos con signo explícito para valores positivos.
  static String convertToMoneyLikeSigned(int valueInCents, {String? symbol}) {
    final formatted = convertToMoneyLike(valueInCents, symbol: symbol);
    return valueInCents > 0 ? '+$formatted' : formatted;
  }

  /// Formato compacto para gráficos o badges reducidos (`C$1.5K`).
  static String convertToMoneyLikeCompact(int valueInCents, {String? symbol}) {
    return NumberFormat.compactCurrency(
      locale: 'en_US',
      symbol: symbol ?? currencySymbol,
      decimalDigits: 1,
    ).format(valueInCents / 100);
  }

  /// Formatea usando una moneda explícita, sin depender del resolver global.
  /// Útil para previews de configuración y tests aislados.
  static String convertToMoneyLikeWith(
    AppCurrency appCurrency,
    int valueInCents,
  ) {
    final value = valueInCents / 100;
    final sign = value < 0 ? '-' : '';
    return '$sign${appCurrency.symbol}${_decimal.format(value.abs())}';
  }

  static String decimalPattern(num value) => _decimal.format(value);

  static int convertFromDoubleToCents(double value) {
    return (value * 100).round();
  }

  static double convertFromCentsToDouble(int value) {
    return value / 100;
  }

  static String convertFromCentsToUnitsCurrency(int valueInCents) {
    final value = valueInCents / 100;
    final rounded = double.parse(value.toStringAsFixed(2));
    return _decimal.format(rounded);
  }

  static String formatDisplayStock(int stock, int factor) {
    final safeFactor = factor < 1 ? 1 : factor;
    final val = stock / safeFactor;
    if (val == val.toInt()) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }
}
