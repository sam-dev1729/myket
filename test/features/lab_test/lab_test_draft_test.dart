import 'package:flutter_test/flutter_test.dart';
import 'package:myket/features/lab_test/data/models/lab_test_models.dart';
import 'package:myket/features/lab_test/presentation/lab_test_draft.dart';

void main() {
  test('converts extracted data to a draft and back without losing values', () {
    const extracted = ExtractedLabTest(
      testDate: '2024-05-20',
      doctorName: 'Dr. Smith',
      labName: 'Central Lab',
      labAddress: 'Tehran',
      testNumber: '123',
      categories: [
        ExtractedCategory(
          name: 'Blood Sugar',
          parameters: [
            ExtractedParameter(
              name: 'Glucose',
              value: '95',
              unit: 'mg/dL',
              refMin: '70',
              refMax: '100',
              flag: 'H',
            ),
          ],
        ),
      ],
    );

    final draft = LabTestDraft.fromExtracted(extracted);
    expect(draft.testDate, '2024-05-20');
    expect(draft.categories.single.name, 'Blood Sugar');
    expect(draft.categories.single.parameters.single.value, '95');

    final roundTrip = draft.toExtractedLabTest();
    expect(roundTrip.testDate, '2024-05-20');
    expect(roundTrip.doctorName, 'Dr. Smith');
    expect(roundTrip.labAddress, 'Tehran');
    expect(roundTrip.testNumber, '123');
    expect(roundTrip.categories!.single.name, 'Blood Sugar');
    expect(roundTrip.categories!.single.parameters!.single.refMax, '100');
    expect(roundTrip.categories!.single.parameters!.single.sortOrder, 0);
  });

  test('edits to a draft are reflected in the saved payload', () {
    final draft = LabTestDraft.fromExtracted(const ExtractedLabTest()).copyForTest();

    final payload = draft.toExtractedLabTest();

    expect(payload.doctorName, 'Dr. New');
    expect(payload.categories!.single.parameters!.single.name, 'HDL');
    expect(payload.categories!.single.parameters!.single.value, '60');
  });
}

/// Small helper that mutates a copy of the empty draft, mirroring what the
/// editor does.
extension on LabTestDraft {
  LabTestDraft copyForTest() {
    return LabTestDraft(
      doctorName: 'Dr. New',
      categories: const [
        LabTestDraftCategory(
          name: 'Lipids',
          parameters: [
            LabTestDraftParameter(name: 'HDL', value: '60', unit: 'mg/dL'),
          ],
        ),
      ],
    );
  }
}
