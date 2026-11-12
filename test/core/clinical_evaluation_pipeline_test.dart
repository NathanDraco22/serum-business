import 'package:serum_business/serum_business.dart';
import 'package:test/test.dart';

void main() {
  const pipeline = ClinicalEvaluationPipeline();
  const service = ClinicalEvaluationService();

  final birthDateMs = DateTime(1990, 1, 1).millisecondsSinceEpoch;
  final referenceDateMs = DateTime(2024, 1, 1).millisecondsSinceEpoch;

  ReferenceValue ref({
    String gender = 'both',
    int minAgeDays = 0,
    int maxAgeDays = 0,
    double minValue = 0,
    double maxValue = 10,
    String ageUnit = 'years',
    bool useAge = false,
    bool useGender = false,
  }) {
    return ReferenceValue(
      patientType: 'general',
      gender: gender,
      minAgeDays: minAgeDays,
      maxAgeDays: maxAgeDays,
      minValue: minValue,
      maxValue: maxValue,
      ageUnit: ageUnit,
      useAge: useAge,
      useGender: useGender,
    );
  }

  ClinicalEvaluationInput numericInput({
    String? resultValue,
    List<ReferenceValue> referenceValues = const [],
    int dateOfBirthMs = 0,
    int referenceDate = 0,
    int? explicitAgeYears,
    String gender = '',
  }) {
    return ClinicalEvaluationInput(
      dateOfBirthMs: dateOfBirthMs,
      explicitAgeYears: explicitAgeYears,
      referenceDateMs: referenceDate,
      gender: gender,
      dataType: 'numeric',
      resultValue: resultValue,
      referenceValues: referenceValues,
    );
  }

  ClinicalEvaluationInput qualitativeInput({
    String dataType = 'qualitative',
    String? resultValue,
    String? expectedQualitativeValue,
  }) {
    return ClinicalEvaluationInput(
      referenceDateMs: referenceDateMs,
      dataType: dataType,
      resultValue: resultValue,
      expectedQualitativeValue: expectedQualitativeValue,
    );
  }

  group('evaluación numérica', () {
    test('1. valor dentro del rango es normal y sin alerta', () {
      final result = pipeline.evaluateInput(
        numericInput(
          resultValue: '5',
          dateOfBirthMs: birthDateMs,
          referenceDate: referenceDateMs,
          referenceValues: [ref(minValue: 0, maxValue: 10)],
        ),
      );

      expect(result.status, ClinicalEvaluationStatus.normal);
      expect(result.alertFlag, isNull);
      expect(result.reason, isNull);
      expect(result.isEvaluated, isTrue);
      expect(result.hasAlert, isFalse);
      expect(result.reference, isNotNull);
    });

    test('2. valor por encima del máximo es high con flag H', () {
      final result = pipeline.evaluateInput(
        numericInput(
          resultValue: '12',
          dateOfBirthMs: birthDateMs,
          referenceDate: referenceDateMs,
          referenceValues: [ref(minValue: 0, maxValue: 10)],
        ),
      );

      expect(result.status, ClinicalEvaluationStatus.high);
      expect(result.alertFlag, 'H');
      expect(result.reason, isNull);
      expect(result.hasAlert, isTrue);
    });

    test('3. valor por debajo del mínimo es low con flag L', () {
      final result = pipeline.evaluateInput(
        numericInput(
          resultValue: '1',
          dateOfBirthMs: birthDateMs,
          referenceDate: referenceDateMs,
          referenceValues: [ref(minValue: 2, maxValue: 10)],
        ),
      );

      expect(result.status, ClinicalEvaluationStatus.low);
      expect(result.alertFlag, 'L');
      expect(result.reason, isNull);
      expect(result.hasAlert, isTrue);
    });

    test('4. sin rango y con demografía es noReference', () {
      final result = pipeline.evaluateInput(
        numericInput(
          resultValue: '5',
          dateOfBirthMs: birthDateMs,
          referenceDate: referenceDateMs,
        ),
      );

      expect(result.status, ClinicalEvaluationStatus.noReference);
      expect(result.reason, ClinicalEvaluationReason.missingReference);
      expect(result.alertFlag, isNull);
      expect(result.reference, isNull);
      expect(result.isEvaluated, isFalse);
    });

    test('5. sin rango y sin demografía es noDemographics', () {
      final result = pipeline.evaluateInput(numericInput(resultValue: '5'));

      expect(result.status, ClinicalEvaluationStatus.noDemographics);
      expect(result.reason, ClinicalEvaluationReason.missingDemographics);
      expect(result.alertFlag, isNull);
      expect(result.hasDemographics, isFalse);
    });

    test('6. valor no parseable es notEvaluable con unparseableValue', () {
      final result = pipeline.evaluateInput(
        numericInput(
          resultValue: 'abc',
          dateOfBirthMs: birthDateMs,
          referenceDate: referenceDateMs,
          referenceValues: [ref(minValue: 0, maxValue: 10)],
        ),
      );

      expect(result.status, ClinicalEvaluationStatus.notEvaluable);
      expect(result.reason, ClinicalEvaluationReason.unparseableValue);
      expect(result.alertFlag, isNull);
      expect(result.isEvaluated, isFalse);
    });

    test('7. sin valor es pending con missingValue', () {
      final nullValue = pipeline.evaluateInput(numericInput());
      final blankValue = pipeline.evaluateInput(
        numericInput(resultValue: '   '),
      );

      for (final result in [nullValue, blankValue]) {
        expect(result.status, ClinicalEvaluationStatus.pending);
        expect(result.reason, ClinicalEvaluationReason.missingValue);
        expect(result.alertFlag, isNull);
        expect(result.isEvaluated, isFalse);
      }
    });

    test('el flag persistido no se usa: siempre se recalcula', () {
      final result = pipeline.evaluateInput(
        numericInput(
          resultValue: '5',
          dateOfBirthMs: birthDateMs,
          referenceDate: referenceDateMs,
          referenceValues: [ref(minValue: 0, maxValue: 10)],
        ),
      );

      expect(result.status, ClinicalEvaluationStatus.normal);
      expect(result.alertFlag, isNull);
    });
  });

  group('evaluación cualitativa y booleana', () {
    test('8. cualitativo que coincide con el esperado es normal', () {
      final result = pipeline.evaluateInput(
        qualitativeInput(
          resultValue: ' negativo ',
          expectedQualitativeValue: 'Negativo',
        ),
      );

      expect(result.status, ClinicalEvaluationStatus.normal);
      expect(result.alertFlag, isNull);
      expect(result.reason, isNull);
      expect(result.isEvaluated, isTrue);
    });

    test('9. cualitativo que no coincide es abnormal con flag ABNORMAL', () {
      final result = pipeline.evaluateInput(
        qualitativeInput(
          resultValue: 'Positivo',
          expectedQualitativeValue: 'Negativo',
        ),
      );

      expect(result.status, ClinicalEvaluationStatus.abnormal);
      expect(result.alertFlag, 'ABNORMAL');
      expect(result.reason, isNull);
      expect(result.hasAlert, isTrue);
    });

    test('10. cualitativo sin valor esperado es notEvaluable', () {
      final withoutExpected = pipeline.evaluateInput(
        qualitativeInput(resultValue: 'Positivo'),
      );
      final blankExpected = pipeline.evaluateInput(
        qualitativeInput(
          resultValue: 'Positivo',
          expectedQualitativeValue: '  ',
        ),
      );

      for (final result in [withoutExpected, blankExpected]) {
        expect(result.status, ClinicalEvaluationStatus.notEvaluable);
        expect(result.reason, ClinicalEvaluationReason.missingExpectedValue);
        expect(result.alertFlag, isNull);
      }
    });

    test('boolean se evalúa igual que cualitativo', () {
      final coincident = pipeline.evaluateInput(
        qualitativeInput(
          dataType: 'boolean',
          resultValue: 'Positivo',
          expectedQualitativeValue: 'positivo',
        ),
      );
      final different = pipeline.evaluateInput(
        qualitativeInput(
          dataType: 'boolean',
          resultValue: 'Negativo',
          expectedQualitativeValue: 'Positivo',
        ),
      );

      expect(coincident.status, ClinicalEvaluationStatus.normal);
      expect(coincident.alertFlag, isNull);
      expect(different.status, ClinicalEvaluationStatus.abnormal);
      expect(different.alertFlag, 'ABNORMAL');
    });
  });

  group('tipos no soportados', () {
    test('11. texto con valor es notEvaluable con unsupportedDataType', () {
      final result = pipeline.evaluateInput(
        ClinicalEvaluationInput(
          referenceDateMs: referenceDateMs,
          dataType: 'text',
          resultValue: 'Observación libre',
        ),
      );

      expect(result.status, ClinicalEvaluationStatus.notEvaluable);
      expect(result.reason, ClinicalEvaluationReason.unsupportedDataType);
      expect(result.alertFlag, isNull);
      expect(result.isEvaluated, isFalse);
    });

    test('un dataType desconocido también es unsupportedDataType', () {
      final result = pipeline.evaluateInput(
        ClinicalEvaluationInput(
          referenceDateMs: referenceDateMs,
          dataType: 'desconocido',
          resultValue: 'valor',
        ),
      );

      expect(result.status, ClinicalEvaluationStatus.notEvaluable);
      expect(result.reason, ClinicalEvaluationReason.unsupportedDataType);
    });
  });

  group('demografía', () {
    test('12. recién nacido con fecha igual a la referencia tiene 0 días', () {
      final sameDateMs = DateTime(2024, 5, 10).millisecondsSinceEpoch;
      final result = pipeline.evaluateInput(
        numericInput(
          resultValue: '5',
          dateOfBirthMs: sameDateMs,
          referenceDate: sameDateMs,
          referenceValues: [
            ref(minAgeDays: 0, maxAgeDays: 28, ageUnit: 'days', useAge: true),
          ],
        ),
      );

      expect(result.ageInDays, 0);
      expect(result.hasAge, isTrue);
      expect(result.hasDemographics, isTrue);
      expect(result.reference, isNotNull);
      expect(result.status, ClinicalEvaluationStatus.normal);
    });

    test(
      '13. edad 0 explícita sin fecha de nacimiento conserva demografía',
      () {
        final result = pipeline.evaluateInput(
          numericInput(
            resultValue: '5',
            explicitAgeYears: 0,
            referenceValues: [
              ref(minAgeDays: 0, maxAgeDays: 28, ageUnit: 'days', useAge: true),
            ],
          ),
        );

        expect(result.ageInDays, 0);
        expect(result.hasAge, isTrue);
        expect(result.hasDemographics, isTrue);
        expect(result.reference, isNotNull);
        expect(result.status, ClinicalEvaluationStatus.normal);
      },
    );

    test('14. sin edad ni fecha de nacimiento es noDemographics', () {
      final result = pipeline.evaluateInput(
        numericInput(
          resultValue: '5',
          referenceValues: [ref(minAgeDays: 0, maxAgeDays: 28, useAge: true)],
        ),
      );

      expect(result.ageInDays, isNull);
      expect(result.hasAge, isFalse);
      expect(result.hasDemographics, isFalse);
      expect(result.status, ClinicalEvaluationStatus.noDemographics);
      expect(result.reason, ClinicalEvaluationReason.missingDemographics);
    });

    test('15. paciente femenina resuelve un rango exclusivo femenino', () {
      final result = pipeline.evaluateInput(
        numericInput(
          resultValue: '5',
          dateOfBirthMs: birthDateMs,
          referenceDate: referenceDateMs,
          gender: 'F',
          referenceValues: [
            ref(gender: 'female', minValue: 0, maxValue: 10, useGender: true),
          ],
        ),
      );

      expect(result.normalizedGender, 'female');
      expect(result.hasGender, isTrue);
      expect(result.reference, isNotNull);
      expect(result.status, ClinicalEvaluationStatus.normal);
    });

    test('16. género desconocido no resuelve rangos exclusivos', () {
      final specificOnly = pipeline.evaluateInput(
        numericInput(
          resultValue: '5',
          explicitAgeYears: 30,
          gender: '',
          referenceValues: [
            ref(gender: 'female', minValue: 0, maxValue: 10, useGender: true),
          ],
        ),
      );

      expect(specificOnly.normalizedGender, 'both');
      expect(specificOnly.hasGender, isFalse);
      expect(specificOnly.reference, isNull);
      expect(specificOnly.status, ClinicalEvaluationStatus.noReference);

      final withGeneral = pipeline.evaluateInput(
        numericInput(
          resultValue: '5',
          explicitAgeYears: 30,
          gender: '',
          referenceValues: [
            ref(gender: 'female', minValue: 0, maxValue: 10, useGender: true),
            ref(minValue: 3, maxValue: 10),
          ],
        ),
      );

      expect(withGeneral.reference, isNotNull);
      expect(withGeneral.reference?.minValue, 3);
      expect(withGeneral.status, ClinicalEvaluationStatus.normal);
    });
  });

  group('resolución de referencias', () {
    test('17. edad + género tiene prioridad sobre solo edad', () {
      final result = pipeline.evaluateInput(
        numericInput(
          resultValue: '5',
          explicitAgeYears: 30,
          gender: 'M',
          referenceValues: [
            ref(
              minAgeDays: 18 * 365,
              maxAgeDays: 65 * 365,
              minValue: 1,
              maxValue: 10,
              useAge: true,
            ),
            ref(
              gender: 'male',
              minAgeDays: 18 * 365,
              maxAgeDays: 65 * 365,
              minValue: 2,
              maxValue: 10,
              useAge: true,
              useGender: true,
            ),
          ],
        ),
      );

      expect(result.reference, isNotNull);
      expect(result.reference?.minValue, 2);
      expect(result.referenceResolution.evaluatedAge, isTrue);
      expect(result.referenceResolution.evaluatedGender, isTrue);
      expect(result.status, ClinicalEvaluationStatus.normal);
    });

    test('18. rango general resuelve incluso sin demografía', () {
      final result = pipeline.evaluateInput(
        numericInput(
          resultValue: '5',
          referenceValues: [ref(minValue: 0, maxValue: 10)],
        ),
      );

      expect(result.ageInDays, isNull);
      expect(result.hasDemographics, isFalse);
      expect(result.reference, isNotNull);
      expect(result.referenceResolution.isGeneral, isTrue);
      expect(result.status, ClinicalEvaluationStatus.normal);
    });

    test(
      '19. sin fecha de referencia no resuelve por edad, pero sí un rango general',
      () {
        final byAge = pipeline.evaluateInput(
          numericInput(
            resultValue: '5',
            dateOfBirthMs: birthDateMs,
            referenceValues: [
              ref(minAgeDays: 18 * 365, maxAgeDays: 65 * 365, useAge: true),
            ],
          ),
        );

        expect(byAge.ageInDays, isNull);
        expect(byAge.hasAge, isFalse);
        expect(byAge.hasDemographics, isTrue);
        expect(byAge.reference, isNull);
        expect(byAge.status, ClinicalEvaluationStatus.noReference);

        final general = pipeline.evaluateInput(
          numericInput(
            resultValue: '5',
            dateOfBirthMs: birthDateMs,
            referenceValues: [ref(minValue: 0, maxValue: 10)],
          ),
        );

        expect(general.reference, isNotNull);
        expect(general.status, ClinicalEvaluationStatus.normal);
      },
    );

    test('20. usa la edad explícita cuando no hay fecha de nacimiento', () {
      final result = pipeline.evaluateInput(
        numericInput(
          resultValue: '5',
          explicitAgeYears: 30,
          referenceValues: [
            ref(minAgeDays: 18 * 365, maxAgeDays: 65 * 365, useAge: true),
          ],
        ),
      );

      expect(result.ageInDays, 30 * 365);
      expect(result.hasAge, isTrue);
      expect(result.hasDemographics, isTrue);
      expect(result.reference, isNotNull);
      expect(result.status, ClinicalEvaluationStatus.normal);
    });
  });

  group('pipeline y service', () {
    test('ClinicalEvaluationService delega en el pipeline', () {
      final result = service.evaluate(
        numericInput(
          resultValue: '12',
          dateOfBirthMs: birthDateMs,
          referenceDate: referenceDateMs,
          referenceValues: [ref(minValue: 0, maxValue: 10)],
        ),
      );

      expect(result.status, ClinicalEvaluationStatus.high);
      expect(result.alertFlag, 'H');
    });

    test('ejecuta los pasos en el orden configurado', () {
      final calls = <String>[];
      final customPipeline = ClinicalEvaluationPipeline(
        steps: [
          _RecordingStep('primero', calls),
          _RecordingStep('segundo', calls),
        ],
      );

      final result = customPipeline.evaluateInput(
        numericInput(resultValue: '5'),
      );

      expect(calls, ['primero', 'segundo']);
      expect(result.status, ClinicalEvaluationStatus.pending);
    });

    test('evaluate usa el contexto recibido y devuelve un resultado nuevo', () {
      final context = ClinicalEvaluationContext(
        input: numericInput(
          resultValue: '5',
          dateOfBirthMs: birthDateMs,
          referenceDate: referenceDateMs,
          referenceValues: [ref(minValue: 0, maxValue: 10)],
        ),
      );

      final result = pipeline.evaluate(context);

      expect(result.status, ClinicalEvaluationStatus.normal);
      expect(context.status, ClinicalEvaluationStatus.normal);
      expect(result.ageInDays, context.ageInDays);
    });
  });
}

class _RecordingStep implements ClinicalEvaluationStep {
  _RecordingStep(this.name, this.calls);

  final String name;
  final List<String> calls;

  @override
  void execute(ClinicalEvaluationContext context) {
    calls.add(name);
  }
}
