import 'package:serum_business/src/core/clinical_alert_evaluator.dart';
import 'package:serum_business/src/core/evaluation/clinical_evaluation.dart';
import 'package:serum_business/src/core/reference_value_resolver.dart';

/// Paso síncrono del pipeline de evaluación clínica.
abstract class ClinicalEvaluationStep {
  void execute(ClinicalEvaluationContext context);
}

/// Calcula la edad, normaliza el género y determina si hay demografía
/// suficiente para resolver un rango de referencia.
class DemographicsStep implements ClinicalEvaluationStep {
  const DemographicsStep();

  @override
  void execute(ClinicalEvaluationContext context) {
    final input = context.input;
    final ageInDays = ReferenceValueResolver.tryAgeInDaysAt(
      dateOfBirthMs: input.dateOfBirthMs,
      referenceDateMs: input.referenceDateMs,
      fallbackAgeYears: input.explicitAgeYears,
    );
    final normalizedGender = ReferenceValueResolver.normalizeGender(
      input.gender,
    );

    context.ageInDays = ageInDays;
    context.normalizedGender = normalizedGender;
    context.hasAge = ageInDays != null;
    context.hasGender =
        normalizedGender == 'male' || normalizedGender == 'female';
    context.hasDemographics =
        input.dateOfBirthMs > 0 || input.explicitAgeYears != null;
  }
}

/// Resuelve el rango de referencia aplicable para resultados numéricos.
///
/// Los tipos cualitativos, booleanos y de texto no usan rangos numéricos, por
/// lo que conservan [ReferenceResolution.none].
class ReferenceResolutionStep implements ClinicalEvaluationStep {
  const ReferenceResolutionStep();

  @override
  void execute(ClinicalEvaluationContext context) {
    final input = context.input;

    if (input.dataType != 'numeric' || input.referenceValues.isEmpty) {
      context.referenceResolution = const ReferenceResolution.none();
      return;
    }

    context.referenceResolution = ReferenceValueResolver.resolveWithMetadata(
      values: input.referenceValues,
      ageInDays: context.ageInDays,
      gender: input.gender,
    );
  }
}

/// Evalúa el valor capturado y asigna el estado y la alerta clínica.
///
/// La evaluación siempre se recalcula: el pipeline nunca lee el `alertFlag`
/// persistido en la orden.
class ResultEvaluationStep implements ClinicalEvaluationStep {
  const ResultEvaluationStep();

  @override
  void execute(ClinicalEvaluationContext context) {
    final input = context.input;
    final value = input.resultValue?.trim();

    if (value == null || value.isEmpty) {
      context
        ..status = ClinicalEvaluationStatus.pending
        ..reason = ClinicalEvaluationReason.missingValue
        ..alertFlag = null;
      return;
    }

    switch (input.dataType) {
      case 'numeric':
        _evaluateNumeric(context, value);
        return;
      case 'qualitative':
      case 'boolean':
        _evaluateQualitative(context, value);
        return;
      default:
        context
          ..status = ClinicalEvaluationStatus.notEvaluable
          ..reason = ClinicalEvaluationReason.unsupportedDataType
          ..alertFlag = null;
        return;
    }
  }

  void _evaluateNumeric(ClinicalEvaluationContext context, String value) {
    final reference = context.referenceResolution.value;

    if (reference == null) {
      context.alertFlag = null;
      if (context.hasDemographics) {
        context
          ..status = ClinicalEvaluationStatus.noReference
          ..reason = ClinicalEvaluationReason.missingReference;
      } else {
        context
          ..status = ClinicalEvaluationStatus.noDemographics
          ..reason = ClinicalEvaluationReason.missingDemographics;
      }
      return;
    }

    final parsed = ClinicalAlertEvaluator.tryParseNumeric(value);
    if (parsed == null) {
      context
        ..status = ClinicalEvaluationStatus.notEvaluable
        ..reason = ClinicalEvaluationReason.unparseableValue
        ..alertFlag = null;
      return;
    }

    final flag = ClinicalAlertEvaluator.evaluateNumeric(
      value: parsed,
      reference: reference,
    );

    context
      ..status = switch (flag) {
        'H' => ClinicalEvaluationStatus.high,
        'L' => ClinicalEvaluationStatus.low,
        _ => ClinicalEvaluationStatus.normal,
      }
      ..reason = null
      ..alertFlag = flag;
  }

  void _evaluateQualitative(ClinicalEvaluationContext context, String value) {
    final expected = context.input.expectedQualitativeValue?.trim();

    if (expected == null || expected.isEmpty) {
      context
        ..status = ClinicalEvaluationStatus.notEvaluable
        ..reason = ClinicalEvaluationReason.missingExpectedValue
        ..alertFlag = null;
      return;
    }

    final flag = ClinicalAlertEvaluator.evaluateQualitative(
      value: value,
      expected: expected,
    );

    context
      ..status = flag == 'ABNORMAL'
          ? ClinicalEvaluationStatus.abnormal
          : ClinicalEvaluationStatus.normal
      ..reason = null
      ..alertFlag = flag;
  }
}
