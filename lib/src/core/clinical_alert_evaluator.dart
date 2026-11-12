import 'package:serum_business/src/domain/models/shared/reference_value.dart';

/// Evalúa los flags clínicos de un resultado a partir del valor capturado y del
/// rango de referencia resuelto para el paciente.
///
/// Es una utilidad pura: no depende de Flutter ni del almacenamiento de la orden.
/// El flag persistido (`alertFlag`) no participa en la evaluación; la fuente de
/// verdad es el valor actual y el rango que resuelve [ReferenceValueResolver].
class ClinicalAlertEvaluator {
  ClinicalAlertEvaluator._();

  /// Normaliza los alias históricos de alertas a `H`, `L` o `ABNORMAL`.
  ///
  /// `NORMAL`, una cadena vacía o `null` representan ausencia de alerta.
  /// Cualquier otro valor se conserva en mayúsculas para no perder información
  /// de catálogos legados.
  static String? normalizeFlag(String? flag) {
    if (flag == null) return null;

    final normalized = flag.trim().toUpperCase();
    if (normalized.isEmpty || normalized == 'NORMAL') return null;

    switch (normalized) {
      case 'HIGH':
      case 'ALTO':
      case 'H':
        return 'H';
      case 'LOW':
      case 'BAJO':
      case 'L':
        return 'L';
      case 'ABNORMAL':
      case 'ANORMAL':
      case '*':
        return 'ABNORMAL';
      default:
        return normalized;
    }
  }

  /// Convierte un texto numérico a [double], tolerando separadores de miles.
  ///
  /// Acepta formatos como `1,234.5`, `1.234,5` o `1,234`. Devuelve `null` si el
  /// texto no representa un número válido.
  static double? tryParseNumeric(String? text) {
    if (text == null) return null;

    var cleaned = text.trim().replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty) return null;

    final hasComma = cleaned.contains(',');
    final hasDot = cleaned.contains('.');

    if (hasComma && hasDot) {
      if (cleaned.lastIndexOf(',') > cleaned.lastIndexOf('.')) {
        // Formato latino: 1.234,5 -> 1234.5
        cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // Formato anglosajón: 1,234.5 -> 1234.5
        cleaned = cleaned.replaceAll(',', '');
      }
    } else if (hasComma) {
      final parts = cleaned.split(',');
      final isSingleComma = parts.length == 2;
      final looksLikeDecimal =
          isSingleComma && parts[1].isNotEmpty && parts[1].length != 3;
      cleaned = looksLikeDecimal
          ? '${parts[0]}.${parts[1]}'
          : cleaned.replaceAll(',', '');
    }

    final value = double.tryParse(cleaned);
    return value != null && value.isFinite ? value : null;
  }

  /// Evalúa un valor numérico contra el rango resuelto.
  ///
  /// Devuelve `H` si supera `maxValue`, `L` si está por debajo de `minValue` y
  /// `null` cuando está dentro del rango o no hay referencia aplicable.
  static String? evaluateNumeric({
    required num? value,
    required ReferenceValue? reference,
  }) {
    if (value == null || reference == null) return null;

    final numericValue = value.toDouble();
    if (!numericValue.isFinite) return null;

    if (numericValue > reference.maxValue) return 'H';
    if (numericValue < reference.minValue) return 'L';
    return null;
  }

  /// Evalúa un resultado numérico capturado como texto contra el rango resuelto.
  static String? evaluateNumericText({
    required String? text,
    required ReferenceValue? reference,
  }) {
    return evaluateNumeric(value: tryParseNumeric(text), reference: reference);
  }

  /// Evalúa un resultado cualitativo o booleano contra el valor esperado.
  ///
  /// La comparación ignora mayúsculas y espacios periféricos para evitar falsos
  /// `ABNORMAL`. Sin valor capturado o sin valor esperado no se genera alerta.
  static String? evaluateQualitative({
    required String? value,
    required String? expected,
  }) {
    final captured = value?.trim();
    if (captured == null || captured.isEmpty) return null;

    final expectedValue = expected?.trim();
    if (expectedValue == null || expectedValue.isEmpty) return null;

    return captured.toLowerCase() == expectedValue.toLowerCase()
        ? null
        : 'ABNORMAL';
  }

  /// Indica si un resultado numérico puede evaluarse con el rango dado.
  static bool canEvaluateNumeric({
    required String? text,
    required ReferenceValue? reference,
  }) {
    return reference != null && tryParseNumeric(text) != null;
  }

  /// Indica si un resultado cualitativo/booleano puede compararse contra su
  /// valor esperado.
  static bool canEvaluateQualitative({
    required String? value,
    required String? expected,
  }) {
    final captured = value?.trim();
    if (captured == null || captured.isEmpty) return false;

    final expectedValue = expected?.trim();
    return expectedValue != null && expectedValue.isNotEmpty;
  }

  /// Indica si el resultado tiene información suficiente para emitir un juicio
  /// clínico (normal, alto, bajo o anormal).
  static bool canEvaluateResult({
    required String? dataType,
    required String? resultValue,
    required String? expectedQualitativeValue,
    required ReferenceValue? reference,
  }) {
    final value = resultValue?.trim();
    if (value == null || value.isEmpty) return false;

    switch (dataType) {
      case 'numeric':
        return canEvaluateNumeric(text: value, reference: reference);
      case 'qualitative':
      case 'boolean':
        return canEvaluateQualitative(
          value: value,
          expected: expectedQualitativeValue,
        );
      default:
        return false;
    }
  }

  /// Evalúa un resultado completo según su tipo de dato.
  ///
  /// Para `numeric` usa el rango resuelto; para `qualitative` y `boolean` usa
  /// el valor esperado. Los resultados de texto libre no generan alerta.
  static String? evaluateResult({
    required String? dataType,
    required String? resultValue,
    required String? expectedQualitativeValue,
    required ReferenceValue? reference,
  }) {
    final value = resultValue?.trim();
    if (value == null || value.isEmpty) return null;

    switch (dataType) {
      case 'numeric':
        return evaluateNumericText(text: value, reference: reference);
      case 'qualitative':
      case 'boolean':
        return evaluateQualitative(
          value: value,
          expected: expectedQualitativeValue,
        );
      default:
        return null;
    }
  }
}
