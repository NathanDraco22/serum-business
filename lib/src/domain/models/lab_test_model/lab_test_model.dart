import 'package:serum_business/src/domain/models/lab_test_account_model/commercial_model.dart';
import 'package:serum_business/src/domain/models/shared/reference_value.dart';

class BaseLabTest {
  final String name;
  final String? code;
  final String commercialCategory;
  final int salePrice;
  final int salePrice2;
  final int costPrice;
  final String currency;
  final bool isPack;
  final bool useChildTestsPriceSum;
  final List<String> childTestIds;
  final String dataType;
  final String unitOfMeasure;
  final List<ReferenceValue> referenceValues;
  final List<String> qualitativeOptions;
  final String? expectedQualitativeValue;
  final String referenceText;

  String get parameterName => name;
  String get medicalClassification => commercialCategory;

  BaseLabTest({
    required this.name,
    this.code,
    this.commercialCategory = '',
    this.salePrice = 0,
    this.salePrice2 = 0,
    this.costPrice = 0,
    this.currency = 'USD',
    this.isPack = false,
    this.useChildTestsPriceSum = true,
    this.childTestIds = const [],
    this.dataType = 'numeric',
    this.unitOfMeasure = '',
    this.referenceValues = const [],
    this.qualitativeOptions = const [],
    this.expectedQualitativeValue,
    this.referenceText = '',
  });
}

class CreateLabTest extends BaseLabTest {
  final String branchId;

  CreateLabTest({
    required this.branchId,
    required super.name,
    super.code,
    super.commercialCategory = '',
    super.salePrice = 0,
    super.salePrice2 = 0,
    super.costPrice = 0,
    super.currency = 'USD',
    super.isPack = false,
    super.useChildTestsPriceSum = true,
    super.childTestIds = const [],
    super.dataType = 'numeric',
    super.unitOfMeasure = '',
    super.referenceValues = const [],
    super.qualitativeOptions = const [],
    super.expectedQualitativeValue,
    super.referenceText = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'name': name,
      'parameterName': name,
      'code': code,
      'commercialCategory': commercialCategory,
      'salePrice': salePrice,
      'salePrice2': salePrice2,
      'costPrice': costPrice,
      'currency': currency,
      'isPack': isPack,
      'useChildTestsPriceSum': useChildTestsPriceSum,
      'childTestIds': childTestIds,
      'dataType': dataType,
      'unitOfMeasure': unitOfMeasure,
      'referenceValues': referenceValues.map((e) => e.toJson()).toList(),
      'qualitativeOptions': qualitativeOptions,
      'expectedQualitativeValue': expectedQualitativeValue,
      'referenceText': referenceText,
    };
  }
}

class UpdateLabTest {
  final String? branchId;
  final String? name;
  final String? code;
  final String? commercialCategory;
  final int? salePrice;
  final int? salePrice2;
  final int? costPrice;
  final String? currency;
  final bool? isPack;
  final bool? useChildTestsPriceSum;
  final List<String>? childTestIds;
  final String? dataType;
  final String? unitOfMeasure;
  final List<ReferenceValue>? referenceValues;
  final List<String>? qualitativeOptions;
  final String? expectedQualitativeValue;
  final String? referenceText;

  UpdateLabTest({
    this.branchId,
    this.name,
    this.code,
    this.commercialCategory,
    this.salePrice,
    this.salePrice2,
    this.costPrice,
    this.currency,
    this.isPack,
    this.useChildTestsPriceSum,
    this.childTestIds,
    this.dataType,
    this.unitOfMeasure,
    this.referenceValues,
    this.qualitativeOptions,
    this.expectedQualitativeValue,
    this.referenceText,
  });

  Map<String, dynamic> toJson() {
    return {
      if (branchId != null) 'branchId': branchId,
      if (name != null) 'name': name,
      if (name != null) 'parameterName': name,
      if (code != null) 'code': code,
      if (commercialCategory != null) 'commercialCategory': commercialCategory,
      if (salePrice != null) 'salePrice': salePrice,
      if (salePrice2 != null) 'salePrice2': salePrice2,
      if (costPrice != null) 'costPrice': costPrice,
      if (currency != null) 'currency': currency,
      if (isPack != null) 'isPack': isPack,
      if (useChildTestsPriceSum != null)
        'useChildTestsPriceSum': useChildTestsPriceSum,
      if (childTestIds != null) 'childTestIds': childTestIds,
      if (dataType != null) 'dataType': dataType,
      if (unitOfMeasure != null) 'unitOfMeasure': unitOfMeasure,
      if (referenceValues != null)
        'referenceValues': referenceValues!.map((e) => e.toJson()).toList(),
      if (qualitativeOptions != null) 'qualitativeOptions': qualitativeOptions,
      if (expectedQualitativeValue != null)
        'expectedQualitativeValue': expectedQualitativeValue,
      if (referenceText != null) 'referenceText': referenceText,
    };
  }
}

class LabTestInDb extends BaseLabTest {
  final String id;
  final int createdAt;
  final int? updatedAt;
  final bool isDeleted;
  final LabTestCommercial? commercial;

  LabTestInDb({
    required this.id,
    required super.name,
    super.code,
    super.commercialCategory = '',
    super.salePrice = 0,
    super.salePrice2 = 0,
    super.costPrice = 0,
    super.currency = 'USD',
    super.isPack = false,
    super.useChildTestsPriceSum = true,
    super.childTestIds = const [],
    super.dataType = 'numeric',
    super.unitOfMeasure = '',
    super.referenceValues = const [],
    super.qualitativeOptions = const [],
    super.expectedQualitativeValue,
    super.referenceText = '',
    this.commercial,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  factory LabTestInDb.fromJson(Map<String, dynamic> json) {
    final rawName =
        json['name'] as String? ?? json['parameterName'] as String? ?? '';
    final rawCategory = json['commercialCategory'] as String? ??
        json['medicalClassification'] as String? ??
        '';
    final rawCommercial = json['commercial'] != null
        ? LabTestCommercial.fromJson(json['commercial'] as Map<String, dynamic>)
        : null;
    final parsedCost = (json['costPrice'] as num?)?.toInt() ??
        rawCommercial?.costPrice ??
        0;

    return LabTestInDb(
      id: json['id'] as String,
      name: rawName,
      code: json['code'] as String?,
      commercialCategory: rawCategory,
      salePrice: (json['salePrice'] as num?)?.toInt() ??
          rawCommercial?.salePrice ??
          0,
      salePrice2: (json['salePrice2'] as num?)?.toInt() ??
          rawCommercial?.salePrice2 ??
          0,
      costPrice: parsedCost,
      currency: json['currency'] as String? ??
          rawCommercial?.currency ??
          'USD',
      isPack: json['isPack'] as bool? ?? false,
      useChildTestsPriceSum: json['useChildTestsPriceSum'] as bool? ?? true,
      childTestIds: (json['childTestIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
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
      commercial: rawCommercial,
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int?,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parameterName': name,
      'code': code,
      'commercialCategory': commercialCategory,
      'salePrice': salePrice,
      'salePrice2': salePrice2,
      'costPrice': costPrice,
      'currency': currency,
      'isPack': isPack,
      'useChildTestsPriceSum': useChildTestsPriceSum,
      'childTestIds': childTestIds,
      'dataType': dataType,
      'unitOfMeasure': unitOfMeasure,
      'referenceValues': referenceValues.map((e) => e.toJson()).toList(),
      'qualitativeOptions': qualitativeOptions,
      'expectedQualitativeValue': expectedQualitativeValue,
      'referenceText': referenceText,
      'commercial': commercial?.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
    };
  }

  LabTestInDb copyWith({
    String? id,
    String? name,
    String? code,
    String? commercialCategory,
    int? salePrice,
    int? salePrice2,
    int? costPrice,
    String? currency,
    bool? isPack,
    bool? useChildTestsPriceSum,
    List<String>? childTestIds,
    String? dataType,
    String? unitOfMeasure,
    List<ReferenceValue>? referenceValues,
    List<String>? qualitativeOptions,
    String? expectedQualitativeValue,
    String? referenceText,
    LabTestCommercial? commercial,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
  }) {
    return LabTestInDb(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      commercialCategory: commercialCategory ?? this.commercialCategory,
      salePrice: salePrice ?? this.salePrice,
      salePrice2: salePrice2 ?? this.salePrice2,
      costPrice: costPrice ?? this.costPrice,
      currency: currency ?? this.currency,
      isPack: isPack ?? this.isPack,
      useChildTestsPriceSum:
          useChildTestsPriceSum ?? this.useChildTestsPriceSum,
      childTestIds: childTestIds ?? this.childTestIds,
      dataType: dataType ?? this.dataType,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      referenceValues: referenceValues ?? this.referenceValues,
      qualitativeOptions: qualitativeOptions ?? this.qualitativeOptions,
      expectedQualitativeValue:
          expectedQualitativeValue ?? this.expectedQualitativeValue,
      referenceText: referenceText ?? this.referenceText,
      commercial: commercial ?? this.commercial,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
