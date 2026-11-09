import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../data/file_repository.dart';
import '../data/lab_test_repository.dart';
import '../data/models/lab_test_models.dart';
import 'health_overview_provider.dart';
import 'lab_test_list_controller.dart';

/// Represents the steps of uploading and extracting a lab test.
enum LabTestProcessStatus { initial, uploading, extracting, success, saving, saveSuccess, error }

/// State model for [LabTestController].
class LabTestProcessState {
  final LabTestProcessStatus status;
  final double uploadProgress;
  final ExtractedLabTest? extractedData;
  final String? errorMessage;
  final String? savedFileId;

  const LabTestProcessState({
    this.status = LabTestProcessStatus.initial,
    this.uploadProgress = 0.0,
    this.extractedData,
    this.errorMessage,
    this.savedFileId,
  });

  LabTestProcessState copyWith({
    LabTestProcessStatus? status,
    double? uploadProgress,
    ExtractedLabTest? extractedData,
    String? errorMessage,
    String? savedFileId,
  }) {
    return LabTestProcessState(
      status: status ?? this.status,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      extractedData: extractedData ?? this.extractedData,
      errorMessage: errorMessage ?? this.errorMessage,
      savedFileId: savedFileId ?? this.savedFileId,
    );
  }
}

/// Controller that manages the upload, extraction, and saving of lab tests.
class LabTestController extends Notifier<LabTestProcessState> {
  @override
  LabTestProcessState build() {
    return const LabTestProcessState();
  }

  /// Starts the process of uploading a file and extracting its data.
  Future<void> processFile(File file) async {
    state = const LabTestProcessState(status: LabTestProcessStatus.uploading);

    try {
      final fileResponse = await ref
          .read(fileRepositoryProvider)
          .uploadFile(
            file,
            onProgress: (progress) {
              state = state.copyWith(uploadProgress: progress);
            },
          );

      state = state.copyWith(status: LabTestProcessStatus.extracting, savedFileId: fileResponse.id);
      final extractedData = await ref.read(labTestRepositoryProvider).extractLabTest([
        fileResponse.id,
      ]);

      state = state.copyWith(status: LabTestProcessStatus.success, extractedData: extractedData);
    } on ApiException catch (e) {
      state = state.copyWith(status: LabTestProcessStatus.error, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(status: LabTestProcessStatus.error, errorMessage: e.toString());
    }
  }

  /// Saves the extracted lab test to the backend.
  ///
  /// On success, invalidates the lab-test list and the health overview so the
  /// downstream tabs (Blood Test list + Health Record) reflect the new test
  /// without a manual refresh.
  Future<void> saveLabTest() async {
    final fileId = state.savedFileId;
    final data = state.extractedData;
    if (fileId == null || data == null) return;

    state = state.copyWith(status: LabTestProcessStatus.saving);

    try {
      await ref.read(labTestRepositoryProvider).saveLabTest([fileId], data);
      state = state.copyWith(status: LabTestProcessStatus.saveSuccess);

      // New lab test was persisted — refresh the list and the health overview.
      ref.invalidate(labTestListControllerProvider);
      ref.invalidate(healthOverviewProvider);
    } on ApiException catch (e) {
      state = state.copyWith(status: LabTestProcessStatus.error, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(status: LabTestProcessStatus.error, errorMessage: e.toString());
    }
  }

  /// Resets the state to initial.
  void reset() {
    state = const LabTestProcessState();
  }
}

/// Riverpod provider for [LabTestController].
final labTestControllerProvider = NotifierProvider<LabTestController, LabTestProcessState>(() {
  return LabTestController();
});