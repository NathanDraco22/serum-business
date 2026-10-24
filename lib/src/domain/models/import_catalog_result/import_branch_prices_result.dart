class ImportBranchPricesResult {
  final bool success;
  final String message;
  final String sourceBranchId;
  final String sourceBranchName;
  final String targetBranchId;
  final String targetBranchName;
  final bool mustOverridePrice;
  final int totalEvaluated;
  final int updatedCount;
  final int createdCount;
  final int skippedCount;

  const ImportBranchPricesResult({
    this.success = true,
    this.message = 'Precios importados exitosamente',
    this.sourceBranchId = '',
    this.sourceBranchName = '',
    this.targetBranchId = '',
    this.targetBranchName = '',
    this.mustOverridePrice = false,
    this.totalEvaluated = 0,
    this.updatedCount = 0,
    this.createdCount = 0,
    this.skippedCount = 0,
  });

  factory ImportBranchPricesResult.fromJson(Map<String, dynamic> json) {
    return ImportBranchPricesResult(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      sourceBranchId: json['sourceBranchId'] as String? ?? '',
      sourceBranchName: json['sourceBranchName'] as String? ?? '',
      targetBranchId: json['targetBranchId'] as String? ?? '',
      targetBranchName: json['targetBranchName'] as String? ?? '',
      mustOverridePrice: json['mustOverridePrice'] as bool? ?? false,
      totalEvaluated: json['totalEvaluated'] as int? ?? 0,
      updatedCount: json['updatedCount'] as int? ?? 0,
      createdCount: json['createdCount'] as int? ?? 0,
      skippedCount: json['skippedCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'sourceBranchId': sourceBranchId,
      'sourceBranchName': sourceBranchName,
      'targetBranchId': targetBranchId,
      'targetBranchName': targetBranchName,
      'mustOverridePrice': mustOverridePrice,
      'totalEvaluated': totalEvaluated,
      'updatedCount': updatedCount,
      'createdCount': createdCount,
      'skippedCount': skippedCount,
    };
  }

  @override
  String toString() {
    return 'ImportBranchPricesResult(success: $success, message: $message, sourceBranchId: $sourceBranchId, targetBranchId: $targetBranchId, mustOverridePrice: $mustOverridePrice, totalEvaluated: $totalEvaluated, updatedCount: $updatedCount, createdCount: $createdCount, skippedCount: $skippedCount)';
  }
}
