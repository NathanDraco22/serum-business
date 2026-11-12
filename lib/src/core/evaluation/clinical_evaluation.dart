import 'package:serum_business/src/core/reference_value_resolver.dart';
import 'package:serum_business/src/domain/models/shared/reference_value.dart';

/// Estado semántico del resultado de una evaluación clínica.
///
/// Los estados [pending], [noReference], [noDemographics] y [notEvaluable]
/// indican que todavía no existe un juicio clínico; [normal], [high], [low] y
/// [abnormal] representan un resultado evaluado.
enum ClinicalEvaluationStatus {
  pending,
  normal,
  high,
  low,
  abnormal,
  noReference,
  noDemographics,
  notEvaluable,
}

/// Motivo por el que un resultado no pudo evaluarse.
enum ClinicalEvaluationReason {
  missingValue,
  missingDemographics,
  missingReference,
  unparseableValue,
  missingExpectedValue,
  unsupportedDataType,
}

/// Datos mínimos necesarios para evaluar un resultado clínico.
///
/// La fecha de referencia es obligatoria y explícita (normalmente
/// `order.createdAt`) para que el cálculo sea determinista y auditable. El
/// pipeline no conoce ni utiliza el `alertFlag` persistido en la orden.
class ClinicalEvaluationInput {
  const ClinicalEvaluationInput({
    this.dateOfBirthMs = 0,
    this.explicitAgeYears,
    required this.referenceDateMs,
    this.gender = '',
    required this.dataType,
    this.resultValue,
    this.expectedQualitativeValue,
    this.referenceValues = const [],
  });

  final int dateOfBirthMs;
  final int? explicitAgeYears;
  final int referenceDateMs;
  final String gender;
  final String dataType;
  final String? resultValue;
  final String? expectedQualitativeValue;
  final List<ReferenceValue> referenceValues;
}

/// Estado mutable que comparten los pasos del pipeline durante una evaluación.
///
/// Cada evaluación debe crear un contexto nuevo; el pipeline no reutiliza ni
/// comparte estado entre llamadas.
class ClinicalEvaluationContext {
  ClinicalEvaluationContext({required this.input});

  final ClinicalEvaluationInput input;

  int? ageInDays;
  String normalizedGender = '';
  bool hasAge = false;
  bool hasGender = false;
  bool hasDemographics = false;
  ReferenceResolution referenceResolution = const ReferenceResolution.none();
  String? alertFlag;
  ClinicalEvaluationStatus status = ClinicalEvaluationStatus.pending;
  ClinicalEvaluationReason? reason;

  /// Materializa el estado actual del contexto en un resultado inmutable.
  ClinicalEvaluationResult toResult() {
    return ClinicalEvaluationResult(
      status: status,
      reason: reason,
      ageInDays: ageInDays,
      normalizedGender: normalizedGender,
      hasAge: hasAge,
      hasGender: hasGender,
      hasDemographics: hasDemographics,
      referenceResolution: referenceResolution,
      alertFlag: alertFlag,
    );
  }
}

/// Resultado semántico e inmutable de una evaluación clínica.
///
/// No contiene textos de presentación: el consumidor decide cómo mostrar el
/// estado, el rango o el asterisco del PDF.
class ClinicalEvaluationResult {
  const ClinicalEvaluationResult({
    required this.status,
    required this.reason,
    required this.ageInDays,
    required this.normalizedGender,
    required this.hasAge,
    required this.hasGender,
    required this.hasDemographics,
    required this.referenceResolution,
    required this.alertFlag,
  });

  final ClinicalEvaluationStatus status;
  final ClinicalEvaluationReason? reason;
  final int? ageInDays;
  final String normalizedGender;
  final bool hasAge;
  final bool hasGender;
  final bool hasDemographics;
  final ReferenceResolution referenceResolution;
  final String? alertFlag;

  /// Rango de referencia aplicado, si existe.
  ReferenceValue? get reference => referenceResolution.value;

  /// Indica si el resultado recibió un juicio clínico.
  bool get isEvaluated =>
      status == ClinicalEvaluationStatus.normal ||
      status == ClinicalEvaluationStatus.high ||
      status == ClinicalEvaluationStatus.low ||
      status == ClinicalEvaluationStatus.abnormal;

  /// Indica si el resultado tiene una alerta clínica activa.
  bool get hasAlert => alertFlag != null;
}
