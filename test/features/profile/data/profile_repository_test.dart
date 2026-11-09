import 'package:flutter_test/flutter_test.dart';
import 'package:myket/core/network/api_exception.dart';
import 'package:myket/core/network/api_response.dart';
import 'package:myket/features/profile/data/models/user_profile.dart';
import 'package:myket/features/profile/data/profile_api.dart';
import 'package:myket/features/profile/data/profile_repository.dart';
import 'package:mocktail/mocktail.dart';

/// Mock of [ProfileApi] used to test the repository in isolation.
class MockProfileApi extends Mock implements ProfileApi {}

void main() {
  late MockProfileApi mockApi;
  late ProfileRepository repository;

  setUp(() {
    mockApi = MockProfileApi();
    repository = ProfileRepository(mockApi);
  });

  group('ProfileRepository - getProfile', () {
    test('should return UserProfile on success', () async {
      final profile = UserProfile(
        id: 'user-1',
        mobile: '09123456789',
        firstName: 'سام',
        lastName: 'محمدی',
        birthDate: '1990-01-15',
        bloodType: 'A_POSITIVE',
      );
      when(
        () => mockApi.getProfile(),
      ).thenAnswer((_) async => ApiResponse(success: true, body: profile));

      final result = await repository.getProfile();

      expect(result.id, 'user-1');
      expect(result.mobile, '09123456789');
      expect(result.firstName, 'سام');
      expect(result.lastName, 'محمدی');
      expect(result.bloodType, 'A_POSITIVE');
    });

    test('should throw ApiException on failure', () async {
      final error = ApiException(code: 'UNAUTHORIZED', message: 'Invalid token');
      when(
        () => mockApi.getProfile(),
      ).thenAnswer((_) async => ApiResponse(success: false, error: error));

      expect(() => repository.getProfile(), throwsA(isA<ApiException>()));
    });
  });
}
