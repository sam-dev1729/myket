import 'package:flutter_test/flutter_test.dart';
import 'package:myket/core/constants/app_constants.dart';
import 'package:myket/core/network/api_exception.dart';
import 'package:myket/core/network/api_response.dart';

/// Unit tests for the backend envelope parser [ApiResponse].
void main() {
  group('ApiResponse - success parsing', () {
    test('should parse body when success is true', () {
      final json = <String, dynamic>{
        'success': true,
        'body': {'id': 'abc'},
      };

      final response = ApiResponse<dynamic>.fromJson(
        json,
        (j) => (j as Map<String, dynamic>)['id'],
      );

      expect(response.success, isTrue);
      expect(response.body, 'abc');
      expect(response.error, isNull);
    });

    test('should parse null body when success is true', () {
      final json = <String, dynamic>{'success': true, 'body': null};

      final response = ApiResponse<dynamic>.fromJson(json, (j) => j);

      expect(response.success, isTrue);
      expect(response.body, isNull);
      expect(response.error, isNull);
    });
  });

  group('ApiResponse - error parsing', () {
    test('should parse typed error body into an ApiException', () {
      final json = <String, dynamic>{
        'success': false,
        'body': {'statusCode': 400, 'code': AppConstants.errorCodeOtpInvalid, 'message': 'invalid'},
      };

      final response = ApiResponse<dynamic>.fromJson(json, (j) => j);

      expect(response.success, isFalse);
      expect(response.error, isA<ApiException>());
      expect(response.error!.code, AppConstants.errorCodeOtpInvalid);
      expect(response.error!.statusCode, 400);
    });

    test('should gracefully handle a non-map error body', () {
      final json = <String, dynamic>{'success': false, 'body': 'Some raw string error'};

      final response = ApiResponse<dynamic>.fromJson(json, (j) => j);

      expect(response.success, isFalse);
      expect(response.error, isNotNull);
      expect(response.error!.type, ApiErrorType.unknown);
      expect(response.error!.message, 'Some raw string error');
    });

    test('should gracefully handle a null error body', () {
      final json = <String, dynamic>{'success': false, 'body': null};

      final response = ApiResponse<dynamic>.fromJson(json, (j) => j);

      expect(response.success, isFalse);
      expect(response.error, isNotNull);
      expect(response.error!.type, ApiErrorType.unknown);
    });
  });
}
