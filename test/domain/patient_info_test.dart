import 'package:serum_business/serum_business.dart';
import 'package:test/test.dart';

void main() {
  group('PatientInfo demografía', () {
    test('no serializa age cuando no hay dato demográfico', () {
      final info = PatientInfo(name: 'Sin datos', gender: '');

      final json = info.toJson();

      expect(json.containsKey('age'), isFalse);
    });

    test('fromJson trata age=0 sin fecha como edad desconocida', () {
      final info = PatientInfo.fromJson({
        'name': 'Sin datos',
        'dateOfBirth': 0,
        'age': 0,
      });

      expect(info.explicitAge, isNull);
    });

    test('fromJson conserva age=0 cuando hay fecha de nacimiento', () {
      final info = PatientInfo.fromJson({
        'name': 'Recién nacido',
        'dateOfBirth': 123,
        'age': 0,
      });

      expect(info.explicitAge, 0);
    });

    test('fromJson conserva age>0 sin fecha de nacimiento', () {
      final info = PatientInfo.fromJson({
        'name': 'Adulto sin fecha',
        'dateOfBirth': 0,
        'age': 30,
      });

      expect(info.explicitAge, 30);
    });
  });
}
