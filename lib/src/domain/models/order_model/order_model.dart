import 'package:serum_business/src/domain/models/shared/order_test_result.dart';
import 'package:serum_business/src/domain/models/shared/user_info.dart';

class PatientInfo {
  final String name;
  final int dateOfBirth;
  final String gender;
  final String phone;
  final String address;
  final String? cardId;
  final String? email;
  final int? explicitAge;

  PatientInfo({
    required this.name,
    this.dateOfBirth = 0,
    this.gender = '',
    this.phone = '',
    this.address = '',
    this.cardId,
    this.email,
    int? age,
  }) : explicitAge = age;

  int get age {
    if (explicitAge != null && explicitAge! >= 0) return explicitAge!;
    if (dateOfBirth <= 0) return 0;
    final birth = DateTime.fromMillisecondsSinceEpoch(dateOfBirth);
    final today = DateTime.now();
    int a = today.year - birth.year;
    if (today.month < birth.month ||
        (today.month == birth.month && today.day < birth.day)) {
      a--;
    }
    return a >= 0 ? a : 0;
  }

  factory PatientInfo.fromJson(Map<String, dynamic> json) {
    final dateOfBirth = (json['dateOfBirth'] as num?)?.toInt() ?? 0;
    final rawAge = (json['age'] as num?)?.toInt();
    // `age: 0` sin fecha de nacimiento es ambiguo: puede ser un recién nacido
    // o un snapshot viejo que serializó "sin edad" como 0. Se trata como
    // desconocido; la fecha de nacimiento sigue siendo la fuente principal.
    final explicitAge = rawAge != null && (rawAge > 0 || dateOfBirth > 0)
        ? rawAge
        : null;

    return PatientInfo(
      name: json['name'] as String? ?? '',
      dateOfBirth: dateOfBirth,
      gender: json['gender'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      cardId: json['cardId'] as String?,
      email: json['email'] as String?,
      age: explicitAge,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'phone': phone,
      'address': address,
      if (cardId != null) 'cardId': cardId,
      if (email != null) 'email': email,
      if (explicitAge != null) 'age': explicitAge!,
    };
  }
}

class DoctorInfo {
  final String name;
  final String specialty;
  final String phone;
  final String? cardId;
  final String? email;

  DoctorInfo({
    required this.name,
    this.specialty = 'Medicina General',
    this.phone = '',
    this.cardId,
    this.email,
  });

  factory DoctorInfo.fromJson(Map<String, dynamic> json) {
    return DoctorInfo(
      name: json['name'] as String? ?? '',
      specialty: json['specialty'] as String? ?? 'Medicina General',
      phone: json['phone'] as String? ?? '',
      cardId: json['cardId'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'specialty': specialty,
      'phone': phone,
      if (cardId != null) 'cardId': cardId,
      if (email != null) 'email': email,
    };
  }
}

class OrderItem {
  final String labTestId;
  final String name;
  final int salePriceApplied;
  final int originalPrice;
  final bool isPack;
  final int priceLevel;

  OrderItem({
    required this.labTestId,
    required this.name,
    required this.salePriceApplied,
    this.originalPrice = 0,
    this.isPack = false,
    this.priceLevel = 1,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final salePrice = (json['salePriceApplied'] as num?)?.toInt() ?? 0;
    return OrderItem(
      labTestId:
          json['labTestId'] as String? ?? json['examId'] as String? ?? '',
      name: json['name'] as String? ?? json['examName'] as String? ?? '',
      salePriceApplied: salePrice,
      originalPrice: (json['originalPrice'] as num?)?.toInt() ?? salePrice,
      isPack: json['isPack'] as bool? ?? false,
      priceLevel: (json['priceLevel'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'labTestId': labTestId,
      'name': name,
      'salePriceApplied': salePriceApplied,
      'originalPrice': originalPrice > 0 ? originalPrice : salePriceApplied,
      'isPack': isPack,
      'priceLevel': priceLevel,
    };
  }
}

class OrderService {
  final String? id;
  final String name;
  final int price;

  OrderService({this.id, required this.name, required this.price});

  factory OrderService.fromJson(Map<String, dynamic> json) {
    return OrderService(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {if (id != null) 'id': id, 'name': name, 'price': price};
  }

  OrderService copyWith({String? id, String? name, int? price}) {
    return OrderService(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }
}

class OrderDiscount {
  final String? id;
  final String description;
  final String type; // 'percentage' | 'amount'
  final double value;
  final int appliedAmount; // Monto deducido en centavos

  OrderDiscount({
    this.id,
    required this.description,
    this.type = 'percentage',
    this.value = 0.0,
    this.appliedAmount = 0,
  });

  bool get isPercentage => type == 'percentage';
  bool get isAmount => type == 'amount';

  factory OrderDiscount.fromJson(Map<String, dynamic> json) {
    return OrderDiscount(
      id: json['id'] as String?,
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'percentage',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      appliedAmount: (json['appliedAmount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'description': description,
      'type': type,
      'value': value,
      'appliedAmount': appliedAmount,
    };
  }

  OrderDiscount copyWith({
    String? id,
    String? description,
    String? type,
    double? value,
    int? appliedAmount,
  }) {
    return OrderDiscount(
      id: id ?? this.id,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      appliedAmount: appliedAmount ?? this.appliedAmount,
    );
  }
}

class OrderApproval {
  final bool requiresApproval;
  final bool isApproved;
  final UserInfo? approvedBy;
  final int? approvedAt;
  final String? reason;

  OrderApproval({
    this.requiresApproval = false,
    this.isApproved = false,
    this.approvedBy,
    this.approvedAt,
    this.reason,
  });

  factory OrderApproval.fromJson(Map<String, dynamic> json) {
    return OrderApproval(
      requiresApproval: json['requiresApproval'] as bool? ?? false,
      isApproved: json['isApproved'] as bool? ?? false,
      approvedBy: json['approvedBy'] != null
          ? UserInfo.fromJson(json['approvedBy'] as Map<String, dynamic>)
          : null,
      approvedAt: (json['approvedAt'] as num?)?.toInt(),
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requiresApproval': requiresApproval,
      'isApproved': isApproved,
      if (approvedBy != null) 'approvedBy': approvedBy!.toJson(),
      if (approvedAt != null) 'approvedAt': approvedAt,
      if (reason != null) 'reason': reason,
    };
  }
}

class OrderStatusChange {
  final String status;
  final int changedAt;
  final UserInfo? changedBy;
  final String? reason;

  OrderStatusChange({
    required this.status,
    required this.changedAt,
    this.changedBy,
    this.reason,
  });

  factory OrderStatusChange.fromJson(Map<String, dynamic> json) {
    return OrderStatusChange(
      status: json['status'] as String? ?? '',
      changedAt: (json['changedAt'] as num?)?.toInt() ?? 0,
      changedBy: json['changedBy'] != null
          ? UserInfo.fromJson(json['changedBy'] as Map<String, dynamic>)
          : null,
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'changedAt': changedAt,
      if (changedBy != null) 'changedBy': changedBy!.toJson(),
      if (reason != null) 'reason': reason,
    };
  }
}

class OrderReopenRequest {
  final String reason;

  OrderReopenRequest({required this.reason});

  Map<String, dynamic> toJson() {
    return {'reason': reason};
  }
}

class BaseOrder {
  final String patientId;
  final String branchId;
  final String? doctorId;
  final PatientInfo? patientInfo;
  final DoctorInfo? doctorInfo;
  final String? quotationId;
  final List<OrderItem> items;
  final List<OrderService> services;
  final List<OrderDiscount> discounts;
  final int totalPrice;
  final int paidAmount;
  final String status;
  final List<OrderTestResult> results;
  final bool isBlocked;
  final OrderApproval? approval;
  final String? notes;

  // Backward compatibility getters
  String? get description => notes;
  String get examId => items.isNotEmpty ? items.first.labTestId : '';
  String get examName =>
      items.isNotEmpty ? items.map((e) => e.name).join(', ') : '';
  int get grossTotal {
    final itemsSum = items.fold<int>(0, (sum, i) => sum + i.salePriceApplied);
    final servicesSum = services.fold<int>(0, (sum, s) => sum + s.price);
    return itemsSum + servicesSum;
  }

  int get totalDiscounts {
    return discounts.fold<int>(0, (sum, d) => sum + d.appliedAmount);
  }

  int get salePriceApplied {
    if (totalPrice > 0) return totalPrice;
    final total = grossTotal - totalDiscounts;
    return total > 0 ? total : 0;
  }

  /// Total efectivo de la orden. Es la base para decidir el estado financiero.
  int get effectiveTotalPrice => salePriceApplied;

  /// Una orden está liquidada cuando ya cubrió su total, o cuando su total es cero.
  bool get isFullyPaid =>
      effectiveTotalPrice <= 0 || paidAmount >= effectiveTotalPrice;

  bool get isPartiallyPaid => paidAmount > 0 && !isFullyPaid;

  bool get isUnpaid => paidAmount <= 0;

  /// Indica si la orden está esperando la validación/finalización clínica.
  bool get isInReview => status == 'in_review';

  /// Todos los parámetros clínicos tienen un valor capturado.
  bool get hasAllResults =>
      results.isNotEmpty &&
      results.every(
        (r) => r.resultValue != null && r.resultValue!.trim().isNotEmpty,
      );

  /// Estado clínico de cierre. `in_review` nunca se considera completada,
  /// incluso si ya está pagada y tiene todos los resultados.
  bool get isCompleted =>
      status == 'completed' || (!isInReview && isFullyPaid && hasAllResults);

  BaseOrder({
    required this.patientId,
    required this.branchId,
    this.doctorId,
    this.patientInfo,
    this.doctorInfo,
    this.quotationId,
    this.items = const [],
    this.services = const [],
    this.discounts = const [],
    this.totalPrice = 0,
    this.paidAmount = 0,
    this.status = "pending",
    this.results = const [],
    this.isBlocked = false,
    this.approval,
    this.notes,
  });
}

class CreateOrder extends BaseOrder {
  CreateOrder({
    required super.patientId,
    required super.branchId,
    super.doctorId,
    super.patientInfo,
    super.doctorInfo,
    super.quotationId,
    super.items = const [],
    super.services = const [],
    super.discounts = const [],
    super.totalPrice = 0,
    super.paidAmount = 0,
    super.status = "pending",
    super.results = const [],
    super.isBlocked = false,
    super.approval,
    super.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'branchId': branchId,
      if (doctorId != null) 'doctorId': doctorId,
      if (patientInfo != null) 'patientInfo': patientInfo!.toJson(),
      if (doctorInfo != null) 'doctorInfo': doctorInfo!.toJson(),
      'quotationId': quotationId,
      'items': items.map((e) => e.toJson()).toList(),
      'services': services.map((e) => e.toJson()).toList(),
      'discounts': discounts.map((e) => e.toJson()).toList(),
      'totalPrice': totalPrice > 0 ? totalPrice : salePriceApplied,
      'paidAmount': paidAmount,
      'status': status,
      'results': results.map((e) => e.toJson()).toList(),
      'isBlocked': isBlocked,
      if (approval != null) 'approval': approval!.toJson(),
      if (notes != null) 'notes': notes,
    };
  }
}

class UpdateOrder {
  final String? patientId;
  final String? doctorId;
  final PatientInfo? patientInfo;
  final DoctorInfo? doctorInfo;
  final String? quotationId;
  final List<OrderItem>? items;
  final List<OrderService>? services;
  final List<OrderDiscount>? discounts;
  final int? totalPrice;
  final int? paidAmount;
  final String? status;
  final List<OrderTestResult>? results;
  final String? branchId;
  final bool? isBlocked;
  final OrderApproval? approval;
  final String? notes;
  final bool clearDoctor;

  String? get description => notes;

  UpdateOrder({
    this.patientId,
    this.doctorId,
    this.patientInfo,
    this.doctorInfo,
    this.quotationId,
    this.items,
    this.services,
    this.discounts,
    this.totalPrice,
    this.paidAmount,
    this.status,
    this.results,
    this.branchId,
    this.isBlocked,
    this.approval,
    this.notes,
    this.clearDoctor = false,
  });

  Map<String, dynamic> toJson() {
    return {
      if (patientId != null) 'patientId': patientId,
      if (patientInfo != null) 'patientInfo': patientInfo!.toJson(),
      if (clearDoctor) ...{
        'doctorId': null,
        'doctorInfo': null,
      } else ...{
        if (doctorId != null) 'doctorId': doctorId,
        if (doctorInfo != null) 'doctorInfo': doctorInfo!.toJson(),
      },
      if (quotationId != null) 'quotationId': quotationId,
      if (items != null) 'items': items!.map((e) => e.toJson()).toList(),
      if (services != null)
        'services': services!.map((e) => e.toJson()).toList(),
      if (discounts != null)
        'discounts': discounts!.map((e) => e.toJson()).toList(),
      if (totalPrice != null) 'totalPrice': totalPrice,
      if (paidAmount != null) 'paidAmount': paidAmount,
      if (status != null) 'status': status,
      if (results != null) 'results': results!.map((e) => e.toJson()).toList(),
      if (branchId != null) 'branchId': branchId,
      if (isBlocked != null) 'isBlocked': isBlocked,
      if (approval != null) 'approval': approval!.toJson(),
      if (notes != null) 'notes': notes,
    };
  }
}

class OrderApproveRequest {
  final String? supervisorUsername;
  final String? supervisorPassword;
  final UserInfo? approvedBy;
  final String? reason;

  OrderApproveRequest({
    this.supervisorUsername,
    this.supervisorPassword,
    this.approvedBy,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      if (supervisorUsername != null) 'supervisorUsername': supervisorUsername,
      if (supervisorPassword != null) 'supervisorPassword': supervisorPassword,
      if (approvedBy != null) 'approvedBy': approvedBy!.toJson(),
      if (reason != null) 'reason': reason,
    };
  }
}

class OrderPayRequest {
  final int amount;
  final String? shiftId;
  final String? registerId;
  final String paymentMethod;
  final UserInfo performedBy;
  final String? referenceNumber;
  final String? bank;

  OrderPayRequest({
    required this.amount,
    this.shiftId,
    this.registerId,
    required this.paymentMethod,
    required this.performedBy,
    this.referenceNumber,
    this.bank,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      if (shiftId != null) 'shiftId': shiftId,
      if (registerId != null) 'registerId': registerId,
      'paymentMethod': paymentMethod,
      'performedBy': performedBy.toJson(),
      if (referenceNumber != null) 'referenceNumber': referenceNumber,
      if (bank != null) 'bank': bank,
    };
  }
}

class OrderInDb extends BaseOrder {
  final String id;
  final int createdAt;
  final int? updatedAt;
  final bool isDeleted;
  final int? cancelledAt;
  final UserInfo? cancelledBy;
  final String? cancellationReason;
  final List<OrderStatusChange> statusHistory;
  final int? finalizedAt;
  final UserInfo? finalizedBy;
  final int? reopenedAt;
  final UserInfo? reopenedBy;
  final String? reopenReason;
  final int revisionCount;

  OrderInDb({
    required this.id,
    required super.patientId,
    required super.branchId,
    super.doctorId,
    super.patientInfo,
    super.doctorInfo,
    super.quotationId,
    super.items = const [],
    super.services = const [],
    super.discounts = const [],
    super.totalPrice = 0,
    super.paidAmount = 0,
    super.status = "pending",
    super.results = const [],
    super.isBlocked = false,
    super.approval,
    super.notes,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
    this.statusHistory = const [],
    this.finalizedAt,
    this.finalizedBy,
    this.reopenedAt,
    this.reopenedBy,
    this.reopenReason,
    this.revisionCount = 0,
  });

  factory OrderInDb.fromJson(Map<String, dynamic> json) {
    List<OrderItem> parsedItems = [];
    if (json['items'] != null) {
      parsedItems = (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['examId'] != null) {
      parsedItems = [
        OrderItem(
          labTestId: json['examId'] as String,
          name: json['examName'] as String? ?? '',
          salePriceApplied: (json['salePriceApplied'] as num?)?.toInt() ?? 0,
        ),
      ];
    }

    List<OrderService> parsedServices = [];
    if (json['services'] != null) {
      parsedServices = (json['services'] as List<dynamic>)
          .map((e) => OrderService.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<OrderDiscount> parsedDiscounts = [];
    if (json['discounts'] != null) {
      parsedDiscounts = (json['discounts'] as List<dynamic>)
          .map((e) => OrderDiscount.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final int calculatedFallback =
        parsedItems.fold<int>(0, (sum, i) => sum + i.salePriceApplied) +
        parsedServices.fold<int>(0, (sum, s) => sum + s.price) -
        parsedDiscounts.fold<int>(0, (sum, d) => sum + d.appliedAmount);

    final int total =
        (json['totalPrice'] as num?)?.toInt() ??
        (json['salePriceApplied'] as num?)?.toInt() ??
        (calculatedFallback > 0 ? calculatedFallback : 0);

    final patientInfoRaw = json['patientInfo'];
    final doctorInfoRaw = json['doctorInfo'];
    final approvalRaw = json['approval'];
    final cancelledByRaw = json['cancelledBy'];
    final finalizedByRaw = json['finalizedBy'];
    final reopenedByRaw = json['reopenedBy'];
    final notesRaw = json['notes'] as String? ?? json['description'] as String?;

    return OrderInDb(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      branchId: json['branchId'] as String? ?? '',
      doctorId: json['doctorId'] as String?,
      patientInfo: patientInfoRaw != null
          ? PatientInfo.fromJson(patientInfoRaw as Map<String, dynamic>)
          : null,
      doctorInfo: doctorInfoRaw != null
          ? DoctorInfo.fromJson(doctorInfoRaw as Map<String, dynamic>)
          : null,
      quotationId: json['quotationId'] as String?,
      items: parsedItems,
      services: parsedServices,
      discounts: parsedDiscounts,
      totalPrice: total,
      paidAmount: (json['paidAmount'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? "pending",
      results:
          (json['results'] as List<dynamic>?)
              ?.map((e) => OrderTestResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isBlocked: json['isBlocked'] as bool? ?? false,
      approval: approvalRaw != null
          ? OrderApproval.fromJson(approvalRaw as Map<String, dynamic>)
          : null,
      notes: notesRaw,
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      cancelledAt: (json['cancelledAt'] as num?)?.toInt(),
      cancelledBy: cancelledByRaw != null
          ? UserInfo.fromJson(cancelledByRaw as Map<String, dynamic>)
          : null,
      cancellationReason: json['cancellationReason'] as String?,
      statusHistory:
          (json['statusHistory'] as List<dynamic>?)
              ?.map(
                (e) => OrderStatusChange.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      finalizedAt: (json['finalizedAt'] as num?)?.toInt(),
      finalizedBy: finalizedByRaw != null
          ? UserInfo.fromJson(finalizedByRaw as Map<String, dynamic>)
          : null,
      reopenedAt: (json['reopenedAt'] as num?)?.toInt(),
      reopenedBy: reopenedByRaw != null
          ? UserInfo.fromJson(reopenedByRaw as Map<String, dynamic>)
          : null,
      reopenReason: json['reopenReason'] as String?,
      revisionCount: (json['revisionCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'branchId': branchId,
      if (doctorId != null) 'doctorId': doctorId,
      if (patientInfo != null) 'patientInfo': patientInfo!.toJson(),
      if (doctorInfo != null) 'doctorInfo': doctorInfo!.toJson(),
      'quotationId': quotationId,
      'items': items.map((e) => e.toJson()).toList(),
      'services': services.map((e) => e.toJson()).toList(),
      'discounts': discounts.map((e) => e.toJson()).toList(),
      'totalPrice': totalPrice > 0 ? totalPrice : salePriceApplied,
      'paidAmount': paidAmount,
      'status': status,
      'results': results.map((e) => e.toJson()).toList(),
      'isBlocked': isBlocked,
      if (approval != null) 'approval': approval!.toJson(),
      if (notes != null) 'notes': notes,
      'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      'isDeleted': isDeleted,
      if (cancelledAt != null) 'cancelledAt': cancelledAt,
      if (cancelledBy != null) 'cancelledBy': cancelledBy!.toJson(),
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      'statusHistory': statusHistory.map((e) => e.toJson()).toList(),
      if (finalizedAt != null) 'finalizedAt': finalizedAt,
      if (finalizedBy != null) 'finalizedBy': finalizedBy!.toJson(),
      if (reopenedAt != null) 'reopenedAt': reopenedAt,
      if (reopenedBy != null) 'reopenedBy': reopenedBy!.toJson(),
      if (reopenReason != null) 'reopenReason': reopenReason,
      'revisionCount': revisionCount,
    };
  }
}
