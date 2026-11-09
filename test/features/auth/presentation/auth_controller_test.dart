import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myket/core/constants/app_constants.dart';
import 'package:myket/core/network/api_exception.dart';
import 'package:myket/core/services/google_auth_service.dart';
import 'package:myket/core/storage/token_storage.dart';
import 'package:myket/features/auth/data/auth_repository.dart';
import 'package:myket/features/auth/data/models/auth_models.dart';
import 'package:myket/features/auth/presentation/auth_controller.dart';
import 'package:mocktail/mocktail.dart';

/// Mock of [AuthRepository] used to isolate the controller from networking.
class MockAuthRepository extends Mock implements AuthRepository {}

/// Mock of [TokenStorage] to avoid touching `flutter_secure_storage`.
class MockTokenStorage extends Mock implements TokenStorage {}

/// Mock of [GoogleAuthService] to control the Google Sign-In outcome.
class MockGoogleAuthService extends Mock implements GoogleAuthService {}

void main() {
  late MockAuthRepository mockRepository;
  late MockTokenStorage mockTokenStorage;
  late MockGoogleAuthService mockGoogleAuthService;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockAuthRepository();
    mockTokenStorage = MockTokenStorage();
    mockGoogleAuthService = MockGoogleAuthService();

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepository),
        tokenStorageProvider.overrideWithValue(mockTokenStorage),
        googleAuthServiceProvider.overrideWithValue(mockGoogleAuthService),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('AuthController - sendOtp', () {
    test('should set status to otpSent on success', () async {
      when(() => mockRepository.sendOtp(any())).thenAnswer((_) async {});

      await container.read(authControllerProvider.notifier).sendOtp('09123456789');

      expect(container.read(authControllerProvider).status, AuthStatus.otpSent);
    });

    test('should set timeout error on connection timeout', () async {
      when(() => mockRepository.sendOtp(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: AppConstants.sendOtpEndpoint),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      await container.read(authControllerProvider.notifier).sendOtp('09123456789');

      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.error);
      expect(state.error, AuthError.timeout);
    });

    test('should set noInternet error on connection error', () async {
      when(() => mockRepository.sendOtp(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: AppConstants.sendOtpEndpoint),
          type: DioExceptionType.connectionError,
        ),
      );

      await container.read(authControllerProvider.notifier).sendOtp('09123456789');

      expect(container.read(authControllerProvider).error, AuthError.noInternet);
    });
  });

  group('AuthController - verifyOtp', () {
    test('should save tokens and succeed for registered user', () async {
      when(() => mockRepository.validateOtp(any(), any())).thenAnswer(
        (_) async =>
            ValidateOtpResponse(isRegistered: true, accessToken: 'access', refreshToken: 'refresh'),
      );
      when(() => mockTokenStorage.saveTokens(any(), any())).thenAnswer((_) async {});

      await container.read(authControllerProvider.notifier).verifyOtp('09123456789', '12345');

      expect(container.read(authControllerProvider).status, AuthStatus.success);
      verify(() => mockTokenStorage.saveTokens('access', 'refresh')).called(1);
    });

    test('should set newUser for unregistered user', () async {
      when(() => mockRepository.validateOtp(any(), any())).thenAnswer(
        (_) async => ValidateOtpResponse(isRegistered: false, registrationToken: 'reg-token'),
      );

      await container.read(authControllerProvider.notifier).verifyOtp('09123456789', '12345');

      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.newUser);
      expect(state.registrationToken, 'reg-token');
    });

    test('should set invalidOtp on OTP_INVALID error', () async {
      when(
        () => mockRepository.validateOtp(any(), any()),
      ).thenThrow(ApiException(code: AppConstants.errorCodeOtpInvalid));

      await container.read(authControllerProvider.notifier).verifyOtp('09123456789', '00000');

      expect(container.read(authControllerProvider).error, AuthError.invalidOtp);
    });
  });

  group('AuthController - registerPatient', () {
    test('should save tokens and succeed', () async {
      when(() => mockRepository.validateOtp(any(), any())).thenAnswer(
        (_) async => ValidateOtpResponse(isRegistered: false, registrationToken: 'reg-token'),
      );
      when(
        () => mockRepository.registerPatient(
          any(),
          any(),
          any(),
          any(),
          birthDate: any(named: 'birthDate'),
          isMale: any(named: 'isMale'),
        ),
      ).thenAnswer(
        (_) async =>
            ValidateOtpResponse(isRegistered: true, accessToken: 'access', refreshToken: 'refresh'),
      );
      when(() => mockTokenStorage.saveTokens(any(), any())).thenAnswer((_) async {});

      final controller = container.read(authControllerProvider.notifier);
      await controller.verifyOtp('09123456789', '12345');
      await controller.registerPatient(
        '09123456789',
        'سام',
        'محمدی',
        birthDate: '1990-01-15',
        isMale: true,
      );

      expect(container.read(authControllerProvider).status, AuthStatus.success);
      verify(() => mockTokenStorage.saveTokens('access', 'refresh')).called(1);
    });

    test('should return early if no registration token', () async {
      await container
          .read(authControllerProvider.notifier)
          .registerPatient('09123456789', 'سام', 'محمدی');

      expect(container.read(authControllerProvider).status, AuthStatus.initial);
      verifyNever(
        () => mockRepository.registerPatient(
          any(),
          any(),
          any(),
          any(),
          birthDate: any(named: 'birthDate'),
          isMale: any(named: 'isMale'),
        ),
      );
    });
  });

  group('AuthController - loginWithGoogle', () {
    test('should succeed for existing Google user', () async {
      when(() => mockGoogleAuthService.signIn()).thenAnswer(
        (_) async => const GoogleAuthResult(openId: 'google-open-id', email: 'user@gmail.com'),
      );
      when(() => mockRepository.loginWithGoogle(any(), any())).thenAnswer(
        (_) async =>
            ValidateOtpResponse(isRegistered: true, accessToken: 'access', refreshToken: 'refresh'),
      );
      when(() => mockTokenStorage.saveTokens(any(), any())).thenAnswer((_) async {});

      await container.read(authControllerProvider.notifier).loginWithGoogle();

      expect(container.read(authControllerProvider).status, AuthStatus.success);
      verify(() => mockTokenStorage.saveTokens('access', 'refresh')).called(1);
    });

    test('should return to initial state when user cancels', () async {
      when(() => mockGoogleAuthService.signIn()).thenAnswer((_) async => null);

      await container.read(authControllerProvider.notifier).loginWithGoogle();

      expect(container.read(authControllerProvider).status, AuthStatus.initial);
      verifyNever(() => mockRepository.loginWithGoogle(any(), any()));
    });

    test('should set googleNeedsPhone for unlinked Google account', () async {
      when(() => mockGoogleAuthService.signIn()).thenAnswer(
        (_) async => const GoogleAuthResult(openId: 'google-open-id', email: 'new@gmail.com'),
      );
      // Per API: login-with-google for an unlinked account returns
      // `is_registered: false` without tokens — the user must first complete
      // OTP for a mobile number before registering.
      when(
        () => mockRepository.loginWithGoogle(any(), any()),
      ).thenAnswer((_) async => ValidateOtpResponse(isRegistered: false, registrationToken: null));

      await container.read(authControllerProvider.notifier).loginWithGoogle();

      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.googleNeedsPhone);
      expect(state.registrationToken, isNull);
    });
  });

  group('AuthController - logout', () {
    test('should clear tokens and reset state', () async {
      when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});
      // `logout()` also calls `GoogleAuthService.signOut()` — must be stubbed.
      when(() => mockGoogleAuthService.signOut()).thenAnswer((_) async {});

      await container.read(authControllerProvider.notifier).logout();

      expect(container.read(authControllerProvider).status, AuthStatus.initial);
      verify(() => mockTokenStorage.clearTokens()).called(1);
      verify(() => mockGoogleAuthService.signOut()).called(1);
    });
  });
}
