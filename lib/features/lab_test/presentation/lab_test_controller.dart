import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exception.dart';
import '../data/file_repository.dart';
import '../data/lab_test_repository.dart';
import '../data/models/lab_test_models.dart';
import '../data/pending_upload_store.dart';
import 'health_overview_provider.dart';
import 'lab_test_draft.dart';
import 'lab_test_list_controller.dart';

/// Represents the steps of uploading and extracting a lab test.
enum LabTestProcessStatus {
  initial,
  fileSelected,
  uploading,
  extracting,
  success,
  saving,
  saveSuccess,
  error,
}

/// Which step failed, so the UI can offer the right retry action.
enum LabTestErrorStage { upload, analysis, save }

/// State model for [LabTestController].
class LabTestProcessState {
  /// Current step.
  final LabTestProcessStatus status;

  /// File chosen by the user (kept across retries; cleared on reset).
  final File? selectedFile;

  /// Active/previous upload session (used to resume).
  final FileUploadSession? uploadSession;

  /// Real upload progress (received / total).
  final double uploadProgress;

  /// Attempt number of the current chunk retry.
  final int uploadAttempt;

  /// Maximum automatic attempts per chunk.
  final int maxUploadAttempts;

  /// Uploaded file id returned after a successful upload.
  final String? savedFileId;

  /// Id of a lab test created by a save attempt that did not finish, used to
  /// retry the save without creating a duplicate.
  final String? createdTestId;

  /// Extracted data after a successful AI analysis.
  final ExtractedLabTest? extractedData;

  /// Editable draft of the extracted data (edited before saving).
  final LabTestDraft? draft;

  /// Human-readable error message.
  final String? errorMessage;

  /// Step that failed.
  final LabTestErrorStage? errorStage;

  const LabTestProcessState({
    this.status = LabTestProcessStatus.initial,
    this.selectedFile,
    this.uploadSession,
    this.uploadProgress = 0.0,
    this.uploadAttempt = 0,
    this.maxUploadAttempts = AppConstants.maxUploadChunkRetries,
    this.savedFileId,
    this.createdTestId,
    this.extractedData,
    this.draft,
    this.errorMessage,
    this.errorStage,
  });

  /// Returns a copy while optionally clearing the error fields.
  LabTestProcessState copyWith({
    LabTestProcessStatus? status,
    File? selectedFile,
    FileUploadSession? uploadSession,
    double? uploadProgress,
    int? uploadAttempt,
    int? maxUploadAttempts,
    String? savedFileId,
    String? createdTestId,
    ExtractedLabTest? extractedData,
    LabTestDraft? draft,
    String? errorMessage,
    LabTestErrorStage? errorStage,
    bool clearError = false,
  }) {
    return LabTestProcessState(
      status: status ?? this.status,
      selectedFile: selectedFile ?? this.selectedFile,
      uploadSession: uploadSession ?? this.uploadSession,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      uploadAttempt: uploadAttempt ?? this.uploadAttempt,
      maxUploadAttempts: maxUploadAttempts ?? this.maxUploadAttempts,
      savedFileId: savedFileId ?? this.savedFileId,
      createdTestId: createdTestId ?? this.createdTestId,
      extractedData: extractedData ?? this.extractedData,
      draft: draft ?? this.draft,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorStage: clearError ? null : (errorStage ?? this.errorStage),
    );
  }
}

/// Controller that manages selecting, uploading, extracting and saving a
/// lab test. The selected file and upload session survive failed attempts so
/// retries can resume instead of asking the user to pick the file again.
class LabTestController extends Notifier<LabTestProcessState> {
  int _operationId = 0;
  Future<void> _pendingWriteQueue = Future<void>.value();

  @override
  LabTestProcessState build() {
    ref.onDispose(() => _operationId++);
    return const LabTestProcessState();
  }

  /// Stores the chosen file without uploading it yet and keeps a copy on disk
  /// so the upload can resume after an app restart.
  Future<void> selectFile(File file) async {
    final operationId = ++_operationId;
    state = LabTestProcessState(
      status: LabTestProcessStatus.fileSelected,
      selectedFile: file,
    );

    await _pendingWriteQueue;
    await ref.read(pendingUploadStoreProvider).stageFile(file);
    if (operationId != _operationId && state.status == LabTestProcessStatus.initial) {
      // The user left the screen while the copy was being staged.
      await ref.read(pendingUploadStoreProvider).clear();
    }
  }

  /// Loads a pending upload from disk (if any) and restores its state.
  ///
  /// Returns true when a pending file was found and restored.
  Future<bool> restorePendingUpload() async {
    final pending = await ref.read(pendingUploadStoreProvider).load();
    if (pending == null) return false;

    final file = File(pending.filePath);
    if (!await file.exists()) {
      await ref.read(pendingUploadStoreProvider).clear();
      return false;
    }

    var session = pending.toSession();
    if (session != null && session.isExpired) {
      session = null;
    }

    _operationId++;
    state = LabTestProcessState(
      status: LabTestProcessStatus.fileSelected,
      selectedFile: file,
      uploadSession: session,
      uploadProgress: session?.progress ?? 0,
    );
    return true;
  }

  /// Forgets the selected file and any upload session.
  ///
  /// Also deletes the on-disk pending upload unless [clearPending] is false.
  void reset({bool clearPending = true}) {
    _operationId++;
    state = const LabTestProcessState();
    if (clearPending) {
      unawaited(
        _pendingWriteQueue.then<void>((_) async {
          await ref.read(pendingUploadStoreProvider).clear();
        }),
      );
    }
  }

  /// Uploads the selected file (resuming if a session exists) and then runs
  /// the AI extraction.
  Future<void> startUpload() async {
    final file = state.selectedFile;
    if (file == null) return;

    final operationId = ++_operationId;
    state = state.copyWith(
      status: LabTestProcessStatus.uploading,
      uploadProgress: state.uploadSession?.progress ?? 0,
      uploadAttempt: 0,
      clearError: true,
    );

    try {
      final fileResponse = await ref
          .read(fileRepositoryProvider)
          .uploadFile(
            file,
            resumeFrom: state.uploadSession,
            onProgress: (progress) {
              if (operationId != _operationId) return;
              state = state.copyWith(uploadProgress: progress);
            },
            onAttempt: (attempt, maxAttempts) {
              if (operationId != _operationId) return;
              state = state.copyWith(
                uploadAttempt: attempt,
                maxUploadAttempts: maxAttempts,
              );
            },
            onSession: (session) {
              if (operationId != _operationId) return;
              state = state.copyWith(uploadSession: session);
              _persistSession(session);
            },
          );

      if (operationId != _operationId) return;
      state = state.copyWith(
        status: LabTestProcessStatus.extracting,
        savedFileId: fileResponse.id,
        uploadProgress: 1,
        clearError: true,
      );

      // The upload is complete; the copied file is no longer needed.
      await _pendingWriteQueue;
      await ref.read(pendingUploadStoreProvider).clear();

      await _extract(operationId);
    } on ApiException catch (e) {
      if (operationId != _operationId) return;
      state = state.copyWith(
        status: LabTestProcessStatus.error,
        errorStage: LabTestErrorStage.upload,
        errorMessage: e.message ?? e.toString(),
      );
    } catch (e) {
      if (operationId != _operationId) return;
      state = state.copyWith(
        status: LabTestProcessStatus.error,
        errorStage: LabTestErrorStage.upload,
        errorMessage: e.toString(),
      );
    }
  }

  /// Retries the failed step without clearing the selected file/session.
  Future<void> retry() async {
    switch (state.errorStage) {
      case LabTestErrorStage.upload:
        await startUpload();
        break;
      case LabTestErrorStage.analysis:
        await retryAnalysis();
        break;
      case LabTestErrorStage.save:
        await saveLabTest();
        break;
      case null:
        break;
    }
  }

  /// Re-runs only the AI extraction (no re-upload).
  Future<void> retryAnalysis() async {
    if (state.savedFileId == null) return;
    final operationId = ++_operationId;
    state = state.copyWith(
      status: LabTestProcessStatus.extracting,
      clearError: true,
    );
    await _extract(operationId);
  }

  Future<void> _extract(int operationId) async {
    final fileId = state.savedFileId;
    if (fileId == null) return;

    try {
      final extractedData = await ref
          .read(labTestRepositoryProvider)
          .extractLabTest([fileId]);
      if (operationId != _operationId) return;
      state = state.copyWith(
        status: LabTestProcessStatus.success,
        extractedData: extractedData,
        draft: LabTestDraft.fromExtracted(extractedData),
        clearError: true,
      );
    } on ApiException catch (e) {
      if (operationId != _operationId) return;
      state = state.copyWith(
        status: LabTestProcessStatus.error,
        errorStage: LabTestErrorStage.analysis,
        errorMessage: e.message ?? e.toString(),
      );
    } catch (e) {
      if (operationId != _operationId) return;
      state = state.copyWith(
        status: LabTestProcessStatus.error,
        errorStage: LabTestErrorStage.analysis,
        errorMessage: e.toString(),
      );
    }
  }

  /// Replaces the editable draft with [draft] (e.g. after an inline edit).
  void updateDraft(LabTestDraft draft) {
    state = state.copyWith(draft: draft);
  }

  /// Persists the upload session after init/each accepted chunk.
  void _persistSession(FileUploadSession session) {
    _pendingWriteQueue = _pendingWriteQueue
        .then<void>((_) async {
          await ref.read(pendingUploadStoreProvider).saveSession(session);
        })
        .catchError((Object _) {});
  }

  /// Saves the edited draft to the backend.
  ///
  /// On success, invalidates the lab-test list and the health overview so the
  /// downstream tabs (Blood Test list + Health Record) reflect the new test
  /// without a manual refresh.
  Future<void> saveLabTest() async {
    final fileId = state.savedFileId;
    final data = state.draft?.toExtractedLabTest() ?? state.extractedData;
    if (fileId == null || data == null) return;

    final operationId = ++_operationId;
    state = state.copyWith(status: LabTestProcessStatus.saving, clearError: true);

    try {
      await ref
          .read(labTestRepositoryProvider)
          .saveLabTest(
            [fileId],
            data,
            existingTestId: state.createdTestId,
            onTestCreated: (id) {
              if (operationId != _operationId) return;
              state = state.copyWith(createdTestId: id);
            },
          );
      if (operationId != _operationId) return;
      state = state.copyWith(status: LabTestProcessStatus.saveSuccess);

      ref.invalidate(labTestListControllerProvider);
      ref.invalidate(healthOverviewProvider);
    } on ApiException catch (e) {
      if (operationId != _operationId) return;
      state = state.copyWith(
        status: LabTestProcessStatus.error,
        errorStage: LabTestErrorStage.save,
        errorMessage: e.message ?? e.toString(),
      );
    } catch (e) {
      if (operationId != _operationId) return;
      state = state.copyWith(
        status: LabTestProcessStatus.error,
        errorStage: LabTestErrorStage.save,
        errorMessage: e.toString(),
      );
    }
  }
}

/// Riverpod provider for [LabTestController].
final labTestControllerProvider = NotifierProvider<LabTestController, LabTestProcessState>(() {
  return LabTestController();
});
