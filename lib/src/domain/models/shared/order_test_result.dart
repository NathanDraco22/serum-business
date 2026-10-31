import 'package:serum_business/src/domain/models/shared/included_test.dart';
import 'package:serum_business/src/domain/models/shared/reference_value.dart';

class OrderTestResult extends IncludedTest {
  final String? resultValue;
  final String? alertFlag;
  final bool showInPrint;

  OrderTestResult({
    required super.labTestId,
    required super.parameterName,
    super.medicalClassification = '',
    super.subclassification = '',
    required super.dataType,
    super.unitOfMeasure = '',
    super.referenceValues = const [],
    super.qualitativeOptions = const [],
    super.expectedQualitativeValue,
    super.referenceText = '',
    this.resultValue,
    this.alertFlag,
    this.showInPrint = true,
  });

  factory OrderTestResult.fromJson(Map<String, dynamic> json) {
    return OrderTestResult(
      labTestId: json['labTestId'] as String? ?? '',
      parameterName: json['parameterName'] as String? ?? json['testName'] as String? ?? '',
      medicalClassification: json['medicalClassification'] as String? ?? '',
      subclassification: json['subclassification'] as String? ?? '',
      dataType: json['dataType'] as String? ?? 'numeric',
      unitOfMeasure: json['unitOfMeasure'] as String? ?? '',
      referenceValues: (json['referenceValues'] as List<dynamic>?)
              ?.map((e) => ReferenceValue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      qualitativeOptions: (json['qualitativeOptions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      expectedQualitativeValue: json['expectedQualitativeValue'] as String?,
      referenceText: json['referenceText'] as String? ?? '',
      resultValue: json['resultValue'] as String?,
      alertFlag: json['alertFlag'] as String?,
      showInPrint: json['showInPrint'] as bool? ?? true,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'resultValue': resultValue,
      'alertFlag': alertFlag,
      'showInPrint': showInPrint,
    };
  }

  OrderTestResult copyWith({
    String? labTestId,
    String? parameterName,
    String? medicalClassification,
    String? subclassification,
    String? dataType,
    String? unitOfMeasure,
    List<ReferenceValue>? referenceValues,
    List<String>? qualitativeOptions,
    String? expectedQualitativeValue,
    String? referenceText,
    String? resultValue,
    String? alertFlag,
    bool? showInPrint,
  }) {
    return OrderTestResult(
      labTestId: labTestId ?? this.labTestId,
      parameterName: parameterName ?? this.parameterName,
      medicalClassification: medicalClassification ?? this.medicalClassification,
      subclassification: subclassification ?? this.subclassification,
      dataType: dataType ?? this.dataType,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      referenceValues: referenceValues ?? this.referenceValues,
      qualitativeOptions: qualitativeOptions ?? this.qualitativeOptions,
      expectedQualitativeValue: expectedQualitativeValue ?? this.expectedQualitativeValue,
      referenceText: referenceText ?? this.referenceText,
      resultValue: resultValue ?? this.resultValue,
      alertFlag: alertFlag ?? this.alertFlag,
      showInPrint: showInPrint ?? this.showInPrint,
    );
  }
}
