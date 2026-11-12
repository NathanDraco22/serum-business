class ReferenceValue {
  final String patientType;
  final String gender;
  final int minAgeDays;
  final int maxAgeDays;
  final double minValue;
  final double maxValue;

  /// Unidad de presentación para los límites de edad (`days`, `months`, `years`).
  ///
  /// Es solo metadato de presentación; la lógica clínica sigue operando con
  /// `minAgeDays` y `maxAgeDays`.
  final String ageUnit;
  final bool useAge;
  final bool useGender;

  ReferenceValue({
    required this.patientType,
    required this.gender,
    required this.minAgeDays,
    required this.maxAgeDays,
    required this.minValue,
    required this.maxValue,
    this.ageUnit = 'years',
    this.useAge = false,
    this.useGender = false,
  });

  factory ReferenceValue.fromJson(Map<String, dynamic> json) {
    final minAgeDays = (json['minAgeDays'] as num?)?.toInt() ?? 0;
    final maxAgeDays = (json['maxAgeDays'] as num?)?.toInt() ?? 0;

    return ReferenceValue(
      patientType: json['patientType'] as String? ?? 'general',
      gender: json['gender'] as String? ?? 'both',
      minAgeDays: minAgeDays,
      maxAgeDays: maxAgeDays,
      minValue: (json['minValue'] as num).toDouble(),
      maxValue: (json['maxValue'] as num).toDouble(),
      ageUnit:
          json['ageUnit'] as String? ?? inferAgeUnit(minAgeDays, maxAgeDays),
      useAge: json['useAge'] as bool? ?? false,
      useGender: json['useGender'] as bool? ?? false,
    );
  }

  /// Infiere la unidad de presentación a partir de los límites en días.
  static String inferAgeUnit(int minAgeDays, int maxAgeDays) {
    if (minAgeDays % 365 == 0 && maxAgeDays % 365 == 0) return 'years';
    if (minAgeDays % 30 == 0 && maxAgeDays % 30 == 0) return 'months';
    return 'days';
  }

  Map<String, dynamic> toJson() {
    return {
      'patientType': patientType,
      'gender': gender,
      'minAgeDays': minAgeDays,
      'maxAgeDays': maxAgeDays,
      'minValue': minValue,
      'maxValue': maxValue,
      'ageUnit': ageUnit,
      'useAge': useAge,
      'useGender': useGender,
    };
  }

  ReferenceValue copyWith({
    String? patientType,
    String? gender,
    int? minAgeDays,
    int? maxAgeDays,
    double? minValue,
    double? maxValue,
    String? ageUnit,
    bool? useAge,
    bool? useGender,
  }) {
    return ReferenceValue(
      patientType: patientType ?? this.patientType,
      gender: gender ?? this.gender,
      minAgeDays: minAgeDays ?? this.minAgeDays,
      maxAgeDays: maxAgeDays ?? this.maxAgeDays,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      ageUnit: ageUnit ?? this.ageUnit,
      useAge: useAge ?? this.useAge,
      useGender: useGender ?? this.useGender,
    );
  }
}
