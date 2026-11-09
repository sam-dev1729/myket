import 'package:flutter_test/flutter_test.dart';
import 'package:myket/core/network/api_exception.dart';
import 'package:myket/core/network/api_response.dart';
import 'package:myket/features/lab_test/data/lab_test_api.dart';
import 'package:myket/features/lab_test/data/lab_test_repository.dart';
import 'package:myket/features/lab_test/data/models/lab_test_models.dart';
import 'package:mocktail/mocktail.dart';

/// Mock of [LabTestApi] used to test the repository in isolation.
class MockLabTestApi extends Mock implements LabTestApi {}

/// Fake registered as fallback value for `any()` matchers.
class FakeExtractLabTestRequest extends Fake implements ExtractLabTestRequest {}

/// Fake registered as fallback value for `any()` matchers.
class FakeCreateLabTestRequest extends Fake implements CreateLabTestRequest {}

void main() {
  late MockLabTestApi mockApi;
  late LabTestRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeExtractLabTestRequest());
    registerFallbackValue(FakeCreateLabTestRequest());
    // An empty list of the exact type is a valid fallback for
    // `List<ExtractedCategory>` and compiles on every mocktail version.
    registerFallbackValue(<ExtractedCategory>[]);
  });

  setUp(() {
    mockApi = MockLabTestApi();
    repository = LabTestRepository(mockApi);
  });

  group('LabTestRepository - getLabTests', () {
    test('should return a list of lab tests on success', () async {
      final labTests = [
        const LabTestHeader(
          id: 'test-1',
          testDate: '2024-12-13',
          doctorName: 'Dr. Smith',
          labName: 'Central Lab',
        ),
      ];
      when(
        () => mockApi.getLabTests(),
      ).thenAnswer((_) async => ApiResponse(success: true, body: labTests));

      final result = await repository.getLabTests();

      expect(result.length, 1);
      expect(result.first.id, 'test-1');
      expect(result.first.labName, 'Central Lab');
      verify(() => mockApi.getLabTests()).called(1);
    });

    test('should throw ApiException on failure', () async {
      final error = ApiException(code: 'INTERNAL_SERVER_ERROR', message: 'Server error');
      when(
        () => mockApi.getLabTests(),
      ).thenAnswer((_) async => ApiResponse(success: false, error: error));

      expect(() => repository.getLabTests(), throwsA(isA<ApiException>()));
    });
  });

  group('LabTestRepository - saveLabTest', () {
    test('should call createLabTest and saveLabTestTree on success', () async {
      final extractedData = ExtractedLabTest(
        testDate: '2024-12-13',
        doctorName: 'Dr. Smith',
        labName: 'Central Lab',
        categories: [
          ExtractedCategory(
            name: 'CBC',
            parameters: [ExtractedParameter(name: 'WBC', value: '12000', unit: '#/ml')],
          ),
        ],
      );
      final fileIds = ['file-123'];
      final createdResponse = const CreatedLabTestResponse(id: 'lab-test-123');

      when(
        () => mockApi.createLabTest(any()),
      ).thenAnswer((_) async => ApiResponse(success: true, body: createdResponse));

      when(
        () => mockApi.saveLabTestTree(any(), any()),
      ).thenAnswer((_) async => ApiResponse(success: true, body: null));

      await repository.saveLabTest(fileIds, extractedData);

      verify(() => mockApi.createLabTest(any())).called(1);
      verify(() => mockApi.saveLabTestTree('lab-test-123', any())).called(1);
    });

    test('should throw ApiException if createLabTest fails', () async {
      final extractedData = const ExtractedLabTest(testDate: '2024-12-13');
      final fileIds = ['file-123'];
      final error = ApiException(code: 'INVALID_FILE_SOURCE');

      when(
        () => mockApi.createLabTest(any()),
      ).thenAnswer((_) async => ApiResponse(success: false, error: error));

      expect(() => repository.saveLabTest(fileIds, extractedData), throwsA(isA<ApiException>()));
      verifyNever(() => mockApi.saveLabTestTree(any(), any()));
    });
  });
}
