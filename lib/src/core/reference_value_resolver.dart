import 'package:serum_business/src/domain/models/shared/reference_value.dart';

/// Resultado de resolver el valor de referencia aplicable a un paciente.
class ReferenceResolution {
  final ReferenceValue? value;
  final bool evaluatedAge;
  final bool evaluatedGender;
  final bool isGeneral;

  const ReferenceResolution({
    required this.value,
    this.evaluatedAge = false,
    this.evaluatedGender = false,
    this.isGeneral = false,
  });

  const ReferenceResolution.none()
    : value = null,
      evaluatedAge = false,
      evaluatedGender = false,
      isGeneral = false;

  bool get hasValue => value != null;
}

/// Resuelve el rango de referencia que corresponde a la demografía de un paciente.
///
/// Reglas:
/// - `useAge = false` ignora `minAgeDays` / `maxAgeDays`.
/// - `useGender = false` ignora `gender`.
/// - Ambos flags en `false` representan un rango general.
/// - Si varios rangos coinciden, gana el más específico.
class ReferenceValueResolver {
  ReferenceValueResolver._();

  /// Calcula la edad en días a una fecha de referencia.
  ///
  /// Devuelve `null` cuando no hay datos demográficos suficientes, cuando la
  /// fecha de nacimiento es futura o cuando hay fecha de nacimiento pero no una
  /// fecha de referencia válida. Un retorno `0` significa una edad conocida
  /// de 0 días (recién nacido), no "sin datos".
  ///
  /// `referenceDateMs` es obligatorio: para órdenes históricas debe ser
  /// `order.createdAt`, y para cálculos nuevos debe pasarse explícitamente la
  /// fecha actual desde el caller. Esto evita una dependencia oculta del reloj.
  static int? tryAgeInDaysAt({
    required int dateOfBirthMs,
    required int referenceDateMs,
    int? fallbackAgeYears,
  }) {
    if (dateOfBirthMs > 0) {
      if (referenceDateMs <= 0) return null;

      final birth = DateTime.fromMillisecondsSinceEpoch(dateOfBirthMs);
      final reference = DateTime.fromMillisecondsSinceEpoch(referenceDateMs);

      final birthDate = DateTime.utc(birth.year, birth.month, birth.day);
      final referenceDate = DateTime.utc(
        reference.year,
        reference.month,
        reference.day,
      );
      final days = referenceDate.difference(birthDate).inDays;
      return days >= 0 ? days : null;
    }

    if (fallbackAgeYears != null && fallbackAgeYears >= 0) {
      return fallbackAgeYears * 365;
    }
    return null;
  }

  /// Compatibilidad: devuelve `0` cuando la edad es desconocida.
  ///
  /// Los flujos clínicos deben usar [tryAgeInDaysAt] para distinguir
  /// "0 días" de "sin datos demográficos".
  static int ageInDaysAt({
    required int dateOfBirthMs,
    required int referenceDateMs,
    int? fallbackAgeYears,
  }) {
    return tryAgeInDaysAt(
          dateOfBirthMs: dateOfBirthMs,
          referenceDateMs: referenceDateMs,
          fallbackAgeYears: fallbackAgeYears,
        ) ??
        0;
  }

  /// Normaliza los valores de género usados por el catálogo y los pacientes.
  static String normalizeGender(String raw) {
    final lower = raw.trim().toLowerCase();
    if (const {'m', 'male', 'masculino', 'hombre'}.contains(lower)) {
      return 'male';
    }
    if (const {'f', 'female', 'femenino', 'mujer'}.contains(lower)) {
      return 'female';
    }
    if (const {
      '',
      'both',
      'todos',
      'any',
      'ambos',
      'general',
    }.contains(lower)) {
      return 'both';
    }
    return lower;
  }

  /// Devuelve el rango aplicable o `null` si no hay coincidencia.
  ///
  /// `ageInDays` debe ser `null` cuando la edad es desconocida. En ese caso
  /// solo son candidatos los rangos con `useAge = false`.
  static ReferenceValue? resolve({
    required List<ReferenceValue> values,
    required int? ageInDays,
    required String gender,
  }) {
    return resolveWithMetadata(
      values: values,
      ageInDays: ageInDays,
      gender: gender,
    ).value;
  }

  /// Devuelve el rango aplicable junto con metadatos de la coincidencia.
  static ReferenceResolution resolveWithMetadata({
    required List<ReferenceValue> values,
    required int? ageInDays,
    required String gender,
  }) {
    if (values.isEmpty) return const ReferenceResolution.none();

    final normalizedGender = normalizeGender(gender);
    final candidates = <_Candidate>[];

    for (var i = 0; i < values.length; i++) {
      final ref = values[i];
      final ageOk = !ref.useAge || _ageMatches(ref, ageInDays);
      final genderOk = !ref.useGender || _genderMatches(ref, normalizedGender);
      if (ageOk && genderOk) {
        candidates.add(_Candidate(ref: ref, index: i));
      }
    }

    if (candidates.isEmpty) return const ReferenceResolution.none();

    candidates.sort(_compareCandidates);
    final best = candidates.first;

    return ReferenceResolution(
      value: best.ref,
      evaluatedAge: best.ref.useAge,
      evaluatedGender: best.ref.useGender,
      isGeneral: !best.ref.useAge && !best.ref.useGender,
    );
  }

  /// Formatea un rango de edad en días para mostrarlo en la UI.
  static String formatAgeRange(
    int minAgeDays,
    int maxAgeDays, {
    bool useAge = true,
    int allAgesThresholdDays = 36500,
  }) {
    if (!useAge) return 'Todas las edades';

    final min = minAgeDays <= 0 ? 0 : minAgeDays;
    final max = maxAgeDays <= 0 ? 0 : maxAgeDays;

    if (min == 0 && (max == 0 || max >= allAgesThresholdDays)) {
      return 'Todas las edades';
    }
    if (max == 0) {
      return 'Desde ${_formatAgeDays(min)}';
    }
    return '${_formatAgeDays(min)} - ${_formatAgeDays(max)}';
  }

  /// Formatea una edad en días para mostrarla en la UI.
  static String formatAgeDays(int days) => _formatAgeDays(days);

  /// Formatea el criterio de edad de una referencia usando su `ageUnit`.
  ///
  /// Devuelve una cadena vacía si el rango no evalúa edad. Respeta la unidad
  /// configurada en el catálogo (`days`, `months`, `years`) para que un rango
  /// de 1–12 meses se muestre como tal y no como “1 mes - 1 año”.
  static String formatReferenceAge(ReferenceValue ref) {
    if (!ref.useAge) return '';

    final factor = switch (ref.ageUnit) {
      'days' => 1,
      'months' => 30,
      _ => 365,
    };
    final min = ref.minAgeDays <= 0 ? 0 : (ref.minAgeDays / factor).round();
    final max = ref.maxAgeDays <= 0 ? 0 : (ref.maxAgeDays / factor).round();

    if (min <= 0 && (max <= 0 || ref.maxAgeDays >= 36500)) {
      return 'Todas las edades';
    }

    String formatValue(int value) {
      if (ref.ageUnit == 'days') {
        return '$value ${value == 1 ? 'día' : 'días'}';
      }
      if (ref.ageUnit == 'months') {
        return '$value ${value == 1 ? 'mes' : 'meses'}';
      }
      return '$value ${value == 1 ? 'año' : 'años'}';
    }

    if (max <= 0) return 'Desde ${formatValue(min)}';
    if (min <= 0) return '0 - ${formatValue(max)}';
    if (min == max) return formatValue(min);
    return '$min - ${formatValue(max)}';
  }

  /// Formatea una cantidad de días en días, meses o años.
  static String _formatAgeDays(int days) {
    if (days <= 0) return '0 días';
    if (days < 30) return '$days ${days == 1 ? 'día' : 'días'}';

    if (days < 365) {
      final months = days ~/ 30;
      final remaining = days % 30;
      final monthsText = '$months ${months == 1 ? 'mes' : 'meses'}';
      if (remaining == 0) return monthsText;
      return '$monthsText y ${_formatAgeDays(remaining)}';
    }

    final years = days ~/ 365;
    final remaining = days % 365;
    final yearsText = '$years ${years == 1 ? 'año' : 'años'}';
    if (remaining == 0) return yearsText;
    return '$yearsText y ${_formatAgeDays(remaining)}';
  }

  static bool _ageMatches(ReferenceValue ref, int? ageInDays) {
    if (!ref.useAge) return true;
    if (ageInDays == null) return false;

    final aboveMin = ref.minAgeDays <= 0 || ageInDays >= ref.minAgeDays;
    final belowMax = ref.maxAgeDays <= 0 || ageInDays <= ref.maxAgeDays;
    return aboveMin && belowMax;
  }

  static bool _genderMatches(
    ReferenceValue ref,
    String normalizedPatientGender,
  ) {
    final refGender = normalizeGender(ref.gender);
    if (refGender == 'both') return true;
    if (normalizedPatientGender == 'both') return false;
    return refGender == normalizedPatientGender;
  }

  static int _compareCandidates(_Candidate a, _Candidate b) {
    final specificity = _specificity(b.ref).compareTo(_specificity(a.ref));
    if (specificity != 0) return specificity;

    final genderExact = _genderExact(b.ref).compareTo(_genderExact(a.ref));
    if (genderExact != 0) return genderExact;

    final minAge = _minAgeScore(b.ref).compareTo(_minAgeScore(a.ref));
    if (minAge != 0) return minAge;

    final span = _spanScore(a.ref).compareTo(_spanScore(b.ref));
    if (span != 0) return span;

    return a.index.compareTo(b.index);
  }

  /// Especificidad: ambos flags > solo edad > solo género > general.
  static int _specificity(ReferenceValue ref) {
    if (ref.useAge && ref.useGender) return 3;
    if (ref.useAge) return 2;
    if (ref.useGender) return 1;
    return 0;
  }

  static int _genderExact(ReferenceValue ref) {
    if (!ref.useGender) return 0;
    return normalizeGender(ref.gender) == 'both' ? 0 : 1;
  }

  static int _minAgeScore(ReferenceValue ref) {
    return ref.useAge ? ref.minAgeDays : -1;
  }

  static int _spanScore(ReferenceValue ref) {
    if (!ref.useAge) return 1 << 30;
    if (ref.maxAgeDays <= 0) return 1 << 30;
    final span = ref.maxAgeDays - ref.minAgeDays;
    return span < 0 ? (1 << 30) : span;
  }
}

class _Candidate {
  final ReferenceValue ref;
  final int index;

  const _Candidate({required this.ref, required this.index});
}
