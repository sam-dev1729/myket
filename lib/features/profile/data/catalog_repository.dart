import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'catalog_api.dart';
import 'models/catalog_models.dart';

/// Repository for managing medical catalogs (Allergy, Disease, History).
class CatalogRepository {
  final CatalogApi api;

  CatalogRepository(this.api);

  Future<List<CatalogItem>> getAllergies({String? search}) async {
    final response = await api.getAllergies(search);
    if (!response.success) throw response.error!;
    return response.body ?? [];
  }

  Future<List<CatalogItem>> getDiseases({String? search}) async {
    final response = await api.getDiseases(search);
    if (!response.success) throw response.error!;
    return response.body ?? [];
  }

  Future<List<CatalogItem>> getHistories({String? search}) async {
    final response = await api.getHistories(search);
    if (!response.success) throw response.error!;
    return response.body ?? [];
  }

  Future<CatalogItem> createAllergy(String name) async {
    final response = await api.createAllergy(CreateCatalogItemRequest(name: name));
    if (!response.success) throw response.error!;
    return response.body!;
  }

  Future<CatalogItem> createDisease(String name) async {
    final response = await api.createDisease(CreateCatalogItemRequest(name: name));
    if (!response.success) throw response.error!;
    return response.body!;
  }

  Future<CatalogItem> createHistory(String name) async {
    final response = await api.createHistory(CreateCatalogItemRequest(name: name));
    if (!response.success) throw response.error!;
    return response.body!;
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final api = CatalogApi(apiClient.dio);
  return CatalogRepository(api);
});
