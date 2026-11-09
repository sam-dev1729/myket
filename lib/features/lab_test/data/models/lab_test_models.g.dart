// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lab_test_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExtractLabTestRequest _$ExtractLabTestRequestFromJson(
  Map<String, dynamic> json,
) => ExtractLabTestRequest(
  fileIds: (json['file_ids'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$ExtractLabTestRequestToJson(
  ExtractLabTestRequest instance,
) => <String, dynamic>{'file_ids': instance.fileIds};

CreateLabTestRequest _$CreateLabTestRequestFromJson(
  Map<String, dynamic> json,
) => CreateLabTestRequest(
  fileIds: (json['file_ids'] as List<dynamic>).map((e) => e as String).toList(),
  testDate: json['test_date'] as String?,
  doctorName: json['doctor_name'] as String?,
  labName: json['lab_name'] as String?,
);

Map<String, dynamic> _$CreateLabTestRequestToJson(
  CreateLabTestRequest instance,
) => <String, dynamic>{
  'file_ids': instance.fileIds,
  'test_date': instance.testDate,
  'doctor_name': instance.doctorName,
  'lab_name': instance.labName,
};

CreatedLabTestResponse _$CreatedLabTestResponseFromJson(
  Map<String, dynamic> json,
) => CreatedLabTestResponse(
  id: json['id'] as String,
  testDate: json['test_date'] as String?,
  doctorName: json['doctor_name'] as String?,
  labName: json['lab_name'] as String?,
);

Map<String, dynamic> _$CreatedLabTestResponseToJson(
  CreatedLabTestResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'test_date': instance.testDate,
  'doctor_name': instance.doctorName,
  'lab_name': instance.labName,
};

LabTestHeader _$LabTestHeaderFromJson(Map<String, dynamic> json) =>
    LabTestHeader(
      id: json['id'] as String,
      testDate: json['test_date'] as String?,
      doctorName: json['doctor_name'] as String?,
      labName: json['lab_name'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$LabTestHeaderToJson(LabTestHeader instance) =>
    <String, dynamic>{
      'id': instance.id,
      'test_date': instance.testDate,
      'doctor_name': instance.doctorName,
      'lab_name': instance.labName,
      'created_at': instance.createdAt,
    };

ExtractedLabTest _$ExtractedLabTestFromJson(Map<String, dynamic> json) =>
    ExtractedLabTest(
      testDate: json['test_date'] as String?,
      doctorName: json['doctor_name'] as String?,
      labName: json['lab_name'] as String?,
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => ExtractedCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExtractedLabTestToJson(ExtractedLabTest instance) =>
    <String, dynamic>{
      'test_date': instance.testDate,
      'doctor_name': instance.doctorName,
      'lab_name': instance.labName,
      'categories': instance.categories,
    };

ExtractedCategory _$ExtractedCategoryFromJson(Map<String, dynamic> json) =>
    ExtractedCategory(
      name: json['name'] as String,
      sortOrder: (json['sort_order'] as num?)?.toInt(),
      parameters: (json['parameters'] as List<dynamic>?)
          ?.map((e) => ExtractedParameter.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExtractedCategoryToJson(ExtractedCategory instance) =>
    <String, dynamic>{
      'name': instance.name,
      'sort_order': instance.sortOrder,
      'parameters': instance.parameters,
    };

ExtractedParameter _$ExtractedParameterFromJson(Map<String, dynamic> json) =>
    ExtractedParameter(
      name: json['name'] as String,
      value: json['value'] as String?,
      unit: json['unit'] as String?,
      refMin: json['ref_min'] as String?,
      refMax: json['ref_max'] as String?,
      flag: json['flag'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ExtractedParameterToJson(ExtractedParameter instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
      'unit': instance.unit,
      'ref_min': instance.refMin,
      'ref_max': instance.refMax,
      'flag': instance.flag,
      'sort_order': instance.sortOrder,
    };

LabTestDetailFile _$LabTestDetailFileFromJson(Map<String, dynamic> json) =>
    LabTestDetailFile(
      id: json['id'] as String,
      originalName: json['original_name'] as String?,
      url: json['url'] as String,
    );

Map<String, dynamic> _$LabTestDetailFileToJson(LabTestDetailFile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'original_name': instance.originalName,
      'url': instance.url,
    };

LabTestDetailParameter _$LabTestDetailParameterFromJson(
  Map<String, dynamic> json,
) => LabTestDetailParameter(
  id: json['id'] as String,
  categoryId: json['category_id'] as String,
  name: json['name'] as String,
  value: json['value'] as String,
  unit: json['unit'] as String?,
  refMin: json['ref_min'] as String?,
  refMax: json['ref_max'] as String?,
  flag: json['flag'] as String?,
  sortOrder: (json['sort_order'] as num?)?.toInt(),
);

Map<String, dynamic> _$LabTestDetailParameterToJson(
  LabTestDetailParameter instance,
) => <String, dynamic>{
  'id': instance.id,
  'category_id': instance.categoryId,
  'name': instance.name,
  'value': instance.value,
  'unit': instance.unit,
  'ref_min': instance.refMin,
  'ref_max': instance.refMax,
  'flag': instance.flag,
  'sort_order': instance.sortOrder,
};

LabTestDetailCategory _$LabTestDetailCategoryFromJson(
  Map<String, dynamic> json,
) => LabTestDetailCategory(
  id: json['id'] as String,
  name: json['name'] as String,
  sortOrder: (json['sort_order'] as num?)?.toInt(),
  parameters: (json['parameters'] as List<dynamic>)
      .map((e) => LabTestDetailParameter.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LabTestDetailCategoryToJson(
  LabTestDetailCategory instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'sort_order': instance.sortOrder,
  'parameters': instance.parameters.map((e) => e.toJson()).toList(),
};

LabTestDetail _$LabTestDetailFromJson(Map<String, dynamic> json) =>
    LabTestDetail(
      id: json['id'] as String,
      testDate: json['test_date'] as String?,
      doctorName: json['doctor_name'] as String?,
      labName: json['lab_name'] as String?,
      labAddress: json['lab_address'] as String?,
      testNumber: json['test_number'] as String?,
      files: (json['files'] as List<dynamic>)
          .map((e) => LabTestDetailFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => LabTestDetailCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$LabTestDetailToJson(LabTestDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'test_date': instance.testDate,
      'doctor_name': instance.doctorName,
      'lab_name': instance.labName,
      'lab_address': instance.labAddress,
      'test_number': instance.testNumber,
      'files': instance.files.map((e) => e.toJson()).toList(),
      'categories': instance.categories.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt,
    };

CreateLabTestCategoryRequest _$CreateLabTestCategoryRequestFromJson(
  Map<String, dynamic> json,
) => CreateLabTestCategoryRequest(
  name: json['name'] as String,
  sortOrder: (json['sort_order'] as num?)?.toInt(),
);

Map<String, dynamic> _$CreateLabTestCategoryRequestToJson(
  CreateLabTestCategoryRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'sort_order': ?instance.sortOrder,
};

UpdateLabTestCategoryRequest _$UpdateLabTestCategoryRequestFromJson(
  Map<String, dynamic> json,
) => UpdateLabTestCategoryRequest(
  name: json['name'] as String?,
  sortOrder: (json['sort_order'] as num?)?.toInt(),
);

Map<String, dynamic> _$UpdateLabTestCategoryRequestToJson(
  UpdateLabTestCategoryRequest instance,
) => <String, dynamic>{
  'name': ?instance.name,
  'sort_order': ?instance.sortOrder,
};

CreateLabTestParameterRequest _$CreateLabTestParameterRequestFromJson(
  Map<String, dynamic> json,
) => CreateLabTestParameterRequest(
  categoryId: json['category_id'] as String,
  name: json['name'] as String,
  value: json['value'] as String,
  unit: json['unit'] as String?,
  refMin: json['ref_min'] as num?,
  refMax: json['ref_max'] as num?,
  flag: json['flag'] as String?,
  sortOrder: (json['sort_order'] as num?)?.toInt(),
);

Map<String, dynamic> _$CreateLabTestParameterRequestToJson(
  CreateLabTestParameterRequest instance,
) => <String, dynamic>{
  'category_id': instance.categoryId,
  'name': instance.name,
  'value': instance.value,
  'unit': ?instance.unit,
  'ref_min': ?instance.refMin,
  'ref_max': ?instance.refMax,
  'flag': ?instance.flag,
  'sort_order': ?instance.sortOrder,
};

DeleteLabTestCategoryResponse _$DeleteLabTestCategoryResponseFromJson(
  Map<String, dynamic> json,
) => DeleteLabTestCategoryResponse(
  deleted: json['deleted'] as bool,
  deletedParameters: (json['deleted_parameters'] as num).toInt(),
);

Map<String, dynamic> _$DeleteLabTestCategoryResponseToJson(
  DeleteLabTestCategoryResponse instance,
) => <String, dynamic>{
  'deleted': instance.deleted,
  'deleted_parameters': instance.deletedParameters,
};

HealthKeyMarker _$HealthKeyMarkerFromJson(Map<String, dynamic> json) =>
    HealthKeyMarker(
      code: json['code'] as String?,
      name: json['name'] as String?,
      value: json['value'] as String?,
      unit: json['unit'] as String?,
      refMin: json['ref_min'] as String?,
      refMax: json['ref_max'] as String?,
      status: json['status'] as String?,
      lastTestDate: json['last_test_date'] as String?,
    );

Map<String, dynamic> _$HealthKeyMarkerToJson(HealthKeyMarker instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'value': instance.value,
      'unit': instance.unit,
      'ref_min': instance.refMin,
      'ref_max': instance.refMax,
      'status': instance.status,
      'last_test_date': instance.lastTestDate,
    };

HealthDiseaseRisk _$HealthDiseaseRiskFromJson(Map<String, dynamic> json) =>
    HealthDiseaseRisk(
      text: json['text'] as String?,
      diseases:
          (json['diseases'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$HealthDiseaseRiskToJson(HealthDiseaseRisk instance) =>
    <String, dynamic>{'text': instance.text, 'diseases': instance.diseases};

HealthOverview _$HealthOverviewFromJson(Map<String, dynamic> json) =>
    HealthOverview(
      overallStatus: json['overall_status'] as String?,
      keyMarkers:
          (json['key_markers'] as List<dynamic>?)
              ?.map((e) => HealthKeyMarker.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      diseaseRisk: json['disease_risk'] == null
          ? null
          : HealthDiseaseRisk.fromJson(
              json['disease_risk'] as Map<String, dynamic>,
            ),
      advice: json['advice'] as String?,
    );

Map<String, dynamic> _$HealthOverviewToJson(HealthOverview instance) =>
    <String, dynamic>{
      'overall_status': instance.overallStatus,
      'key_markers': instance.keyMarkers.map((e) => e.toJson()).toList(),
      'disease_risk': instance.diseaseRisk?.toJson(),
      'advice': instance.advice,
    };

LabOverviewParameter _$LabOverviewParameterFromJson(
  Map<String, dynamic> json,
) => LabOverviewParameter(
  analyteId: json['analyte_id'] as String?,
  name: json['name'] as String?,
  unit: json['unit'] as String?,
  value: json['value'] as String?,
  refMin: json['ref_min'] as String?,
  refMax: json['ref_max'] as String?,
  status: json['status'] as String?,
  lastTestDate: json['last_test_date'] as String?,
  labName: json['lab_name'] as String?,
);

Map<String, dynamic> _$LabOverviewParameterToJson(
  LabOverviewParameter instance,
) => <String, dynamic>{
  'analyte_id': instance.analyteId,
  'name': instance.name,
  'unit': instance.unit,
  'value': instance.value,
  'ref_min': instance.refMin,
  'ref_max': instance.refMax,
  'status': instance.status,
  'last_test_date': instance.lastTestDate,
  'lab_name': instance.labName,
};

LabOverview _$LabOverviewFromJson(Map<String, dynamic> json) => LabOverview(
  overallStatus: json['overall_status'] as String?,
  parameters:
      (json['parameters'] as List<dynamic>?)
          ?.map((e) => LabOverviewParameter.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  advice: json['advice'] as String?,
);

Map<String, dynamic> _$LabOverviewToJson(LabOverview instance) =>
    <String, dynamic>{
      'overall_status': instance.overallStatus,
      'parameters': instance.parameters.map((e) => e.toJson()).toList(),
      'advice': instance.advice,
    };

PaginatedLabOverviewParameters _$PaginatedLabOverviewParametersFromJson(
  Map<String, dynamic> json,
) => PaginatedLabOverviewParameters(
  meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
  data: (json['data'] as List<dynamic>)
      .map((e) => LabOverviewParameter.fromJson(e as Map<String, dynamic>))
      .toList(),
  overallStatus: json['overall_status'] as String?,
);

Map<String, dynamic> _$PaginatedLabOverviewParametersToJson(
  PaginatedLabOverviewParameters instance,
) => <String, dynamic>{
  'meta': instance.meta.toJson(),
  'data': instance.data.map((e) => e.toJson()).toList(),
  'overall_status': instance.overallStatus,
};

UserAnalyteCategory _$UserAnalyteCategoryFromJson(Map<String, dynamic> json) =>
    UserAnalyteCategory(
      id: json['id'] as String,
      code: json['code'] as String,
      nameEn: json['name_en'] as String?,
    );

Map<String, dynamic> _$UserAnalyteCategoryToJson(
  UserAnalyteCategory instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name_en': instance.nameEn,
};

UserAnalyte _$UserAnalyteFromJson(Map<String, dynamic> json) => UserAnalyte(
  id: json['id'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  canonicalUnit: json['canonical_unit'] as String?,
  descriptionEn: json['description_en'] as String?,
  descriptionFa: json['description_fa'] as String?,
  valueType: json['value_type'] as String,
  sortOrder: (json['sort_order'] as num).toInt(),
  observationCount: (json['observation_count'] as num).toInt(),
  latestTestDate: json['latest_test_date'] as String?,
  category: json['category'] == null
      ? null
      : UserAnalyteCategory.fromJson(json['category'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserAnalyteToJson(UserAnalyte instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'canonical_unit': instance.canonicalUnit,
      'description_en': instance.descriptionEn,
      'description_fa': instance.descriptionFa,
      'value_type': instance.valueType,
      'sort_order': instance.sortOrder,
      'observation_count': instance.observationCount,
      'latest_test_date': instance.latestTestDate,
      'category': instance.category,
    };

PaginatedUserAnalytes _$PaginatedUserAnalytesFromJson(
  Map<String, dynamic> json,
) => PaginatedUserAnalytes(
  meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
  data: (json['data'] as List<dynamic>)
      .map((e) => UserAnalyte.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PaginatedUserAnalytesToJson(
  PaginatedUserAnalytes instance,
) => <String, dynamic>{
  'meta': instance.meta.toJson(),
  'data': instance.data.map((e) => e.toJson()).toList(),
};

SeriesRequest _$SeriesRequestFromJson(Map<String, dynamic> json) =>
    SeriesRequest(
      analyteIds: (json['analyte_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$SeriesRequestToJson(SeriesRequest instance) =>
    <String, dynamic>{'analyte_ids': instance.analyteIds};

LabSeriesPoint _$LabSeriesPointFromJson(Map<String, dynamic> json) =>
    LabSeriesPoint(
      date: json['date'] as String?,
      value: json['value'] as num?,
      valueCanonical: json['value_canonical'] as num?,
      rawValue: json['raw_value'] as String?,
    );

Map<String, dynamic> _$LabSeriesPointToJson(LabSeriesPoint instance) =>
    <String, dynamic>{
      'date': instance.date,
      'value': instance.value,
      'value_canonical': instance.valueCanonical,
      'raw_value': instance.rawValue,
    };

LabSeries _$LabSeriesFromJson(Map<String, dynamic> json) => LabSeries(
  analyteId: json['analyte_id'] as String?,
  analyteName: json['analyte_name'] as String?,
  unit: json['unit'] as String?,
  points:
      (json['points'] as List<dynamic>?)
          ?.map((e) => LabSeriesPoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$LabSeriesToJson(LabSeries instance) => <String, dynamic>{
  'analyte_id': instance.analyteId,
  'analyte_name': instance.analyteName,
  'unit': instance.unit,
  'points': instance.points.map((e) => e.toJson()).toList(),
};

LabSeriesResponse _$LabSeriesResponseFromJson(Map<String, dynamic> json) =>
    LabSeriesResponse(
      series:
          (json['series'] as List<dynamic>?)
              ?.map((e) => LabSeries.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$LabSeriesResponseToJson(LabSeriesResponse instance) =>
    <String, dynamic>{
      'series': instance.series.map((e) => e.toJson()).toList(),
    };
