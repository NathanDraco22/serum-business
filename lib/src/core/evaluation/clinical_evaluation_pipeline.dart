import 'package:serum_business/src/core/evaluation/clinical_evaluation.dart';
import 'package:serum_business/src/core/evaluation/clinical_evaluation_steps.dart';

/// Orquesta los pasos de la evaluación clínica sobre un contexto nuevo.
///
/// Los pasos se ejecutan en orden y son síncronos. El pipeline no conserva
/// estado entre evaluaciones.
class ClinicalEvaluationPipeline {
  const ClinicalEvaluationPipeline({
    this.steps = const [
      DemographicsStep(),
      ReferenceResolutionStep(),
      ResultEvaluationStep(),
    ],
  });

  final List<ClinicalEvaluationStep> steps;

  ClinicalEvaluationResult evaluate(ClinicalEvaluationContext context) {
    for (final step in steps) {
      step.execute(context);
    }
    return context.toResult();
  }

  ClinicalEvaluationResult evaluateInput(ClinicalEvaluationInput input) {
    return evaluate(ClinicalEvaluationContext(input: input));
  }
}

/// Fachada de conveniencia para evaluar entradas clínicas.
class ClinicalEvaluationService {
  const ClinicalEvaluationService();

  static const ClinicalEvaluationPipeline _pipeline =
      ClinicalEvaluationPipeline();

  ClinicalEvaluationResult evaluate(ClinicalEvaluationInput input) {
    return _pipeline.evaluateInput(input);
  }
}
