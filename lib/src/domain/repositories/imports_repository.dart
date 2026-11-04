import '../../data/imports_data_source.dart';
import '../models/import_catalog_result/import_branch_prices_result.dart';
import '../models/import_catalog_result/import_catalog_result.dart';
import '../models/import_catalog_result/update_import_result.dart';

class ImportsRepository {
  final ImportsDataSource importsDataSource;

  ImportsRepository(this.importsDataSource);

  ImportCatalogResult? _lastResult;
  ImportBranchPricesResult? _lastPricesResult;
  UpdateImportResult? _lastUpdateResult;

  ImportCatalogResult? get lastResult => _lastResult;
  ImportBranchPricesResult? get lastPricesResult => _lastPricesResult;
  UpdateImportResult? get lastUpdateResult => _lastUpdateResult;

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

  Future<UpdateImportResult> updateCatalog({
    bool overridePrice = false,
    bool updateLabTest = true,
  }) async {
    final result = await importsDataSource.updateCatalog(
      overridePrice: overridePrice,
      updateLabTest: updateLabTest,
    );
    final model = UpdateImportResult.fromJson(result);
    _lastUpdateResult = model;
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
