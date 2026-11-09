import 'package:json_annotation/json_annotation.dart';

// Shared pagination metadata (PaginationMeta).
import '../../../financial/data/models/common_models.dart';

import '../../../../core/utils/optional.dart';

part 'lab_test_models.g.dart';

/// Request body to extract lab test data from uploaded files.
@JsonSerializable()
class ExtractLabTestRequest {
  @JsonKey(name: 'file_ids')
  final List<String> fileIds;

  const ExtractLabTestRequest({required this.fileIds});

  Map<String, dynamic> toJson() => _$ExtractLabTestRequestToJson(this);
}

/// Request body to create a new lab test header.
@JsonSerializable()
class CreateLabTestRequest {
  @JsonKey(name: 'file_ids')
  final List<String> fileIds;
  @JsonKey(name: 'test_date')
  final String? testDate;
  @JsonKey(name: 'doctor_name')
  final String? doctorName;
  @JsonKey(name: 'lab_name')
  final String? labName;

  const CreateLabTestRequest({required this.fileIds, this.testDate, this.doctorName, this.labName});

  Map<String, dynamic> toJson() => _$CreateLabTestRequestToJson(this);
}

/// Represents the response received after creating a new lab test.
@JsonSerializable()
class CreatedLabTestResponse {
  final String id;
  @JsonKey(name: 'test_date')
  final String? testDate;
  @JsonKey(name: 'doctor_name')
  final String? doctorName;
  @JsonKey(name: 'lab_name')
  final String? labName;

  const CreatedLabTestResponse({required this.id, this.testDate, this.doctorName, this.labName});

  factory CreatedLabTestResponse.fromJson(Map<String, dynamic> json) =>
      _$CreatedLabTestResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CreatedLabTestResponseToJson(this);
}

/// Represents a saved lab test header returned by `GET /lab-test`.
@JsonSerializable()
class LabTestHeader {
  final String id;
  @JsonKey(name: 'test_date')
  final String? testDate;
  @JsonKey(name: 'doctor_name')
  final String? doctorName;
  @JsonKey(name: 'lab_name')
  final String? labName;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const LabTestHeader({
    required this.id,
    this.testDate,
    this.doctorName,
    this.labName,
    this.createdAt,
  });

  factory LabTestHeader.fromJson(Map<String, dynamic> json) => _$LabTestHeaderFromJson(json);
  Map<String, dynamic> toJson() => _$LabTestHeaderToJson(this);
}

/// Represents the AI-extracted data of a lab test.
@JsonSerializable()
class ExtractedLabTest {
  @JsonKey(name: 'test_date')
  final String? testDate;
  @JsonKey(name: 'doctor_name')
  final String? doctorName;
  @JsonKey(name: 'lab_name')
  final String? labName;
  final List<ExtractedCategory>? categories;

  const ExtractedLabTest({this.testDate, this.doctorName, this.labName, this.categories});

  factory ExtractedLabTest.fromJson(Map<String, dynamic> json) => _$ExtractedLabTestFromJson(json);
  Map<String, dynamic> toJson() => _$ExtractedLabTestToJson(this);
}

/// Represents a category (e.g., CBC, Lipids) in the extracted data.
@JsonSerializable()
class ExtractedCategory {
  final String name;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  final List<ExtractedParameter>? parameters;

  const ExtractedCategory({required this.name, this.sortOrder, this.parameters});

  factory ExtractedCategory.fromJson(Map<String, dynamic> json) =>
      _$ExtractedCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$ExtractedCategoryToJson(this);
}

/// Represents a single parameter (e.g., WBC, HDL) in a category.
@JsonSerializable()
class ExtractedParameter {
  final String name;
  final String? value;
  final String? unit;
  @JsonKey(name: 'ref_min')
  final String? refMin;
  @JsonKey(name: 'ref_max')
  final String? refMax;
  final String? flag;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;

  const ExtractedParameter({
    required this.name,
    this.value,
    this.unit,
    this.refMin,
    this.refMax,
    this.flag,
    this.sortOrder,
  });

  factory ExtractedParameter.fromJson(Map<String, dynamic> json) =>
      _$ExtractedParameterFromJson(json);
  Map<String, dynamic> toJson() => _$ExtractedParameterToJson(this);
}

// ─────────────────────────────────────────────────────────────
// Blood Test Detail Models
// ─────────────────────────────────────────────────────────────

/// A file linked to a saved lab test.
@JsonSerializable()
class LabTestDetailFile {
  final String id;
  @JsonKey(name: 'original_name')
  final String? originalName;
  final String url;

  const LabTestDetailFile({required this.id, this.originalName, required this.url});

  factory LabTestDetailFile.fromJson(Map<String, dynamic> json) =>
      _$LabTestDetailFileFromJson(json);
  Map<String, dynamic> toJson() => _$LabTestDetailFileToJson(this);
}

/// A single parameter row on a saved lab test, as stored by the backend.
@JsonSerializable()
class LabTestDetailParameter {
  final String id;
  @JsonKey(name: 'category_id')
  final String categoryId;
  final String name;
  final String value;
  final String? unit;
  @JsonKey(name: 'ref_min')
  final String? refMin;
  @JsonKey(name: 'ref_max')
  final String? refMax;
  final String? flag;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;

  const LabTestDetailParameter({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.value,
    this.unit,
    this.refMin,
    this.refMax,
    this.flag,
    this.sortOrder,
  });

  factory LabTestDetailParameter.fromJson(Map<String, dynamic> json) =>
      _$LabTestDetailParameterFromJson(json);
  Map<String, dynamic> toJson() => _$LabTestDetailParameterToJson(this);
}

/// A category grouping one or more [LabTestDetailParameter] rows.
@JsonSerializable(explicitToJson: true)
class LabTestDetailCategory {
  final String id;
  final String name;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  final List<LabTestDetailParameter> parameters;

  const LabTestDetailCategory({
    required this.id,
    required this.name,
    this.sortOrder,
    required this.parameters,
  });

  factory LabTestDetailCategory.fromJson(Map<String, dynamic> json) =>
      _$LabTestDetailCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$LabTestDetailCategoryToJson(this);
}

/// Full detail for a saved lab test returned by `GET /lab-test/{id}`.
@JsonSerializable(explicitToJson: true)
class LabTestDetail {
  final String id;
  @JsonKey(name: 'test_date')
  final String? testDate;
  @JsonKey(name: 'doctor_name')
  final String? doctorName;
  @JsonKey(name: 'lab_name')
  final String? labName;
  @JsonKey(name: 'lab_address')
  final String? labAddress;
  @JsonKey(name: 'test_number')
  final String? testNumber;
  final List<LabTestDetailFile> files;
  final List<LabTestDetailCategory> categories;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const LabTestDetail({
    required this.id,
    this.testDate,
    this.doctorName,
    this.labName,
    this.labAddress,
    this.testNumber,
    required this.files,
    required this.categories,
    this.createdAt,
  });

  factory LabTestDetail.fromJson(Map<String, dynamic> json) => _$LabTestDetailFromJson(json);
  Map<String, dynamic> toJson() => _$LabTestDetailToJson(this);
}

// ─────────────────────────────────────────────────────────────
// Edit Granular Lab Test Models (NEW)
// ─────────────────────────────────────────────────────────────

/// Request body for `PATCH /lab-test/{id}` (header update).
///
/// Uses [Optional] to distinguish three states per field:
/// - absent → field omitted (unchanged)
/// - of(value) → field set to value
/// - ofNullable(null) → field cleared on the backend
class UpdateLabTestHeaderRequest {
  final Optional<String> testDate;
  final Optional<String> doctorName;
  final Optional<String> labName;
  final Optional<String> labAddress;
  final Optional<String> testNumber;

  const UpdateLabTestHeaderRequest({
    this.testDate = const Optional.absent(),
    this.doctorName = const Optional.absent(),
    this.labName = const Optional.absent(),
    this.labAddress = const Optional.absent(),
    this.testNumber = const Optional.absent(),
  });

  /// Builds the JSON payload, including only fields that are present.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (testDate.isPresent) json['test_date'] = testDate.value;
    if (doctorName.isPresent) json['doctor_name'] = doctorName.value;
    if (labName.isPresent) json['lab_name'] = labName.value;
    if (labAddress.isPresent) json['lab_address'] = labAddress.value;
    if (testNumber.isPresent) json['test_number'] = testNumber.value;
    return json;
  }
}

/// Request body for `POST /lab-test/{id}/categories`.
@JsonSerializable()
class CreateLabTestCategoryRequest {
  final String name;
  @JsonKey(name: 'sort_order', includeIfNull: false)
  final int? sortOrder;

  const CreateLabTestCategoryRequest({required this.name, this.sortOrder});

  Map<String, dynamic> toJson() => _$CreateLabTestCategoryRequestToJson(this);
}

/// Request body for `PATCH /lab-test/{id}/categories/{categoryId}`.
@JsonSerializable()
class UpdateLabTestCategoryRequest {
  @JsonKey(includeIfNull: false)
  final String? name;
  @JsonKey(name: 'sort_order', includeIfNull: false)
  final int? sortOrder;

  const UpdateLabTestCategoryRequest({this.name, this.sortOrder});

  Map<String, dynamic> toJson() => _$UpdateLabTestCategoryRequestToJson(this);
}

/// Request body for `POST /lab-test/{id}/parameters`.
@JsonSerializable()
class CreateLabTestParameterRequest {
  @JsonKey(name: 'category_id')
  final String categoryId;
  final String name;
  final String value;
  @JsonKey(includeIfNull: false)
  final String? unit;
  @JsonKey(name: 'ref_min', includeIfNull: false)
  final num? refMin;
  @JsonKey(name: 'ref_max', includeIfNull: false)
  final num? refMax;
  @JsonKey(includeIfNull: false)
  final String? flag;
  @JsonKey(name: 'sort_order', includeIfNull: false)
  final int? sortOrder;

  const CreateLabTestParameterRequest({
    required this.categoryId,
    required this.name,
    required this.value,
    this.unit,
    this.refMin,
    this.refMax,
    this.flag,
    this.sortOrder,
  });

  Map<String, dynamic> toJson() => _$CreateLabTestParameterRequestToJson(this);
}

/// Request body for `PATCH /lab-test/{id}/parameters/{parameterId}`.
///
/// Uses [Optional] per field (see [UpdateLabTestHeaderRequest]).
class UpdateLabTestParameterRequest {
  final Optional<String> categoryId;
  final Optional<String> analyteId;
  final Optional<String> name;
  final Optional<String> value;
  final Optional<String> unit;
  final Optional<num> refMin;
  final Optional<num> refMax;
  final Optional<String> flag;
  final Optional<int> sortOrder;

  const UpdateLabTestParameterRequest({
    this.categoryId = const Optional.absent(),
    this.analyteId = const Optional.absent(),
    this.name = const Optional.absent(),
    this.value = const Optional.absent(),
    this.unit = const Optional.absent(),
    this.refMin = const Optional.absent(),
    this.refMax = const Optional.absent(),
    this.flag = const Optional.absent(),
    this.sortOrder = const Optional.absent(),
  });

  /// Builds the JSON payload, including only fields that are present.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (categoryId.isPresent) json['category_id'] = categoryId.value;
    if (analyteId.isPresent) json['analyte_id'] = analyteId.value;
    if (name.isPresent) json['name'] = name.value;
    if (value.isPresent) json['value'] = value.value;
    if (unit.isPresent) json['unit'] = unit.value;
    if (refMin.isPresent) json['ref_min'] = refMin.value;
    if (refMax.isPresent) json['ref_max'] = refMax.value;
    if (flag.isPresent) json['flag'] = flag.value;
    if (sortOrder.isPresent) json['sort_order'] = sortOrder.value;
    return json;
  }
}
/// Response body for `DELETE /lab-test/{id}/categories/{categoryId}`.
@JsonSerializable()
class DeleteLabTestCategoryResponse {
  final bool deleted;
  @JsonKey(name: 'deleted_parameters')
  final int deletedParameters;

  const DeleteLabTestCategoryResponse({required this.deleted, required this.deletedParameters});

  factory DeleteLabTestCategoryResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteLabTestCategoryResponseFromJson(json);
}

// ─────────────────────────────────────────────────────────────
// Health Overview Models
// ─────────────────────────────────────────────────────────────

/// A single key marker (e.g. FBS, Calcium, ALT, WBC) returned by
/// `GET /lab-test/overview/health`.
@JsonSerializable()
class HealthKeyMarker {
  final String? code;
  final String? name;
  final String? value;
  final String? unit;
  @JsonKey(name: 'ref_min')
  final String? refMin;
  @JsonKey(name: 'ref_max')
  final String? refMax;
  final String? status;
  @JsonKey(name: 'last_test_date')
  final String? lastTestDate;

  const HealthKeyMarker({
    this.code,
    this.name,
    this.value,
    this.unit,
    this.refMin,
    this.refMax,
    this.status,
    this.lastTestDate,
  });

  factory HealthKeyMarker.fromJson(Map<String, dynamic> json) => _$HealthKeyMarkerFromJson(json);
  Map<String, dynamic> toJson() => _$HealthKeyMarkerToJson(this);
}

/// AI-driven disease-risk block embedded in the health overview.
@JsonSerializable()
class HealthDiseaseRisk {
  final String? text;
  final List<String> diseases;

  const HealthDiseaseRisk({this.text, this.diseases = const []});

  factory HealthDiseaseRisk.fromJson(Map<String, dynamic> json) =>
      _$HealthDiseaseRiskFromJson(json);
  Map<String, dynamic> toJson() => _$HealthDiseaseRiskToJson(this);
}

/// Response body for `GET /lab-test/overview/health`.
@JsonSerializable(explicitToJson: true)
class HealthOverview {
  @JsonKey(name: 'overall_status')
  final String? overallStatus;
  @JsonKey(name: 'key_markers')
  final List<HealthKeyMarker> keyMarkers;
  @JsonKey(name: 'disease_risk')
  final HealthDiseaseRisk? diseaseRisk;
  final String? advice;

  const HealthOverview({
    this.overallStatus,
    this.keyMarkers = const [],
    this.diseaseRisk,
    this.advice,
  });

  factory HealthOverview.fromJson(Map<String, dynamic> json) => _$HealthOverviewFromJson(json);
  Map<String, dynamic> toJson() => _$HealthOverviewToJson(this);
}

// ─────────────────────────────────────────────────────────────
// Lab Overview Models
// ─────────────────────────────────────────────────────────────

/// A single parameter row in the results-overview response.
@JsonSerializable()
class LabOverviewParameter {
  @JsonKey(name: 'analyte_id')
  final String? analyteId;
  final String? name;
  final String? unit;
  final String? value;
  @JsonKey(name: 'ref_min')
  final String? refMin;
  @JsonKey(name: 'ref_max')
  final String? refMax;
  final String? status;
  @JsonKey(name: 'last_test_date')
  final String? lastTestDate;
  @JsonKey(name: 'lab_name')
  final String? labName;

  const LabOverviewParameter({
    this.analyteId,
    this.name,
    this.unit,
    this.value,
    this.refMin,
    this.refMax,
    this.status,
    this.lastTestDate,
    this.labName,
  });

  factory LabOverviewParameter.fromJson(Map<String, dynamic> json) =>
      _$LabOverviewParameterFromJson(json);
  Map<String, dynamic> toJson() => _$LabOverviewParameterToJson(this);
}

/// Response body for `GET /lab-test/overview`.
@JsonSerializable(explicitToJson: true)
class LabOverview {
  @JsonKey(name: 'overall_status')
  final String? overallStatus;
  final List<LabOverviewParameter> parameters;
  final String? advice;

  const LabOverview({this.overallStatus, this.parameters = const [], this.advice});

  factory LabOverview.fromJson(Map<String, dynamic> json) => _$LabOverviewFromJson(json);
  Map<String, dynamic> toJson() => _$LabOverviewToJson(this);
}

/// Paginated response body for `GET /lab-test/overview/parameters`.
@JsonSerializable(explicitToJson: true)
class PaginatedLabOverviewParameters {
  final PaginationMeta meta;
  final List<LabOverviewParameter> data;

  /// Overall status computed over the full set (not just the current page).
  @JsonKey(name: 'overall_status')
  final String? overallStatus;

  const PaginatedLabOverviewParameters({
    required this.meta,
    required this.data,
    this.overallStatus,
  });

  factory PaginatedLabOverviewParameters.fromJson(Map<String, dynamic> json) =>
      _$PaginatedLabOverviewParametersFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedLabOverviewParametersToJson(this);
}

// ─────────────────────────────────────────────────────────────
// Series Analytics Models (NEW)
// ─────────────────────────────────────────────────────────────

/// A single analyte category (e.g. HEMATOLOGIC, LIPIDS).
@JsonSerializable()
class UserAnalyteCategory {
  final String id;
  final String code;
  @JsonKey(name: 'name_en')
  final String? nameEn;

  const UserAnalyteCategory({required this.id, required this.code, this.nameEn});

  factory UserAnalyteCategory.fromJson(Map<String, dynamic> json) =>
      _$UserAnalyteCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$UserAnalyteCategoryToJson(this);
}

/// A single analyte the current user already has mapped on their lab tests.
///
/// Returned by `GET /lab-test/analytes`. Use `id` in
/// [SeriesRequest.analyteIds].
@JsonSerializable()
class UserAnalyte {
  final String id;
  final String code;
  final String name;
  @JsonKey(name: 'canonical_unit')
  final String? canonicalUnit;
  @JsonKey(name: 'description_en')
  final String? descriptionEn;
  @JsonKey(name: 'description_fa')
  final String? descriptionFa;
  @JsonKey(name: 'value_type')
  final String valueType; // NUMERIC | TEXT
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @JsonKey(name: 'observation_count')
  final int observationCount;
  @JsonKey(name: 'latest_test_date')
  final String? latestTestDate;
  final UserAnalyteCategory? category;

  const UserAnalyte({
    required this.id,
    required this.code,
    required this.name,
    this.canonicalUnit,
    this.descriptionEn,
    this.descriptionFa,
    required this.valueType,
    required this.sortOrder,
    required this.observationCount,
    this.latestTestDate,
    this.category,
  });

  factory UserAnalyte.fromJson(Map<String, dynamic> json) => _$UserAnalyteFromJson(json);
  Map<String, dynamic> toJson() => _$UserAnalyteToJson(this);
}

/// Paginated response body for `GET /lab-test/analytes`.
@JsonSerializable(explicitToJson: true)
class PaginatedUserAnalytes {
  final PaginationMeta meta;
  final List<UserAnalyte> data;

  const PaginatedUserAnalytes({required this.meta, required this.data});

  factory PaginatedUserAnalytes.fromJson(Map<String, dynamic> json) =>
      _$PaginatedUserAnalytesFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedUserAnalytesToJson(this);
}

/// Request body for `POST /lab-test/series`.
@JsonSerializable()
class SeriesRequest {
  @JsonKey(name: 'analyte_ids')
  final List<String> analyteIds;

  const SeriesRequest({required this.analyteIds});

  Map<String, dynamic> toJson() => _$SeriesRequestToJson(this);
}

/// A single point on a series timeline.
///
/// Uses `num?` so both `int` and `double` from the backend are tolerated. The
/// chart prefers [valueCanonical] when present, falling back to [value].
@JsonSerializable()
class LabSeriesPoint {
  final String? date;
  final num? value;
  @JsonKey(name: 'value_canonical')
  final num? valueCanonical;
  @JsonKey(name: 'raw_value')
  final String? rawValue;

  const LabSeriesPoint({this.date, this.value, this.valueCanonical, this.rawValue});

  factory LabSeriesPoint.fromJson(Map<String, dynamic> json) => _$LabSeriesPointFromJson(json);
  Map<String, dynamic> toJson() => _$LabSeriesPointToJson(this);

  /// Returns the numeric value to plot, preferring the canonical value.
  num? get plotValue => valueCanonical ?? value;
}

/// One analyte's time series (name, unit, ordered points).
@JsonSerializable(explicitToJson: true)
class LabSeries {
  @JsonKey(name: 'analyte_id')
  final String? analyteId;
  @JsonKey(name: 'analyte_name')
  final String? analyteName;
  final String? unit;
  final List<LabSeriesPoint> points;

  const LabSeries({this.analyteId, this.analyteName, this.unit, this.points = const []});

  factory LabSeries.fromJson(Map<String, dynamic> json) => _$LabSeriesFromJson(json);
  Map<String, dynamic> toJson() => _$LabSeriesToJson(this);
}

/// Response body for `POST /lab-test/series`.
///
/// Assumed shape (backend has no schema in Swagger):
/// `{ "series": [{ "analyte_id": "...", "analyte_name": "...", "unit": "...",
///   "points": [{ "date": "2024-12-13", "value_canonical": 7.2 }] }] }`.
@JsonSerializable(explicitToJson: true)
class LabSeriesResponse {
  final List<LabSeries> series;

  const LabSeriesResponse({this.series = const []});

  factory LabSeriesResponse.fromJson(Map<String, dynamic> json) =>
      _$LabSeriesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LabSeriesResponseToJson(this);
}
