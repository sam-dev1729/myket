import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import 'lab_test_api.dart';
import 'models/lab_test_models.dart';

/// Repository for managing lab test data.
class LabTestRepository {
  final LabTestApi api;

  LabTestRepository(this.api);

  /// Extracts lab test data from the given file IDs.
  Future<ExtractedLabTest> extractLabTest(List<String> fileIds) async {
    final response = await api.extractLabTest(ExtractLabTestRequest(fileIds: fileIds));
    if (!response.success) throw response.error!;
    return response.body!;
  }

  /// Creates a lab test header and saves its tree.
  Future<void> saveLabTest(List<String> fileIds, ExtractedLabTest extractedData) async {
    final createResponse = await api.createLabTest(
      CreateLabTestRequest(
        fileIds: fileIds,
        testDate: extractedData.testDate,
        doctorName: extractedData.doctorName,
        labName: extractedData.labName,
      ),
    );
    if (!createResponse.success) throw createResponse.error!;

    final createdId = createResponse.body?.id;
    if (createdId == null) throw Exception('Failed to get lab test ID');

    if (extractedData.categories != null && extractedData.categories!.isNotEmpty) {
      final treeResponse = await api.saveLabTestTree(createdId, extractedData.categories!);
      if (!treeResponse.success) throw treeResponse.error!;
    }
  }

  /// Fetches the list of saved lab tests.
  Future<List<LabTestHeader>> getLabTests() async {
    final response = await api.getLabTests();
    if (!response.success) throw response.error!;
    return response.body ?? [];
  }

  /// Fetches the full detail for a single lab test.
  Future<LabTestDetail> getLabTestDetail(String id) async {
    final response = await api.getLabTestDetail(id);
    if (!response.success) throw response.error!;
    return response.body!;
  }

  /// Deletes a saved lab test and all its linked data.
  Future<void> deleteLabTest(String id) async {
    final response = await api.deleteLabTest(id);
    if (!response.success) throw response.error!;
  }

  /// Updates the header of a saved lab test.
  Future<LabTestDetail> updateLabTestHeader(
    String id,
    UpdateLabTestHeaderRequest request,
  ) async {
    final response = await api.updateLabTestHeader(id, request);
    if (!response.success) throw response.error!;
    return response.body!;
  }

  /// Creates a new empty category on the lab test.
  Future<LabTestDetailCategory> createCategory(
    String labTestId,
    CreateLabTestCategoryRequest request,
  ) async {
    final response = await api.createCategory(labTestId, request);
    if (!response.success) throw response.error!;
    return response.body!;
  }

  /// Renames a category or changes its sort order.
  Future<LabTestDetailCategory> updateCategory(
    String labTestId,
    String categoryId,
    UpdateLabTestCategoryRequest request,
  ) async {
    final response = await api.updateCategory(labTestId, categoryId, request);
    if (!response.success) throw response.error!;
    return response.body!;
  }

  /// Deletes a category and all its parameters.
  Future<DeleteLabTestCategoryResponse> deleteCategory(
    String labTestId,
    String categoryId,
  ) async {
    final response = await api.deleteCategory(labTestId, categoryId);
    if (!response.success) throw response.error!;
    return response.body!;
  }

  /// Creates a new parameter under a category.
  Future<LabTestDetailParameter> createParameter(
    String labTestId,
    CreateLabTestParameterRequest request,
  ) async {
    final response = await api.createParameter(labTestId, request);
    if (!response.success) throw response.error!;
    return response.body!;
  }

  /// Updates a parameter.
  Future<LabTestDetailParameter> updateParameter(
    String labTestId,
    String parameterId,
    UpdateLabTestParameterRequest request,
  ) async {
    final response = await api.updateParameter(labTestId, parameterId, request);
    if (!response.success) throw response.error!;
    return response.body!;
  }

  /// Deletes a single parameter.
  Future<void> deleteParameter(String labTestId, String parameterId) async {
    final response = await api.deleteParameter(labTestId, parameterId);
    if (!response.success) throw response.error!;
  }

    /// Fetches the AI-driven health overview for the current user.
  Future<HealthOverview> getHealthOverview() async {
    final response = await api.getHealthOverview();
    if (!response.success) throw response.error!;
    return response.body!;
  }
    /// Fetches the results overview (overall status + 10 latest parameters).
  Future<LabOverview> getLabOverview() async {
    final response = await api.getLabOverview();
    if (!response.success) throw response.error!;
    return response.body!;
  }

  /// Fetches the paginated full list of latest mapped parameters.
  Future<PaginatedLabOverviewParameters> getLabOverviewParameters({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final response = await api.getLabOverviewParameters(page: page, limit: limit, search: search);
    if (!response.success) throw response.error!;
    return response.body!;
  }
    /// Fetches the paginated list of user-mapped analytes.
  Future<PaginatedUserAnalytes> getUserAnalytes({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final response = await api.getUserAnalytes(page: page, limit: limit, search: search);
    if (!response.success) throw response.error!;
    return response.body!;
  }

  /// Fetches time series for the given [analyteIds].
  Future<LabSeriesResponse> getLabSeries(List<String> analyteIds) async {
    final response = await api.getLabSeries(SeriesRequest(analyteIds: analyteIds));
    if (!response.success) throw response.error!;
    return response.body!;
  }
}

/// Riverpod provider for [LabTestRepository].
final labTestRepositoryProvider = Provider<LabTestRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final api = LabTestApi(apiClient.dio);
  return LabTestRepository(api);
});