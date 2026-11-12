import 'package:serum_business/serum_business.dart';
import 'package:test/test.dart';

void main() {
  ReferenceValue reference({double minValue = 70, double maxValue = 100}) {
    return ReferenceValue(
      patientType: 'general',
      gender: 'both',
      minAgeDays: 0,
      maxAgeDays: 36500,
      minValue: minValue,
      maxValue: maxValue,
    );
  }

  group('ClinicalAlertEvaluator.normalizeFlag', () {
    test('NORMAL, vacío y null no son alertas', () {
      expect(ClinicalAlertEvaluator.normalizeFlag('NORMAL'), isNull);
      expect(ClinicalAlertEvaluator.normalizeFlag(' normal '), isNull);
      expect(ClinicalAlertEvaluator.normalizeFlag(''), isNull);
      expect(ClinicalAlertEvaluator.normalizeFlag('   '), isNull);
      expect(ClinicalAlertEvaluator.normalizeFlag(null), isNull);
    });

    test('normaliza los alias de alto, bajo y anormal', () {
      expect(ClinicalAlertEvaluator.normalizeFlag('HIGH'), 'H');
      expect(ClinicalAlertEvaluator.normalizeFlag('ALTO'), 'H');
      expect(ClinicalAlertEvaluator.normalizeFlag(' h '), 'H');
      expect(ClinicalAlertEvaluator.normalizeFlag('LOW'), 'L');
      expect(ClinicalAlertEvaluator.normalizeFlag('BAJO'), 'L');
      expect(ClinicalAlertEvaluator.normalizeFlag('l'), 'L');
      expect(ClinicalAlertEvaluator.normalizeFlag('ABNORMAL'), 'ABNORMAL');
      expect(ClinicalAlertEvaluator.normalizeFlag('ANORMAL'), 'ABNORMAL');
      expect(ClinicalAlertEvaluator.normalizeFlag('*'), 'ABNORMAL');
    });
  });

  group('ClinicalAlertEvaluator.evaluateNumeric', () {
    test('marca H cuando el valor supera el máximo', () {
      expect(
        ClinicalAlertEvaluator.evaluateNumeric(
          value: 150,
          reference: reference(),
        ),
        'H',
      );
    });

    test('marca L cuando el valor está por debajo del mínimo', () {
      expect(
        ClinicalAlertEvaluator.evaluateNumeric(
          value: 60,
          reference: reference(),
        ),
        'L',
      );
    });

    test('no marca alerta cuando el valor está dentro del rango', () {
      expect(
        ClinicalAlertEvaluator.evaluateNumeric(
          value: 85,
          reference: reference(),
        ),
        isNull,
      );
    });

    test('no marca alerta cuando el valor o la referencia son nulos', () {
      expect(
        ClinicalAlertEvaluator.evaluateNumeric(
          value: null,
          reference: reference(),
        ),
        isNull,
      );
      expect(
        ClinicalAlertEvaluator.evaluateNumeric(value: 150, reference: null),
        isNull,
      );
    });
  });

  group('ClinicalAlertEvaluator.evaluateNumericText', () {
    test('parsea textos con comas de miles', () {
      expect(
        ClinicalAlertEvaluator.evaluateNumericText(
          text: '1,234.5',
          reference: reference(maxValue: 1000),
        ),
        'H',
      );
      expect(
        ClinicalAlertEvaluator.evaluateNumericText(
          text: '950.5',
          reference: reference(maxValue: 1000),
        ),
        isNull,
      );
      expect(
        ClinicalAlertEvaluator.evaluateNumericText(
          text: '0,5',
          reference: reference(minValue: 1),
        ),
        'L',
      );
    });

    test('devuelve null con texto no numérico o sin referencia', () {
      expect(
        ClinicalAlertEvaluator.evaluateNumericText(
          text: 'N/A',
          reference: reference(),
        ),
        isNull,
      );
      expect(
        ClinicalAlertEvaluator.evaluateNumericText(
          text: '150',
          reference: null,
        ),
        isNull,
      );
    });
  });

  group('ClinicalAlertEvaluator.evaluateQualitative', () {
    test('no marca alerta cuando coincide con el valor esperado', () {
      expect(
        ClinicalAlertEvaluator.evaluateQualitative(
          value: 'Negativo',
          expected: 'Negativo',
        ),
        isNull,
      );
    });

    test('marca ABNORMAL cuando difiere del valor esperado', () {
      expect(
        ClinicalAlertEvaluator.evaluateQualitative(
          value: 'Positivo',
          expected: 'Negativo',
        ),
        'ABNORMAL',
      );
    });

    test('ignora mayúsculas y espacios periféricos al comparar', () {
      expect(
        ClinicalAlertEvaluator.evaluateQualitative(
          value: '  negativo ',
          expected: 'Negativo',
        ),
        isNull,
      );
      expect(
        ClinicalAlertEvaluator.evaluateQualitative(
          value: 'POSITIVO',
          expected: 'positivo',
        ),
        isNull,
      );
    });

    test('no marca alerta sin valor capturado o sin esperado', () {
      expect(
        ClinicalAlertEvaluator.evaluateQualitative(
          value: null,
          expected: 'Negativo',
        ),
        isNull,
      );
      expect(
        ClinicalAlertEvaluator.evaluateQualitative(
          value: '   ',
          expected: 'Negativo',
        ),
        isNull,
      );
      expect(
        ClinicalAlertEvaluator.evaluateQualitative(
          value: 'Positivo',
          expected: null,
        ),
        isNull,
      );
    });
  });

  group('ClinicalAlertEvaluator.canEvaluateResult', () {
    test('numérico requiere rango y valor parseable', () {
      expect(
        ClinicalAlertEvaluator.canEvaluateResult(
          dataType: 'numeric',
          resultValue: '150',
          expectedQualitativeValue: null,
          reference: reference(),
        ),
        isTrue,
      );
      expect(
        ClinicalAlertEvaluator.canEvaluateResult(
          dataType: 'numeric',
          resultValue: 'N/A',
          expectedQualitativeValue: null,
          reference: reference(),
        ),
        isFalse,
      );
      expect(
        ClinicalAlertEvaluator.canEvaluateResult(
          dataType: 'numeric',
          resultValue: '<0.5',
          expectedQualitativeValue: null,
          reference: reference(),
        ),
        isFalse,
      );
      expect(
        ClinicalAlertEvaluator.canEvaluateResult(
          dataType: 'numeric',
          resultValue: '150',
          expectedQualitativeValue: null,
          reference: null,
        ),
        isFalse,
      );
    });

    test('cualitativo requiere valor y esperado', () {
      expect(
        ClinicalAlertEvaluator.canEvaluateResult(
          dataType: 'qualitative',
          resultValue: 'Negativo',
          expectedQualitativeValue: 'Negativo',
          reference: null,
        ),
        isTrue,
      );
      expect(
        ClinicalAlertEvaluator.canEvaluateResult(
          dataType: 'qualitative',
          resultValue: 'Negativo',
          expectedQualitativeValue: null,
          reference: null,
        ),
        isFalse,
      );
    });

    test('texto libre no es evaluable', () {
      expect(
        ClinicalAlertEvaluator.canEvaluateResult(
          dataType: 'text',
          resultValue: 'Descripción',
          expectedQualitativeValue: null,
          reference: null,
        ),
        isFalse,
      );
    });
  });

  group('OrderTestResult.fromJson', () {
    test('normaliza alertFlag NORMAL a null', () {
      final result = OrderTestResult.fromJson({
        'labTestId': 'lt-1',
        'parameterName': 'Glucosa',
        'dataType': 'numeric',
        'alertFlag': 'NORMAL',
      });

      expect(result.alertFlag, isNull);
    });

    test('normaliza alertFlag HIGH a H', () {
      final result = OrderTestResult.fromJson({
        'labTestId': 'lt-1',
        'parameterName': 'Glucosa',
        'dataType': 'numeric',
        'alertFlag': 'HIGH',
      });

      expect(result.alertFlag, 'H');
    });
  });

  group('ClinicalAlertEvaluator.evaluateResult', () {
    test('numérico recalcula con el rango resuelto', () {
      expect(
        ClinicalAlertEvaluator.evaluateResult(
          dataType: 'numeric',
          resultValue: '1,150',
          expectedQualitativeValue: null,
          reference: reference(maxValue: 1000),
        ),
        'H',
      );
    });

    test('cualitativo recalcula contra el esperado', () {
      expect(
        ClinicalAlertEvaluator.evaluateResult(
          dataType: 'qualitative',
          resultValue: 'Reactivo',
          expectedQualitativeValue: 'No reactivo',
          reference: null,
        ),
        'ABNORMAL',
      );
    });

    test('sin valor capturado no genera alerta', () {
      expect(
        ClinicalAlertEvaluator.evaluateResult(
          dataType: 'numeric',
          resultValue: '   ',
          expectedQualitativeValue: null,
          reference: reference(),
        ),
        isNull,
      );
    });

    test('texto libre no genera alerta', () {
      expect(
        ClinicalAlertEvaluator.evaluateResult(
          dataType: 'text',
          resultValue: 'Descripción macroscópica',
          expectedQualitativeValue: null,
          reference: reference(),
        ),
        isNull,
      );
    });
  });
}
