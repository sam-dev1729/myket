import 'package:dio/dio.dart';

import '../../../features/lab_test/data/models/lab_test_models.dart';
import '../mock_storage.dart';
import 'mock_handler.dart';

/// Mock handler for `/lab-test/*` endpoints.
class LabTestHandler extends MockHandler {
  static final _idPattern = RegExp(r'^/lab-test/([^/]+)$');
  static final _treePattern = RegExp(r'^/lab-test/([^/]+)/tree$');
  static final _catPattern = RegExp(r'^/lab-test/([^/]+)/categories$');
  static final _catIdPattern = RegExp(r'^/lab-test/([^/]+)/categories/([^/]+)$');
  static final _paramPattern = RegExp(r'^/lab-test/([^/]+)/parameters$');
  static final _paramIdPattern = RegExp(r'^/lab-test/([^/]+)/parameters/([^/]+)$');

  @override
  bool matches(String method, String path) {
    return path == '/lab-test' || path.startsWith('/lab-test/');
  }

  @override
  Future<ResponseBody> handle(RequestOptions options) async {
    await Future.delayed(const Duration(milliseconds: 120));

    final storage = MockStorage.instance..ensureSeeded();
    final method = options.method;
    final path = options.path;

    // ── Fixed endpoints ──────────────────────────────────────
    if (method == 'POST' && path == '/lab-test/extract') {
      return _handleExtract();
    }
    if (method == 'POST' && path == '/lab-test/compare') {
      return mockError(statusCode: 501, code: 'NOT_IMPLEMENTED', message: 'Compare coming soon');
    }
    if (method == 'GET' && path == '/lab-test/overview') {
      return _handleOverview(storage);
    }
    if (method == 'GET' && path == '/lab-test/overview/parameters') {
      return _handleOverviewParameters(storage, options);
    }
    if (method == 'GET' && path == '/lab-test/overview/health') {
      return _handleHealthOverview(storage);
    }
    if (method == 'GET' && path == '/lab-test/analytes') {
      return _handleAnalytes(storage, options);
    }
    if (method == 'POST' && path == '/lab-test/series') {
      return _handleSeries(storage, options);
    }

    // ── List / Create ────────────────────────────────────────
    if (path == '/lab-test') {
      if (method == 'GET') return _handleList(storage);
      if (method == 'POST') return _handleCreate(storage, options);
    }

    // ── Tree ─────────────────────────────────────────────────
    final tree = _treePattern.firstMatch(path);
    if (tree != null && method == 'PUT') {
      return _handleTree(storage, tree.group(1)!, options);
    }

    // ── Categories ───────────────────────────────────────────
    final catId = _catIdPattern.firstMatch(path);
    if (catId != null) {
      final testId = catId.group(1)!;
      final categoryId = catId.group(2)!;
      if (method == 'PATCH') {
        return _handleUpdateCategory(storage, testId, categoryId, options);
      }
      if (method == 'DELETE') {
        return _handleDeleteCategory(storage, testId, categoryId);
      }
    }
    final cat = _catPattern.firstMatch(path);
    if (cat != null && method == 'POST') {
      return _handleCreateCategory(storage, cat.group(1)!, options);
    }

    // ── Parameters ───────────────────────────────────────────
    final paramId = _paramIdPattern.firstMatch(path);
    if (paramId != null) {
      final testId = paramId.group(1)!;
      final parameterId = paramId.group(2)!;
      if (method == 'PATCH') {
        return _handleUpdateParameter(storage, testId, parameterId, options);
      }
      if (method == 'DELETE') {
        return _handleDeleteParameter(storage, testId, parameterId);
      }
    }
    final param = _paramPattern.firstMatch(path);
    if (param != null && method == 'POST') {
      return _handleCreateParameter(storage, param.group(1)!, options);
    }

    // ── Single test id ───────────────────────────────────────
    final idMatch = _idPattern.firstMatch(path);
    if (idMatch != null) {
      final id = idMatch.group(1)!;
      if (method == 'GET') return _handleGetDetail(storage, id);
      if (method == 'PATCH') return _handleUpdateHeader(storage, id, options);
      if (method == 'DELETE') return _handleDelete(storage, id);
    }

    return mockError(
      statusCode: 404,
      code: 'MOCK_NOT_FOUND',
      message: 'No mock handler for $method $path',
    );
  }

  // ──────────────────────────────────────────────────────────
  // Extract
  // ──────────────────────────────────────────────────────────

  ResponseBody _handleExtract() {
    return mockSuccess({
      'test_date': '2026-11-07',
      'doctor_name': 'دکتر تست',
      'lab_name': 'آزمایشگاه Mock',
      'categories': [
        {
          'name': 'CBC',
          'sort_order': 0,
          'parameters': [
            {
              'name': 'WBC',
              'value': '7.0',
              'unit': '×10³/µL',
              'ref_min': '4',
              'ref_max': '11',
              'flag': null,
              'sort_order': 0,
            },
            {
              'name': 'RBC',
              'value': '4.8',
              'unit': '×10⁶/µL',
              'ref_min': '4.5',
              'ref_max': '5.9',
              'flag': null,
              'sort_order': 1,
            },
            {
              'name': 'HGB',
              'value': '13.5',
              'unit': 'g/dL',
              'ref_min': '13',
              'ref_max': '17',
              'flag': null,
              'sort_order': 2,
            },
          ],
        },
        {
          'name': 'Biochemistry',
          'sort_order': 1,
          'parameters': [
            {
              'name': 'FBS',
              'value': '105',
              'unit': 'mg/dL',
              'ref_min': '70',
              'ref_max': '100',
              'flag': 'H',
              'sort_order': 0,
            },
          ],
        },
      ],
    });
  }

  // ──────────────────────────────────────────────────────────
  // Overview / Health / Analytes / Series
  // ──────────────────────────────────────────────────────────

  ResponseBody _handleOverview(MockStorage storage) {
    final sorted = _sortedTests(storage);
    final all = _collectParameters(sorted);
    final status = _computeOverallStatus(sorted);

    return mockSuccess(
      LabOverview(overallStatus: status, parameters: all.take(10).toList(), advice: '').toJson(),
    );
  }

  ResponseBody _handleOverviewParameters(MockStorage storage, RequestOptions options) {
    final sorted = _sortedTests(storage);
    final all = _collectParameters(sorted);
    final status = _computeOverallStatus(sorted);

    final page = _asInt(options.queryParameters['page']) ?? 1;
    final limit = _asInt(options.queryParameters['limit']) ?? 10;
    final search = options.queryParameters['search']?.toString().trim();

    var filtered = all;
    if (search != null && search.isNotEmpty) {
      filtered = all.where((p) => (p.name ?? '').contains(search)).toList();
    }

    final total = filtered.length;
    final totalPages = total == 0 ? 0 : ((total + limit - 1) ~/ limit);
    final start = (page - 1) * limit;
    final pageData = filtered.skip(start).take(limit).toList();

    return mockSuccess({
      'meta': {'page': page, 'limit': limit, 'total': total, 'total_page': totalPages},
      'data': pageData.map((p) => p.toJson()).toList(),
      'overall_status': status,
    });
  }

  ResponseBody _handleHealthOverview(MockStorage storage) {
    final sorted = _sortedTests(storage);
    final status = _computeOverallStatus(sorted);

    const keyNames = ['FBS', 'TOTAL_CALCIUM', 'ALT', 'ALTSGPT', 'WBC'];
    final markers = <HealthKeyMarker>[];

    for (final name in keyNames) {
      LabTestDetailParameter? latest;
      String? lastDate;
      for (final test in sorted) {
        for (final cat in test.categories) {
          for (final p in cat.parameters) {
            if (p.name == name &&
                (lastDate == null || (test.testDate ?? '').compareTo(lastDate) > 0)) {
              latest = p;
              lastDate = test.testDate;
            }
          }
        }
      }
      if (latest != null) {
        markers.add(
          HealthKeyMarker(
            code: name,
            name: name,
            value: latest.value,
            unit: latest.unit,
            refMin: latest.refMin,
            refMax: latest.refMax,
            status: _statusFor(latest),
            lastTestDate: lastDate,
          ),
        );
      }
    }

    return mockSuccess(
      HealthOverview(
        overallStatus: status,
        keyMarkers: markers,
        diseaseRisk: const HealthDiseaseRisk(text: '', diseases: []),
        advice: '',
      ).toJson(),
    );
  }

  ResponseBody _handleAnalytes(MockStorage storage, RequestOptions options) {
    final sorted = _sortedTests(storage);

    // Build unique analytes by parameter name.
    final map = <String, _AnalyteAccumulator>{};
    for (final test in sorted) {
      for (final cat in test.categories) {
        for (final p in cat.parameters) {
          final key = p.name;
          final existing = map[key];
          if (existing == null) {
            map[key] = _AnalyteAccumulator(
              name: p.name,
              unit: p.unit,
              categoryName: cat.name,
              latestDate: test.testDate,
            );
          } else {
            existing.observationCount += 1;
            if (test.testDate != null &&
                (existing.latestDate == null ||
                    test.testDate!.compareTo(existing.latestDate!) > 0)) {
              existing.latestDate = test.testDate;
            }
          }
        }
      }
    }

    final all = map.values.toList()..sort((a, b) => a.name.compareTo(b.name));

    final page = _asInt(options.queryParameters['page']) ?? 1;
    final limit = _asInt(options.queryParameters['limit']) ?? 50;
    final search = options.queryParameters['search']?.toString().trim();

    var filtered = all;
    if (search != null && search.isNotEmpty) {
      filtered = all.where((a) => a.name.contains(search)).toList();
    }

    final total = filtered.length;
    final totalPages = total == 0 ? 0 : ((total + limit - 1) ~/ limit);
    final start = (page - 1) * limit;
    final pageData = filtered.skip(start).take(limit).toList();

    final data = <Map<String, dynamic>>[];
    for (var i = 0; i < pageData.length; i++) {
      final a = pageData[i];
      data.add(
        UserAnalyte(
          id: _analyteIdForName(a.name),
          code: a.name,
          name: a.name,
          canonicalUnit: a.unit,
          valueType: 'NUMERIC',
          sortOrder: start + i,
          observationCount: a.observationCount,
          latestTestDate: a.latestDate,
          category: UserAnalyteCategory(
            id: 'mock-analyte-cat-${a.categoryName}',
            code: a.categoryName.toUpperCase(),
            nameEn: a.categoryName,
          ),
        ).toJson(),
      );
    }

    return mockSuccess({
      'meta': {'page': page, 'limit': limit, 'total': total, 'total_page': totalPages},
      'data': data,
    });
  }

  ResponseBody _handleSeries(MockStorage storage, RequestOptions options) {
    final data = _asMap(options.data);
    final ids =
        (data['analyte_ids'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];

    final sorted = _sortedTests(storage);
    final seriesList = <Map<String, dynamic>>[];

    for (final id in ids) {
      final name = _nameFromAnalyteId(id);
      final points = <Map<String, dynamic>>[];
      String? unit;

      for (final test in sorted) {
        for (final cat in test.categories) {
          for (final p in cat.parameters) {
            if (p.name == name) {
              unit ??= p.unit;
              final v = _parseNum(p.value);
              points.add({
                'date': test.testDate,
                'value': v,
                'value_canonical': v,
                'raw_value': p.value,
              });
              break;
            }
          }
        }
      }

      points.sort((a, b) => (a['date'] ?? '').toString().compareTo((b['date'] ?? '').toString()));

      seriesList.add({'analyte_id': id, 'analyte_name': name, 'unit': unit, 'points': points});
    }

    return mockSuccess({'series': seriesList});
  }

  // ──────────────────────────────────────────────────────────
  // List / Detail / Create / Update / Delete
  // ──────────────────────────────────────────────────────────

  ResponseBody _handleList(MockStorage storage) {
    final sorted = _sortedTests(storage);
    final headers = sorted
        .map(
          (t) => LabTestHeader(
            id: t.id,
            testDate: t.testDate,
            doctorName: t.doctorName,
            labName: t.labName,
            createdAt: t.createdAt,
          ).toJson(),
        )
        .toList();
    return mockSuccess(headers);
  }

  ResponseBody _handleGetDetail(MockStorage storage, String id) {
    final test = storage.labTests[id];
    if (test == null) {
      return mockError(statusCode: 404, code: 'NOT_FOUND', message: 'Lab test not found');
    }
    return mockSuccess(test.toJson());
  }

  ResponseBody _handleCreate(MockStorage storage, RequestOptions options) {
    final data = _asMap(options.data);
    final id = _newId('test');
    final testDate = _asString(data['test_date']);
    final doctorName = _asString(data['doctor_name']);
    final labName = _asString(data['lab_name']);

    final fileIds =
        (data['file_ids'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];

    final files = fileIds
        .map(
          (fid) => LabTestDetailFile(
            id: fid,
            originalName: storage.uploadedFiles[fid]?.originalName,
            url: 'https://mock.local/files/$fid',
          ),
        )
        .toList();

    final test = LabTestDetail(
      id: id,
      testDate: testDate,
      doctorName: doctorName,
      labName: labName,
      labAddress: null,
      testNumber: null,
      files: files,
      categories: const [],
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );

    storage.labTests[id] = test;

    return mockSuccess(
      CreatedLabTestResponse(
        id: id,
        testDate: testDate,
        doctorName: doctorName,
        labName: labName,
      ).toJson(),
    );
  }

  ResponseBody _handleUpdateHeader(MockStorage storage, String id, RequestOptions options) {
    final test = storage.labTests[id];
    if (test == null) {
      return mockError(statusCode: 404, code: 'NOT_FOUND', message: 'Lab test not found');
    }

    final data = _asMap(options.data);
    final updated = LabTestDetail(
      id: test.id,
      testDate: data.containsKey('test_date') ? _asString(data['test_date']) : test.testDate,
      doctorName: data.containsKey('doctor_name')
          ? _asString(data['doctor_name'])
          : test.doctorName,
      labName: data.containsKey('lab_name') ? _asString(data['lab_name']) : test.labName,
      labAddress: data.containsKey('lab_address')
          ? _asString(data['lab_address'])
          : test.labAddress,
      testNumber: data.containsKey('test_number')
          ? _asString(data['test_number'])
          : test.testNumber,
      files: test.files,
      categories: test.categories,
      createdAt: test.createdAt,
    );

    storage.labTests[id] = updated;
    return mockSuccess(updated.toJson());
  }

  ResponseBody _handleDelete(MockStorage storage, String id) {
    if (!storage.labTests.containsKey(id)) {
      return mockError(statusCode: 404, code: 'NOT_FOUND', message: 'Lab test not found');
    }
    storage.labTests.remove(id);
    return mockSuccess(null);
  }

  ResponseBody _handleTree(MockStorage storage, String id, RequestOptions options) {
    final test = storage.labTests[id];
    if (test == null) {
      return mockError(statusCode: 404, code: 'NOT_FOUND', message: 'Lab test not found');
    }

    final raw = options.data;
    final List<dynamic> list;
    if (raw is List) {
      list = raw;
    } else if (raw is String) {
      list = const [];
    } else {
      list = const [];
    }

    final newCats = <LabTestDetailCategory>[];
    for (var ci = 0; ci < list.length; ci++) {
      final catMap = _asMap(list[ci]);
      final catId = _newId('cat');
      final params = <LabTestDetailParameter>[];
      final rawParams = catMap['parameters'];
      if (rawParams is List) {
        for (var pi = 0; pi < rawParams.length; pi++) {
          final pm = _asMap(rawParams[pi]);
          params.add(
            LabTestDetailParameter(
              id: _newId('p'),
              categoryId: catId,
              name: _asString(pm['name']) ?? '',
              value: _asString(pm['value']) ?? '',
              unit: _asString(pm['unit']),
              refMin: _asString(pm['ref_min']),
              refMax: _asString(pm['ref_max']),
              flag: _asString(pm['flag']),
              sortOrder: _asInt(pm['sort_order']) ?? pi,
            ),
          );
        }
      }
      newCats.add(
        LabTestDetailCategory(
          id: catId,
          name: _asString(catMap['name']) ?? 'دسته',
          sortOrder: _asInt(catMap['sort_order']) ?? ci,
          parameters: params,
        ),
      );
    }

    final updated = _withCategories(test, newCats);
    storage.labTests[id] = updated;
    return mockSuccess(null);
  }

  // ──────────────────────────────────────────────────────────
  // Category CRUD
  // ──────────────────────────────────────────────────────────

  ResponseBody _handleCreateCategory(MockStorage storage, String testId, RequestOptions options) {
    final test = storage.labTests[testId];
    if (test == null) return _notFound('Lab test not found');

    final data = _asMap(options.data);
    final name = _asString(data['name']);
    if (name == null || name.isEmpty) {
      return mockError(statusCode: 400, code: 'BAD_REQUEST', message: 'Name required');
    }

    final cat = LabTestDetailCategory(
      id: _newId('cat'),
      name: name,
      sortOrder: _asInt(data['sort_order']) ?? test.categories.length,
      parameters: const [],
    );

    final updated = _withCategories(test, [...test.categories, cat]);
    storage.labTests[testId] = updated;

    return mockSuccess(cat.toJson());
  }

  ResponseBody _handleUpdateCategory(
    MockStorage storage,
    String testId,
    String categoryId,
    RequestOptions options,
  ) {
    final test = storage.labTests[testId];
    if (test == null) return _notFound('Lab test not found');

    final idx = test.categories.indexWhere((c) => c.id == categoryId);
    if (idx < 0) return _notFound('Category not found');

    final data = _asMap(options.data);
    final old = test.categories[idx];
    final updatedCat = LabTestDetailCategory(
      id: old.id,
      name: _asString(data['name']) ?? old.name,
      sortOrder: _asInt(data['sort_order']) ?? old.sortOrder,
      parameters: old.parameters,
    );

    final newCats = [...test.categories];
    newCats[idx] = updatedCat;
    storage.labTests[testId] = _withCategories(test, newCats);

    return mockSuccess(updatedCat.toJson());
  }

  ResponseBody _handleDeleteCategory(MockStorage storage, String testId, String categoryId) {
    final test = storage.labTests[testId];
    if (test == null) return _notFound('Lab test not found');

    final idx = test.categories.indexWhere((c) => c.id == categoryId);
    if (idx < 0) return _notFound('Category not found');

    final removed = test.categories[idx];
    final newCats = [...test.categories]..removeAt(idx);
    storage.labTests[testId] = _withCategories(test, newCats);

    // Pass a raw Map: DeleteLabTestCategoryResponse has no toJson().
    return mockSuccess({'deleted': true, 'deleted_parameters': removed.parameters.length});
  }

  // ──────────────────────────────────────────────────────────
  // Parameter CRUD
  // ──────────────────────────────────────────────────────────

  ResponseBody _handleCreateParameter(MockStorage storage, String testId, RequestOptions options) {
    final test = storage.labTests[testId];
    if (test == null) return _notFound('Lab test not found');

    final data = _asMap(options.data);
    final categoryId = _asString(data['category_id']);
    if (categoryId == null) {
      return mockError(statusCode: 400, code: 'BAD_REQUEST', message: 'category_id required');
    }

    final catIdx = test.categories.indexWhere((c) => c.id == categoryId);
    if (catIdx < 0) return _notFound('Category not found');

    final name = _asString(data['name']) ?? '';
    final value = _asString(data['value']) ?? '';

    final param = LabTestDetailParameter(
      id: _newId('p'),
      categoryId: categoryId,
      name: name,
      value: value,
      unit: _asString(data['unit']),
      refMin: _asString(data['ref_min']),
      refMax: _asString(data['ref_max']),
      flag: _asString(data['flag']),
      sortOrder: _asInt(data['sort_order']) ?? test.categories[catIdx].parameters.length,
    );

    final cat = test.categories[catIdx];
    final newCats = [...test.categories];
    newCats[catIdx] = LabTestDetailCategory(
      id: cat.id,
      name: cat.name,
      sortOrder: cat.sortOrder,
      parameters: [...cat.parameters, param],
    );
    storage.labTests[testId] = _withCategories(test, newCats);

    return mockSuccess(param.toJson());
  }

  ResponseBody _handleUpdateParameter(
    MockStorage storage,
    String testId,
    String parameterId,
    RequestOptions options,
  ) {
    final test = storage.labTests[testId];
    if (test == null) return _notFound('Lab test not found');

    final data = _asMap(options.data);

    // Locate the parameter across categories.
    int? catIdx;
    int? paramIdx;
    LabTestDetailParameter? existing;
    for (var ci = 0; ci < test.categories.length; ci++) {
      final pi = test.categories[ci].parameters.indexWhere((p) => p.id == parameterId);
      if (pi >= 0) {
        catIdx = ci;
        paramIdx = pi;
        existing = test.categories[ci].parameters[pi];
        break;
      }
    }
    if (existing == null || catIdx == null || paramIdx == null) {
      return _notFound('Parameter not found');
    }

    final newCategoryId = _asString(data['category_id']) ?? existing.categoryId;
    final updatedParam = LabTestDetailParameter(
      id: existing.id,
      categoryId: newCategoryId,
      name: _asString(data['name']) ?? existing.name,
      value: _asString(data['value']) ?? existing.value,
      unit: data.containsKey('unit') ? _asString(data['unit']) : existing.unit,
      refMin: data.containsKey('ref_min') ? _asString(data['ref_min']) : existing.refMin,
      refMax: data.containsKey('ref_max') ? _asString(data['ref_max']) : existing.refMax,
      flag: data.containsKey('flag') ? _asString(data['flag']) : existing.flag,
      sortOrder: _asInt(data['sort_order']) ?? existing.sortOrder,
    );

    // Rebuild categories with the parameter possibly moved.
    final newCats = <LabTestDetailCategory>[];
    for (var ci = 0; ci < test.categories.length; ci++) {
      final cat = test.categories[ci];
      final params = [...cat.parameters];

      if (ci == catIdx) params.removeAt(paramIdx);
      if (cat.id == newCategoryId) {
        params.add(updatedParam);
        params.sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));
      }

      newCats.add(
        LabTestDetailCategory(
          id: cat.id,
          name: cat.name,
          sortOrder: cat.sortOrder,
          parameters: params,
        ),
      );
    }

    storage.labTests[testId] = _withCategories(test, newCats);
    return mockSuccess(updatedParam.toJson());
  }

  ResponseBody _handleDeleteParameter(MockStorage storage, String testId, String parameterId) {
    final test = storage.labTests[testId];
    if (test == null) return _notFound('Lab test not found');

    final newCats = <LabTestDetailCategory>[];
    var found = false;

    for (final cat in test.categories) {
      final params = cat.parameters.where((p) => p.id != parameterId).toList();
      if (params.length != cat.parameters.length) found = true;
      newCats.add(
        LabTestDetailCategory(
          id: cat.id,
          name: cat.name,
          sortOrder: cat.sortOrder,
          parameters: params,
        ),
      );
    }

    if (!found) return _notFound('Parameter not found');

    storage.labTests[testId] = _withCategories(test, newCats);
    return mockSuccess(null);
  }
}

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────

/// Returns a [LabTestDetail] with categories replaced.
LabTestDetail _withCategories(LabTestDetail test, List<LabTestDetailCategory> cats) {
  return LabTestDetail(
    id: test.id,
    testDate: test.testDate,
    doctorName: test.doctorName,
    labName: test.labName,
    labAddress: test.labAddress,
    testNumber: test.testNumber,
    files: test.files,
    categories: cats,
    createdAt: test.createdAt,
  );
}

/// Returns lab tests sorted by test date descending.
List<LabTestDetail> _sortedTests(MockStorage storage) {
  final list = storage.labTests.values.toList()
    ..sort((a, b) => (b.testDate ?? '').compareTo(a.testDate ?? ''));
  return list;
}

/// Flattens all parameters from the given tests into overview rows.
List<LabOverviewParameter> _collectParameters(List<LabTestDetail> tests) {
  final out = <LabOverviewParameter>[];
  for (final test in tests) {
    for (final cat in test.categories) {
      for (final p in cat.parameters) {
        out.add(
          LabOverviewParameter(
            analyteId: _analyteIdForName(p.name),
            name: p.name,
            unit: p.unit,
            value: p.value,
            refMin: p.refMin,
            refMax: p.refMax,
            status: _statusFor(p),
            lastTestDate: test.testDate,
            labName: test.labName,
          ),
        );
      }
    }
  }
  return out;
}

/// Computes overall health status from all seeded tests.
String _computeOverallStatus(List<LabTestDetail> tests) {
  var total = 0;
  var abnormal = 0;
  for (final t in tests) {
    for (final c in t.categories) {
      for (final p in c.parameters) {
        total++;
        final f = p.flag;
        if (f != null && f.isNotEmpty && f != 'N') abnormal++;
      }
    }
  }
  if (total == 0 || abnormal == 0) return 'green';
  if (abnormal <= 2) return 'orange';
  return 'red';
}

/// Returns HIGH / LOW / NORMAL for a parameter row.
String _statusFor(LabTestDetailParameter p) {
  final f = p.flag?.toUpperCase();
  if (f == null || f.isEmpty || f == 'N') return 'NORMAL';
  if (f.startsWith('H')) return 'HIGH';
  if (f.startsWith('L')) return 'LOW';
  return 'NORMAL';
}

/// Generates a stable mock analyte id from a parameter name.
String _analyteIdForName(String name) => 'mock-analyte-${name.toLowerCase().replaceAll(' ', '-')}';

/// Recovers a parameter name from a mock analyte id.
String _nameFromAnalyteId(String id) {
  const prefix = 'mock-analyte-';
  final raw = id.startsWith(prefix) ? id.substring(prefix.length) : id;
  return raw.replaceAll('-', ' ');
}

/// Generates a unique mock id with the given prefix.
String _newId(String prefix) => 'mock-$prefix-${DateTime.now().microsecondsSinceEpoch}';

/// Parses a numeric string into a num, or null.
num? _parseNum(String? s) {
  if (s == null) return null;
  return num.tryParse(s);
}

/// Returns a 404 response with the given message.
ResponseBody _notFound(String message) =>
    mockError(statusCode: 404, code: 'NOT_FOUND', message: message);

/// Safely converts an arbitrary request payload to a map.
Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  if (value != null) {
    try {
      final dynamic dynamicValue = value;
      final json = dynamicValue.toJson();
      if (json is Map) {
        return json.map((key, item) => MapEntry(key.toString(), item));
      }
    } catch (_) {}
  }
  return const <String, dynamic>{};
}

/// Converts a value to a non-empty string, or null.
String? _asString(Object? value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

/// Converts a value to an int, or null.
int? _asInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

/// Accumulator used while building unique analyte rows.
class _AnalyteAccumulator {
  final String name;
  final String? unit;
  final String categoryName;
  String? latestDate;
  int observationCount = 1;

  _AnalyteAccumulator({
    required this.name,
    required this.unit,
    required this.categoryName,
    required this.latestDate,
  });
}
