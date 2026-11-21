import '../data/models/lab_test_models.dart';

/// Editable in-memory draft of a lab test produced by AI extraction.
///
/// The draft is what the review screen edits; [toExtractedLabTest] converts it
/// back to the API model used by the save endpoint.
class LabTestDraft {
  const LabTestDraft({
    this.testDate,
    this.doctorName,
    this.labName,
    this.labAddress,
    this.testNumber,
    this.categories = const [],
  });

  final String? testDate;
  final String? doctorName;
  final String? labName;
  final String? labAddress;
  final String? testNumber;
  final List<LabTestDraftCategory> categories;

  /// Builds a draft from the AI extraction result.
  factory LabTestDraft.fromExtracted(ExtractedLabTest? data) {
    if (data == null) return const LabTestDraft();
    return LabTestDraft(
      testDate: data.testDate,
      doctorName: data.doctorName,
      labName: data.labName,
      labAddress: data.labAddress,
      testNumber: data.testNumber,
      categories: [
        for (final category in data.categories ?? const <ExtractedCategory>[])
          LabTestDraftCategory(
            name: category.name,
            parameters: [
              for (final parameter in category.parameters ?? const <ExtractedParameter>[])
                LabTestDraftParameter(
                  name: parameter.name,
                  value: parameter.value ?? '',
                  unit: parameter.unit,
                  refMin: parameter.refMin,
                  refMax: parameter.refMax,
                  flag: parameter.flag,
                ),
            ],
          ),
      ],
    );
  }

  /// Converts the edited draft back to the payload expected by
  /// `saveLabTest` (`POST /lab-test` + tree).
  ExtractedLabTest toExtractedLabTest() {
    return ExtractedLabTest(
      testDate: testDate,
      doctorName: doctorName,
      labName: labName,
      labAddress: labAddress,
      testNumber: testNumber,
      categories: [
        for (var categoryIndex = 0; categoryIndex < categories.length; categoryIndex++)
          ExtractedCategory(
            name: categories[categoryIndex].name,
            sortOrder: categoryIndex,
            parameters: [
              for (var parameterIndex = 0;
                  parameterIndex < categories[categoryIndex].parameters.length;
                  parameterIndex++)
                ExtractedParameter(
                  name: categories[categoryIndex].parameters[parameterIndex].name,
                  value: categories[categoryIndex].parameters[parameterIndex].value,
                  unit: categories[categoryIndex].parameters[parameterIndex].unit,
                  refMin: categories[categoryIndex].parameters[parameterIndex].refMin,
                  refMax: categories[categoryIndex].parameters[parameterIndex].refMax,
                  flag: categories[categoryIndex].parameters[parameterIndex].flag,
                  sortOrder: parameterIndex,
                ),
            ],
          ),
      ],
    );
  }
}

/// Editable category in a [LabTestDraft].
class LabTestDraftCategory {
  const LabTestDraftCategory({required this.name, this.parameters = const []});

  final String name;
  final List<LabTestDraftParameter> parameters;
}

/// Editable parameter in a [LabTestDraftCategory].
class LabTestDraftParameter {
  const LabTestDraftParameter({
    required this.name,
    required this.value,
    this.unit,
    this.refMin,
    this.refMax,
    this.flag,
  });

  final String name;
  final String value;
  final String? unit;
  final String? refMin;
  final String? refMax;
  final String? flag;
}
