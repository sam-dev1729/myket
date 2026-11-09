import 'package:dio/dio.dart';

import '../../../features/profile/data/models/geo_models.dart'; // 👈 این ایمپورت باید اضافه شود
import '../../../features/profile/data/models/user_profile.dart';
import '../mock_storage.dart';
import 'mock_handler.dart';

/// Mock handler for user-profile endpoints.
class ProfileHandler extends MockHandler {
  @override
  bool matches(String method, String path) {
    if (path == '/user/profile' && (method == 'GET' || method == 'PATCH')) {
      return true;
    }

    if (method != 'POST') return false;

    return path == '/user/profile/allergy/add' ||
        path == '/user/profile/allergy/remove' ||
        path == '/user/profile/underlying-disease/add' ||
        path == '/user/profile/underlying-disease/remove' ||
        path == '/user/profile/medical-history/add' ||
        path == '/user/profile/medical-history/remove' ||
        path == '/user/profile/google-account/attach' ||
        path == '/user/profile/google-account/detach';
  }

  @override
  Future<ResponseBody> handle(RequestOptions options) async {
    await Future.delayed(const Duration(milliseconds: 120));

    final storage = MockStorage.instance..ensureSeeded();
    final mobile = _currentMobile(options);

    if (mobile == null) {
      return mockError(statusCode: 401, code: 'UNAUTHORIZED', message: 'Unauthorized');
    }

    final user = storage.users[mobile];
    if (user == null) {
      return mockError(statusCode: 404, code: 'USER_NOT_FOUND', message: 'User not found');
    }

    final data = _asMap(options.data);

    if (options.path == '/user/profile') {
      if (options.method == 'GET') {
        return mockSuccess(user.toJson());
      }

      final updated = _applyProfileUpdate(user, data);
      storage.users[mobile] = updated;
      return mockSuccess(updated.toJson());
    }

    late UserProfile updated;

    switch (options.path) {
      case '/user/profile/allergy/add':
        updated = _addAllergy(user, data);
        break;
      case '/user/profile/allergy/remove':
        updated = _removeAllergy(user, data);
        break;
      case '/user/profile/underlying-disease/add':
        updated = _addUnderlyingDisease(user, data);
        break;
      case '/user/profile/underlying-disease/remove':
        updated = _removeUnderlyingDisease(user, data);
        break;
      case '/user/profile/medical-history/add':
        updated = _addMedicalHistory(user, data);
        break;
      case '/user/profile/medical-history/remove':
        updated = _removeMedicalHistory(user, data);
        break;
      case '/user/profile/google-account/attach':
        updated = _attachGoogleAccount(user, data);
        break;
      case '/user/profile/google-account/detach':
        updated = _detachGoogleAccount(user, data);
        break;
      default:
        return mockError(
          statusCode: 404,
          code: 'MOCK_NOT_FOUND',
          message: 'No mock handler for ${options.method} ${options.path}',
        );
    }

    storage.users[mobile] = updated;
    return mockSuccess(updated.toJson());
  }
}

/// Applies PATCH /user/profile changes to an existing profile.
UserProfile _applyProfileUpdate(UserProfile user, Map<String, dynamic> data) {
  return UserProfile(
    id: user.id,
    role: user.role,
    mobile: user.mobile,
    firstName: data.containsKey('first_name') ? _asString(data['first_name']) : user.firstName,
    lastName: data.containsKey('last_name') ? _asString(data['last_name']) : user.lastName,
    birthDate: data.containsKey('birth_date') ? _asString(data['birth_date']) : user.birthDate,
    isMale: data.containsKey('is_male') ? _asBool(data['is_male']) : user.isMale,
    height: data.containsKey('height') ? _asInt(data['height']) : user.height,
    weight: data.containsKey('weight') ? _asInt(data['weight']) : user.weight,
    isPregnant: data.containsKey('is_pregnant') ? _asBool(data['is_pregnant']) : user.isPregnant,
    bloodType: data.containsKey('blood_type') ? _asString(data['blood_type']) : user.bloodType,
    city: data.containsKey('city_id')
        ? _cityFromId(_asString(data['city_id']), user.city)
        : user.city,
    underlyingDiseases: user.underlyingDiseases,
    medicalHistories: user.medicalHistories,
    allergies: user.allergies,
    localEthnicity: data.containsKey('local_ethnicity_id')
        ? _ethnicityFromId(_asString(data['local_ethnicity_id']), user.localEthnicity)
        : user.localEthnicity,
    googleAccounts: user.googleAccounts,
  );
}

/// Copies a profile while replacing one of its linked-item lists.
UserProfile _copyWithLinkedItems(
  UserProfile user, {
  List<LinkedItem>? allergies,
  List<LinkedItem>? underlyingDiseases,
  List<LinkedItem>? medicalHistories,
  List<GoogleAccount>? googleAccounts,
}) {
  return UserProfile(
    id: user.id,
    role: user.role,
    mobile: user.mobile,
    firstName: user.firstName,
    lastName: user.lastName,
    birthDate: user.birthDate,
    isMale: user.isMale,
    height: user.height,
    weight: user.weight,
    isPregnant: user.isPregnant,
    bloodType: user.bloodType,
    city: user.city,
    underlyingDiseases: underlyingDiseases ?? user.underlyingDiseases,
    medicalHistories: medicalHistories ?? user.medicalHistories,
    allergies: allergies ?? user.allergies,
    localEthnicity: user.localEthnicity,
    googleAccounts: googleAccounts ?? user.googleAccounts,
  );
}

/// Adds an allergy linked item to the profile.
UserProfile _addAllergy(UserProfile user, Map<String, dynamic> data) {
  final item = _readCatalogItem(data, 'allergy', 'allergy_id');
  final linked = LinkedItem(id: _newId('link'), allergy: item);
  return _copyWithLinkedItems(user, allergies: [...?user.allergies, linked]);
}

/// Removes an allergy linked item from the profile.
UserProfile _removeAllergy(UserProfile user, Map<String, dynamic> data) {
  final id = _readRemovalId(data, 'allergy_id');
  final items = (user.allergies ?? const <LinkedItem>[])
      .where((item) => item.id != id && item.allergy?.id != id)
      .toList();
  return _copyWithLinkedItems(user, allergies: items);
}

/// Adds an underlying-disease linked item to the profile.
UserProfile _addUnderlyingDisease(UserProfile user, Map<String, dynamic> data) {
  final item = _readCatalogItem(data, 'underlying_disease', 'underlying_disease_id');
  final linked = LinkedItem(id: _newId('link'), underlyingDisease: item);
  return _copyWithLinkedItems(user, underlyingDiseases: [...?user.underlyingDiseases, linked]);
}

/// Removes an underlying-disease linked item from the profile.
UserProfile _removeUnderlyingDisease(UserProfile user, Map<String, dynamic> data) {
  final id = _readRemovalId(data, 'underlying_disease_id');
  final items = (user.underlyingDiseases ?? const <LinkedItem>[])
      .where((item) => item.id != id && item.underlyingDisease?.id != id)
      .toList();
  return _copyWithLinkedItems(user, underlyingDiseases: items);
}

/// Adds a medical-history linked item to the profile.
UserProfile _addMedicalHistory(UserProfile user, Map<String, dynamic> data) {
  final item = _readCatalogItem(data, 'medical_history', 'medical_history_id');
  final linked = LinkedItem(id: _newId('link'), medicalHistory: item);
  return _copyWithLinkedItems(user, medicalHistories: [...?user.medicalHistories, linked]);
}

/// Removes a medical-history linked item from the profile.
UserProfile _removeMedicalHistory(UserProfile user, Map<String, dynamic> data) {
  final id = _readRemovalId(data, 'medical_history_id');
  final items = (user.medicalHistories ?? const <LinkedItem>[])
      .where((item) => item.id != id && item.medicalHistory?.id != id)
      .toList();
  return _copyWithLinkedItems(user, medicalHistories: items);
}

/// Attaches a Google account to the profile.
UserProfile _attachGoogleAccount(UserProfile user, Map<String, dynamic> data) {
  final account = GoogleAccount(
    id: _asString(data['google_account_id']) ?? _asString(data['id']) ?? _newId('google'),
    email: _asString(data['google_email']) ?? _asString(data['email']),
    firstName: _asString(data['google_first_name']) ?? _asString(data['first_name']),
    picture: _asString(data['google_picture']) ?? _asString(data['picture']),
  );

  return _copyWithLinkedItems(user, googleAccounts: [...?user.googleAccounts, account]);
}

/// Detaches a Google account from the profile.
UserProfile _detachGoogleAccount(UserProfile user, Map<String, dynamic> data) {
  final id = _asString(data['google_account_id']) ?? _asString(data['id']);
  final email = _asString(data['google_email']) ?? _asString(data['email']);

  final accounts = (user.googleAccounts ?? const <GoogleAccount>[])
      .where((account) => account.id != id && account.email != email)
      .toList();

  return _copyWithLinkedItems(user, googleAccounts: accounts);
}

/// Reads a catalog item from add-request payload.
MedicalCatalogItem _readCatalogItem(Map<String, dynamic> data, String objectKey, String idKey) {
  final raw = data[objectKey] ?? data['item'] ?? data['catalog_item'];

  if (raw is Map) {
    final map = _asMap(raw);
    return MedicalCatalogItem(
      id: _asString(map['id']) ?? _newId('catalog'),
      name: _asString(map['name']) ?? 'آیتم تست',
      isSystem: _asBool(map['is_system']),
    );
  }

  final rawId = raw is String ? raw : null;
  final id = rawId ?? _asString(data[idKey]) ?? _asString(data['id']);

  final catalogName = _lookupCatalogName(id, objectKey);
  final name = _asString(data['name']) ?? catalogName ?? 'آیتم تست';

  return MedicalCatalogItem(id: id ?? _newId('catalog'), name: name, isSystem: true);
}

/// Looks up a catalog item name from [MockStorage] by id.
String? _lookupCatalogName(String? id, String objectKey) {
  if (id == null) return null;
  final storage = MockStorage.instance;
  final list = switch (objectKey) {
    'allergy' => storage.allergies,
    'underlying_disease' => storage.underlyingDiseases,
    'medical_history' => storage.medicalHistories,
    _ => const <MedicalCatalogItem>[],
  };
  for (final item in list) {
    if (item.id == id) return item.name;
  }
  return null;
}

/// Reads a linked-item or catalog id from remove-request payload.
String? _readRemovalId(Map<String, dynamic> data, String catalogIdKey) {
  return _asString(data['linked_item_id']) ??
      _asString(data['id']) ??
      _asString(data[catalogIdKey]);
}

/// Resolves a mock city by id.
CityInfo? _cityFromId(String? id, CityInfo? current) {
  if (id == null) return null;
  if (current?.id == id) return current;

  if (id == 'mock-city-tehran') {
    return const CityInfo(
      id: 'mock-city-tehran',
      name: 'تهران',
      provinceId: 'mock-province-tehran',
    );
  }

  return CityInfo(id: id);
}

/// Resolves a mock local ethnicity by id.
LocalEthnicity? _ethnicityFromId(String? id, LocalEthnicity? current) {
  if (id == null) return null;
  if (current?.id == id) return current;
  // در حالت mock فقط id را برمی‌گردانیم و نام خالی می‌ماند
  return LocalEthnicity(id: id, name: 'قومیت تست');
}

/// Extracts current mobile from the mock access token.
String? _currentMobile(RequestOptions options) {
  final raw = options.headers['Authorization'] ?? options.headers['authorization'];
  final auth = raw is String
      ? raw
      : raw is List && raw.isNotEmpty
      ? raw.first.toString()
      : null;

  if (auth == null || !auth.startsWith('Bearer ')) return null;

  final token = auth.substring(7);
  if (!token.startsWith('mock-access-')) return null;

  return token.substring('mock-access-'.length);
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

/// Converts a value to an int, or null.
int? _asInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

/// Converts a value to a bool, or null.
bool? _asBool(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;

  final text = value.toString().toLowerCase();
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return null;
}