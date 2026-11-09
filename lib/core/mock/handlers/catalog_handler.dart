import 'package:dio/dio.dart';

import '../../../features/profile/data/models/user_profile.dart';
import '../mock_storage.dart';
import 'mock_handler.dart';

/// Mock handler for medical-catalog endpoints.
///
/// Covers allergies, underlying diseases, and medical histories under
/// `/allergy`, `/underlying-disease`, `/medical-history`.
class CatalogHandler extends MockHandler {
  static const _catalogRoots = {'allergy', 'underlying-disease', 'medical-history'};

  @override
  bool matches(String method, String path) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return false;
    if (!_catalogRoots.contains(parts.first)) return false;

    if (parts.length == 1) {
      return method == 'GET' || method == 'POST';
    }
    if (parts.length == 2) {
      return method == 'PATCH' || method == 'DELETE';
    }
    return false;
  }

  @override
  Future<ResponseBody> handle(RequestOptions options) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final storage = MockStorage.instance..ensureSeeded();
    final parts = options.path.split('/').where((p) => p.isNotEmpty).toList();
    final root = parts.first;
    final list = _listFor(storage, root);

    if (list == null) {
      return mockError(statusCode: 404, code: 'NOT_FOUND', message: 'Unknown catalog: $root');
    }

    if (parts.length == 1) {
      if (options.method == 'GET') {
        final search = options.queryParameters['search']?.toString().trim();
        var items = list;
        if (search != null && search.isNotEmpty) {
          items = items.where((i) => i.name.contains(search)).toList();
        }
        return mockSuccess(items.map((i) => i.toJson()).toList());
      }

      if (options.method == 'POST') {
        final data = _asMap(options.data);
        final name = (_asString(data['name']) ?? '').trim();
        if (name.isEmpty) {
          return mockError(statusCode: 400, code: 'BAD_REQUEST', message: 'Name is required');
        }
        final item = MedicalCatalogItem(id: _newId('custom'), name: name, isSystem: false);
        list.add(item);
        return mockSuccess(item.toJson());
      }
    }

    if (parts.length == 2) {
      final id = parts[1];
      final index = list.indexWhere((i) => i.id == id);
      if (index < 0) {
        return mockError(statusCode: 404, code: 'NOT_FOUND', message: 'Item not found');
      }

      if (options.method == 'PATCH') {
        final data = _asMap(options.data);
        final name = (_asString(data['name']) ?? '').trim();
        if (name.isEmpty) {
          return mockError(statusCode: 400, code: 'BAD_REQUEST', message: 'Name is required');
        }
        final old = list[index];
        list[index] = MedicalCatalogItem(id: old.id, name: name, isSystem: old.isSystem);
        return mockSuccess(list[index].toJson());
      }

      if (options.method == 'DELETE') {
        list.removeAt(index);
        return mockSuccess(null);
      }
    }

    return mockError(
      statusCode: 404,
      code: 'MOCK_NOT_FOUND',
      message: 'No mock handler for ${options.method} ${options.path}',
    );
  }
}

/// Returns the mutable catalog list for the given root, or null.
List<MedicalCatalogItem>? _listFor(MockStorage storage, String root) {
  switch (root) {
    case 'allergy':
      return storage.allergies;
    case 'underlying-disease':
      return storage.underlyingDiseases;
    case 'medical-history':
      return storage.medicalHistories;
    default:
      return null;
  }
}

/// Generates a unique mock id with the given prefix.
String _newId(String prefix) => 'mock-$prefix-${DateTime.now().microsecondsSinceEpoch}';

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
