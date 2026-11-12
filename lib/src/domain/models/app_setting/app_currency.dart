/// Monedas soportadas por la configuración global del sistema.
///
/// El [symbol] es el que se usa en pantalla, tickets, PDFs y reportes.
/// El [code] es el valor persistido en el backend (ISO 4217).
enum AppCurrency {
  nio(code: 'NIO', displayName: 'Córdoba nicaragüense', symbol: 'C\$'),
  usd(code: 'USD', displayName: 'Dólar estadounidense', symbol: 'US\$'),
  hnl(code: 'HNL', displayName: 'Lempira hondureña', symbol: 'L'),
  gtq(code: 'GTQ', displayName: 'Quetzal guatemalteco', symbol: 'Q'),
  crc(code: 'CRC', displayName: 'Colón costarricense', symbol: '₡'),
  cop(code: 'COP', displayName: 'Peso colombiano', symbol: 'COL\$'),
  mxn(code: 'MXN', displayName: 'Peso mexicano', symbol: 'MX\$'),
  eur(code: 'EUR', displayName: 'Euro', symbol: '€');

  const AppCurrency({
    required this.code,
    required this.displayName,
    required this.symbol,
  });

  final String code;
  final String displayName;
  final String symbol;

  /// Devuelve la moneda que corresponde al código ISO.
  ///
  /// Si el código es nulo, vacío o desconocido, retorna [AppCurrency.nio]
  /// para mantener un fallback seguro antes de cargar la configuración.
  static AppCurrency fromCode(String? code) {
    final normalized = code?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return AppCurrency.nio;

    for (final currency in AppCurrency.values) {
      if (currency.code == normalized) return currency;
    }
    return AppCurrency.nio;
  }
}
