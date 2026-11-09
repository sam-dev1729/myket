import 'package:dio/dio.dart';
import 'package:myket/features/lab_test/data/lab_test_api.dart';
import 'package:myket/features/lab_test/data/lab_test_repository.dart';
import 'package:myket/features/lab_test/data/models/lab_test_models.dart';


/// Hand-rolled fake of [LabTestRepository] used by lab-test controller tests.
///
/// Configurable via public fields; never touches Dio or any platform channel.
class FakeLabTestRepository extends LabTestRepository {
  FakeLabTestRepository() : super(LabTestApi(Dio()));

  // ── Detail (used by EditLabTestController) ──
  LabTestDetail? detail;
  Exception? throwOnGetLabTestDetail;
  Exception? throwOnUpdateHeader;
  Exception? throwOnDeleteParameter;
  Exception? throwOnUpdateCategory;
  Exception? throwOnUpdateParameter;

  // ── Lab overview ──
  LabOverview? overview;
  Exception? throwOnGetLabOverview;
  PaginatedLabOverviewParameters? overviewParametersPage1;
  PaginatedLabOverviewParameters? overviewParametersPage2;
  Exception? throwOnGetLabOverviewParameters;

  // ── Analytes ──
  PaginatedUserAnalytes? analytesPage1;
  PaginatedUserAnalytes? analytesPage2;
  Exception? throwOnGetUserAnalytes;

  // ── Series ──
  LabSeriesResponse? seriesResponse;
  Exception? throwOnGetLabSeries;

  @override
  Future<LabOverview> getLabOverview() async {
    if (throwOnGetLabOverview != null) throw throwOnGetLabOverview!;
    return overview!;
  }

  @override
  Future<PaginatedLabOverviewParameters> getLabOverviewParameters({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    if (throwOnGetLabOverviewParameters != null) {
      throw throwOnGetLabOverviewParameters!;
    }
    if (page == 1 && overviewParametersPage1 != null) {
      return overviewParametersPage1!;
    }
    if (page == 2 && overviewParametersPage2 != null) {
      return overviewParametersPage2!;
    }
    throw UnimplementedError('Unexpected page=$page');
  }

  @override
  Future<PaginatedUserAnalytes> getUserAnalytes({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    if (throwOnGetUserAnalytes != null) throw throwOnGetUserAnalytes!;
    if (page == 1 && analytesPage1 != null) return analytesPage1!;
    if (page == 2 && analytesPage2 != null) return analytesPage2!;
    throw UnimplementedError('Unexpected page=$page');
  }

  @override
  Future<LabSeriesResponse> getLabSeries(List<String> analyteIds) async {
    if (throwOnGetLabSeries != null) throw throwOnGetLabSeries!;
    return seriesResponse ?? const LabSeriesResponse();
  }

  @override
  Future<LabTestDetail> getLabTestDetail(String id) async {
    if (throwOnGetLabTestDetail != null) throw throwOnGetLabTestDetail!;
    return detail!;
  }

  @override
  Future<LabTestDetail> updateLabTestHeader(String id, UpdateLabTestHeaderRequest request) async {
    if (throwOnUpdateHeader != null) throw throwOnUpdateHeader!;
    return detail!;
  }

  @override
  Future<void> deleteParameter(String labTestId, String parameterId) async {
    if (throwOnDeleteParameter != null) throw throwOnDeleteParameter!;
  }

  @override
  Future<LabTestDetailCategory> updateCategory(
    String labTestId,
    String categoryId,
    UpdateLabTestCategoryRequest request,
  ) async {
    if (throwOnUpdateCategory != null) throw throwOnUpdateCategory!;
    return LabTestDetailCategory(
      id: categoryId,
      name: request.name ?? 'cat',
      sortOrder: request.sortOrder,
      parameters: const [],
    );
  }

  @override
  Future<LabTestDetailParameter> updateParameter(
    String labTestId,
    String parameterId,
    UpdateLabTestParameterRequest request,
  ) async {
    if (throwOnUpdateParameter != null) throw throwOnUpdateParameter!;
    return LabTestDetailParameter(
      id: parameterId,
      categoryId: 'cat-1',
      name: 'p',
      value: '1',
      sortOrder: request.sortOrder.value,
    );
  }
}
