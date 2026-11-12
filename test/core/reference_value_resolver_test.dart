import 'package:test/test.dart';
import 'package:serum_business/serum_business.dart';

void main() {
  ReferenceValue ref({
    String gender = 'both',
    int minAgeDays = 0,
    int maxAgeDays = 0,
    double minValue = 0,
    double maxValue = 100,
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

  group('ReferenceValue.ageUnit', () {
    ReferenceValue fromJson({
      required int minAgeDays,
      required int maxAgeDays,
      String? ageUnit,
    }) {
      return ReferenceValue.fromJson({
        'patientType': 'general',
        'gender': 'both',
        'minAgeDays': minAgeDays,
        'maxAgeDays': maxAgeDays,
        'minValue': 0,
        'maxValue': 100,
        if (ageUnit != null) 'ageUnit': ageUnit,
      });
    }

    test('fromJson conserva ageUnit cuando viene explícito', () {
      final value = fromJson(minAgeDays: 0, maxAgeDays: 720, ageUnit: 'days');

      expect(value.ageUnit, 'days');
    });

    test(
      'fromJson infiere years cuando ambos límites son múltiplos de 365',
      () {
        final value = fromJson(minAgeDays: 6570, maxAgeDays: 21900);

        expect(value.ageUnit, 'years');
      },
    );

    test(
      'fromJson infiere months cuando ambos límites son múltiplos de 30',
      () {
        final value = fromJson(minAgeDays: 0, maxAgeDays: 720);

        expect(value.ageUnit, 'months');
      },
    );

    test('fromJson infiere days en el resto de los casos', () {
      final value = fromJson(minAgeDays: 0, maxAgeDays: 28);

      expect(value.ageUnit, 'days');
    });

    test('toJson incluye ageUnit', () {
      final json = ref(ageUnit: 'months').toJson();

      expect(json['ageUnit'], 'months');
    });

    test('copyWith actualiza ageUnit', () {
      final value = ref(ageUnit: 'years').copyWith(ageUnit: 'days');

      expect(value.ageUnit, 'days');
    });
  });

  group('ReferenceValueResolver.ageInDaysAt', () {
    test('calcula días exactos desde la fecha de nacimiento', () {
      final birth = DateTime(2020, 1, 1);
      final reference = DateTime(2020, 1, 31);

      final days = ReferenceValueResolver.ageInDaysAt(
        dateOfBirthMs: birth.millisecondsSinceEpoch,
        referenceDateMs: reference.millisecondsSinceEpoch,
      );

      expect(days, 30);
    });

    test('usa la edad en años como respaldo cuando no hay fecha', () {
      final days = ReferenceValueResolver.ageInDaysAt(
        dateOfBirthMs: 0,
        referenceDateMs: 0,
        fallbackAgeYears: 30,
      );

      expect(days, 30 * 365);
    });

    test('no devuelve edades negativas', () {
      final days = ReferenceValueResolver.ageInDaysAt(
        dateOfBirthMs: DateTime(2030, 1, 1).millisecondsSinceEpoch,
        referenceDateMs: DateTime(2020, 1, 1).millisecondsSinceEpoch,
      );

      expect(days, 0);
    });

    test('tryAgeInDaysAt distingue edad desconocida de 0 días', () {
      expect(
        ReferenceValueResolver.tryAgeInDaysAt(
          dateOfBirthMs: 0,
          referenceDateMs: 0,
        ),
        isNull,
      );
      expect(
        ReferenceValueResolver.tryAgeInDaysAt(
          dateOfBirthMs: 0,
          referenceDateMs: 0,
          fallbackAgeYears: 0,
        ),
        0,
      );
      expect(
        ReferenceValueResolver.tryAgeInDaysAt(
          dateOfBirthMs: DateTime(2030, 1, 1).millisecondsSinceEpoch,
          referenceDateMs: DateTime(2020, 1, 1).millisecondsSinceEpoch,
        ),
        isNull,
      );
    });

    test(
      'devuelve null si hay fecha de nacimiento pero no fecha de referencia',
      () {
        expect(
          ReferenceValueResolver.tryAgeInDaysAt(
            dateOfBirthMs: DateTime(2020, 1, 1).millisecondsSinceEpoch,
            referenceDateMs: 0,
          ),
          isNull,
        );
      },
    );
  });

  group('ReferenceValueResolver.normalizeGender', () {
    test('normaliza los valores habituales', () {
      expect(ReferenceValueResolver.normalizeGender('M'), 'male');
      expect(ReferenceValueResolver.normalizeGender('masculino'), 'male');
      expect(ReferenceValueResolver.normalizeGender('F'), 'female');
      expect(ReferenceValueResolver.normalizeGender('mujer'), 'female');
      expect(ReferenceValueResolver.normalizeGender('both'), 'both');
      expect(ReferenceValueResolver.normalizeGender('todos'), 'both');
    });
  });

  group('ReferenceValueResolver.resolve', () {
    test('ignora edad y género cuando ambos flags están apagados', () {
      final values = [
        ref(
          minAgeDays: 6570,
          maxAgeDays: 43800,
          useAge: false,
          useGender: false,
        ),
      ];

      final result = ReferenceValueResolver.resolve(
        values: values,
        ageInDays: 30,
        gender: 'female',
      );

      expect(result, isNotNull);
    });

    test('usa edad cuando useAge está encendido', () {
      final values = [
        ref(minAgeDays: 0, maxAgeDays: 365, minValue: 1, useAge: true),
        ref(minAgeDays: 6570, maxAgeDays: 43800, minValue: 2, useAge: true),
      ];

      final child = ReferenceValueResolver.resolve(
        values: values,
        ageInDays: 100,
        gender: 'both',
      );
      final adult = ReferenceValueResolver.resolve(
        values: values,
        ageInDays: 30 * 365,
        gender: 'both',
      );

      expect(child?.minValue, 1);
      expect(adult?.minValue, 2);
    });

    test('usa género cuando useGender está encendido', () {
      final values = [
        ref(gender: 'male', minValue: 1, useGender: true),
        ref(gender: 'female', minValue: 2, useGender: true),
      ];

      final male = ReferenceValueResolver.resolve(
        values: values,
        ageInDays: 30 * 365,
        gender: 'M',
      );
      final female = ReferenceValueResolver.resolve(
        values: values,
        ageInDays: 30 * 365,
        gender: 'F',
      );

      expect(male?.minValue, 1);
      expect(female?.minValue, 2);
    });

    test('prefiere el rango más específico cuando varios coinciden', () {
      final values = [
        ref(minAgeDays: 0, maxAgeDays: 43800, minValue: 1, useAge: false),
        ref(
          minAgeDays: 0,
          maxAgeDays: 43800,
          minValue: 2,
          useAge: true,
          useGender: true,
        ),
      ];

      final result = ReferenceValueResolver.resolve(
        values: values,
        ageInDays: 30 * 365,
        gender: 'M',
      );

      expect(result?.minValue, 2);
    });

    test('devuelve null cuando no hay coincidencia', () {
      final values = [ref(gender: 'male', minValue: 1, useGender: true)];

      final result = ReferenceValueResolver.resolve(
        values: values,
        ageInDays: 30 * 365,
        gender: 'F',
      );

      expect(result, isNull);
    });

    test('con edad desconocida solo aplica rangos generales', () {
      final values = [
        ref(minAgeDays: 0, maxAgeDays: 28, minValue: 1, useAge: true),
        ref(minValue: 2),
      ];

      final result = ReferenceValueResolver.resolve(
        values: values,
        ageInDays: null,
        gender: 'both',
      );

      expect(result?.minValue, 2);
    });

    test('con edad desconocida devuelve null si solo hay rangos por edad', () {
      final values = [
        ref(minAgeDays: 0, maxAgeDays: 28, minValue: 1, useAge: true),
      ];

      final result = ReferenceValueResolver.resolve(
        values: values,
        ageInDays: null,
        gender: 'both',
      );

      expect(result, isNull);
    });

    test('con género desconocido no aplica rangos por género', () {
      final values = [
        ref(gender: 'male', minValue: 1, useGender: true),
        ref(gender: 'female', minValue: 2, useGender: true),
        ref(gender: 'both', minValue: 3),
      ];

      final result = ReferenceValueResolver.resolve(
        values: values,
        ageInDays: 30 * 365,
        gender: '',
      );

      expect(result?.minValue, 3);
    });
  });

  group('ReferenceValueResolver.formatAgeDays', () {
    test('formatea días, meses y años', () {
      expect(ReferenceValueResolver.formatAgeDays(0), '0 días');
      expect(ReferenceValueResolver.formatAgeDays(1), '1 día');
      expect(ReferenceValueResolver.formatAgeDays(29), '29 días');
      expect(ReferenceValueResolver.formatAgeDays(30), '1 mes');
      expect(ReferenceValueResolver.formatAgeDays(90), '3 meses');
      expect(ReferenceValueResolver.formatAgeDays(335), '11 meses y 5 días');
      expect(ReferenceValueResolver.formatAgeDays(365), '1 año');
      expect(ReferenceValueResolver.formatAgeDays(366), '1 año y 1 día');
      expect(ReferenceValueResolver.formatAgeDays(730), '2 años');
    });
  });

  group('ReferenceValueResolver.formatReferenceAge', () {
    test('respeta la unidad configurada del rango', () {
      expect(
        ReferenceValueResolver.formatReferenceAge(
          ref(
            minAgeDays: 20 * 365,
            maxAgeDays: 25 * 365,
            ageUnit: 'years',
            useAge: true,
          ),
        ),
        '20 - 25 años',
      );
      expect(
        ReferenceValueResolver.formatReferenceAge(
          ref(minAgeDays: 30, maxAgeDays: 360, ageUnit: 'months', useAge: true),
        ),
        '1 - 12 meses',
      );
      expect(
        ReferenceValueResolver.formatReferenceAge(
          ref(minAgeDays: 0, maxAgeDays: 28, ageUnit: 'days', useAge: true),
        ),
        '0 - 28 días',
      );
    });

    test('devuelve vacío cuando el rango no evalúa edad', () {
      expect(
        ReferenceValueResolver.formatReferenceAge(ref(useAge: false)),
        isEmpty,
      );
    });

    test('maneja todas las edades y rangos sin límite superior', () {
      expect(
        ReferenceValueResolver.formatReferenceAge(
          ref(minAgeDays: 0, maxAgeDays: 43800, ageUnit: 'years', useAge: true),
        ),
        'Todas las edades',
      );
      expect(
        ReferenceValueResolver.formatReferenceAge(
          ref(
            minAgeDays: 18 * 365,
            maxAgeDays: 0,
            ageUnit: 'years',
            useAge: true,
          ),
        ),
        'Desde 18 años',
      );
    });
  });

  group('ReferenceValueResolver.formatAgeRange', () {
    test('formatea días, meses y años', () {
      expect(
        ReferenceValueResolver.formatAgeRange(0, 30, useAge: true),
        '0 días - 1 mes',
      );
      expect(
        ReferenceValueResolver.formatAgeRange(6570, 43800, useAge: true),
        '18 años - 120 años',
      );
      expect(
        ReferenceValueResolver.formatAgeRange(0, 43800, useAge: true),
        'Todas las edades',
      );
      expect(
        ReferenceValueResolver.formatAgeRange(0, 43800, useAge: false),
        'Todas las edades',
      );
    });
  });
}
