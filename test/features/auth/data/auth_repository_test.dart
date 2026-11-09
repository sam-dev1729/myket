import 'package:flutter_test/flutter_test.dart';
import 'package:myket/core/network/api_exception.dart';
import 'package:myket/core/network/api_response.dart';
import 'package:myket/features/auth/data/auth_api.dart';
import 'package:myket/features/auth/data/auth_repository.dart';
import 'package:myket/features/auth/data/models/auth_models.dart';
import 'package:mocktail/mocktail.dart';

/// Mock of [AuthApi] used to test the repository in isolation.
class MockAuthApi extends Mock implements AuthApi {}

/// Fake registered as fallback value for `any()` matchers.
class FakeSendOtpRequest extends Fake implements SendOtpRequest {}

class FakeValidateOtpRequest extends Fake implements ValidateOtpRequest {}

class FakeRegisterPatientRequest extends Fake implements RegisterPatientRequest {}

class FakeGoogleLoginRequest extends Fake implements GoogleLoginRequest {}

void main() {
  late MockAuthApi mockApi;
  late AuthRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeSendOtpRequest());
    registerFallbackValue(FakeValidateOtpRequest());
    registerFallbackValue(FakeRegisterPatientRequest());
    registerFallbackValue(FakeGoogleLoginRequest());
  });

  setUp(() {
    mockApi = MockAuthApi();
    repository = AuthRepository(mockApi);
  });

  group('AuthRepository - sendOtp', () {
    test('should call API and return successfully', () async {
      when(
        () => mockApi.sendOtp(any()),
      ).thenAnswer((_) async => ApiResponse(success: true, body: null));

      await repository.sendOtp('09123456789');

      verify(() => mockApi.sendOtp(any())).called(1);
    });

    test('should throw ApiException on failure', () async {
      final error = ApiException(code: 'INVALID', message: 'Invalid phone');
      when(
        () => mockApi.sendOtp(any()),
      ).thenAnswer((_) async => ApiResponse(success: false, error: error));

      expect(() => repository.sendOtp('09123456789'), throwsA(isA<ApiException>()));
    });
  });

  group('AuthRepository - validateOtp', () {
    test('should return response for registered user', () async {
      final response = ValidateOtpResponse(
        isRegistered: true,
        accessToken: 'access',
        refreshToken: 'refresh',
        user: {'id': 'user-1'},
      );
      when(
        () => mockApi.validateOtp(any()),
      ).thenAnswer((_) async => ApiResponse(success: true, body: response));

      final result = await repository.validateOtp('09123456789', '12345');

      expect(result.isRegistered, true);
      expect(result.accessToken, 'access');
    });

    test('should return response for unregistered user', () async {
      final response = ValidateOtpResponse(isRegistered: false, registrationToken: 'reg-token');
      when(
        () => mockApi.validateOtp(any()),
      ).thenAnswer((_) async => ApiResponse(success: true, body: response));

      final result = await repository.validateOtp('09123456789', '12345');

      expect(result.isRegistered, false);
      expect(result.registrationToken, 'reg-token');
    });

    test('should throw ApiException on invalid OTP', () async {
      final error = ApiException(code: 'OTP_INVALID');
      when(
        () => mockApi.validateOtp(any()),
      ).thenAnswer((_) async => ApiResponse(success: false, error: error));

      expect(() => repository.validateOtp('09123456789', '00000'), throwsA(isA<ApiException>()));
    });
  });

  group('AuthRepository - registerPatient', () {
    test('should send all fields correctly', () async {
      final response = ValidateOtpResponse(
        isRegistered: true,
        accessToken: 'access',
        refreshToken: 'refresh',
      );
      when(
        () => mockApi.registerPatient(any()),
      ).thenAnswer((_) async => ApiResponse(success: true, body: response));

      await repository.registerPatient(
        'reg-token',
        '09123456789',
        'سام',
        'محمدی',
        birthDate: '1990-01-15',
        isMale: true,
      );

      final captured =
          verify(() => mockApi.registerPatient(captureAny())).captured.single
              as RegisterPatientRequest;

      expect(captured.registrationToken, 'reg-token');
      expect(captured.mobile, '09123456789');
      expect(captured.firstName, 'سام');
      expect(captured.lastName, 'محمدی');
      expect(captured.birthDate, '1990-01-15');
      expect(captured.isMale, true);
    });

    test('should handle optional fields as null', () async {
      final response = ValidateOtpResponse(
        isRegistered: true,
        accessToken: 'access',
        refreshToken: 'refresh',
      );
      when(
        () => mockApi.registerPatient(any()),
      ).thenAnswer((_) async => ApiResponse(success: true, body: response));

      await repository.registerPatient('reg-token', '09123456789', 'Sam', 'Smith');

      final captured =
          verify(() => mockApi.registerPatient(captureAny())).captured.single
              as RegisterPatientRequest;

      expect(captured.birthDate, isNull);
      expect(captured.isMale, isNull);
    });
  });

  group('AuthRepository - loginWithGoogle', () {
    test('should send Google credentials and return response', () async {
      final response = ValidateOtpResponse(
        isRegistered: true,
        accessToken: 'access',
        refreshToken: 'refresh',
      );
      when(
        () => mockApi.loginWithGoogle(any()),
      ).thenAnswer((_) async => ApiResponse(success: true, body: response));

      final result = await repository.loginWithGoogle('google-open-id', 'user@gmail.com');

      expect(result.isRegistered, true);

      final captured =
          verify(() => mockApi.loginWithGoogle(captureAny())).captured.single as GoogleLoginRequest;

      expect(captured.googleOpenId, 'google-open-id');
      expect(captured.googleEmail, 'user@gmail.com');
    });
  });
}
