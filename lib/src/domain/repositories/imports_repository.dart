import '../../data/imports_data_source.dart';
import '../models/import_catalog_result/import_branch_prices_result.dart';
import '../models/import_catalog_result/import_catalog_result.dart';

class ImportsRepository {
  final ImportsDataSource importsDataSource;

  ImportsRepository(this.importsDataSource);

  ImportCatalogResult? _lastResult;
  ImportBranchPricesResult? _lastPricesResult;

  ImportCatalogResult? get lastResult => _lastResult;
  ImportBranchPricesResult? get lastPricesResult => _lastPricesResult;

  Future<ImportCatalogResult> importDefaultCatalog() async {
    final result = await importsDataSource.importDefaultCatalog();
    final model = ImportCatalogResult.fromJson(result);
    _lastResult = model;
    return model;
  }

  Future<ImportCatalogResult> importLabTests() async {
    final result = await importsDataSource.importLabTests();
    final model = ImportCatalogResult.fromJson(result);
    _lastResult = model;
    return model;
  }

  Future<ImportBranchPricesResult> importBranchPrices({
    required String sourceBranchId,
    required String targetBranchId,
    bool mustOverridePrice = false,
  }) async {
    final result = await importsDataSource.importBranchPrices(
      sourceBranchId: sourceBranchId,
      targetBranchId: targetBranchId,
      mustOverridePrice: mustOverridePrice,
    );
    final model = ImportBranchPricesResult.fromJson(result);
    _lastPricesResult = model;
    return model;
  }
}
