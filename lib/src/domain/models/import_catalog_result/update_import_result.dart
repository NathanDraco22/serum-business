class UpdateImportResult {
  final bool success;
  final String message;
  final int totalProcessed;
  final int updatedTestsCount;
  final int createdTestsCount;
  final int updatedAccountsCount;
  final int createdAccountsCount;
  final int skippedPricesCount;
  final int preservedReferenceValuesCount;

  const UpdateImportResult({
    this.success = true,
    this.message = 'Catálogo actualizado exitosamente',
    this.totalProcessed = 0,
    this.updatedTestsCount = 0,
    this.createdTestsCount = 0,
    this.updatedAccountsCount = 0,
    this.createdAccountsCount = 0,
    this.skippedPricesCount = 0,
    this.preservedReferenceValuesCount = 0,
  });

  factory UpdateImportResult.fromJson(Map<String, dynamic> json) {
    return UpdateImportResult(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      totalProcessed: json['totalProcessed'] as int? ?? 0,
      updatedTestsCount: json['updatedTestsCount'] as int? ?? 0,
      createdTestsCount: json['createdTestsCount'] as int? ?? 0,
      updatedAccountsCount: json['updatedAccountsCount'] as int? ?? 0,
      createdAccountsCount: json['createdAccountsCount'] as int? ?? 0,
      skippedPricesCount: json['skippedPricesCount'] as int? ?? 0,
      preservedReferenceValuesCount:
          json['preservedReferenceValuesCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'totalProcessed': totalProcessed,
      'updatedTestsCount': updatedTestsCount,
      'createdTestsCount': createdTestsCount,
      'updatedAccountsCount': updatedAccountsCount,
      'createdAccountsCount': createdAccountsCount,
      'skippedPricesCount': skippedPricesCount,
      'preservedReferenceValuesCount': preservedReferenceValuesCount,
    };
  }

  @override
  String toString() {
    return 'UpdateImportResult(success: $success, message: $message, totalProcessed: $totalProcessed, updatedTestsCount: $updatedTestsCount, createdTestsCount: $createdTestsCount, updatedAccountsCount: $updatedAccountsCount, createdAccountsCount: $createdAccountsCount, skippedPricesCount: $skippedPricesCount, preservedReferenceValuesCount: $preservedReferenceValuesCount)';
  }
}
