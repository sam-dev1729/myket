import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myket/core/network/api_exception.dart';
import 'package:myket/features/lab_test/data/file_repository.dart';
import 'package:myket/features/lab_test/data/lab_test_repository.dart';
import 'package:myket/features/lab_test/data/models/file_models.dart';
import 'package:myket/features/lab_test/data/models/lab_test_models.dart';
import 'package:myket/features/lab_test/data/pending_upload_store.dart';
import 'package:myket/features/lab_test/presentation/lab_test_controller.dart';
import 'package:myket/features/lab_test/presentation/lab_test_draft.dart';

void main() {
  late Directory tempDir;
  late File file;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('lab_controller_test');
    file = File('${tempDir.path}/report.pdf');
    await file.writeAsBytes(List<int>.generate(8, (index) => index));
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  ProviderContainer createContainer(
    _FakeFileRepository fileRepository,
    _FakeLabTestRepository labTestRepository, {
    _FakePendingUploadStore? pendingStore,
  }) {
    return ProviderContainer(
      overrides: [
        fileRepositoryProvider.overrideWithValue(fileRepository),
        labTestRepositoryProvider.overrideWithValue(labTestRepository),
        pendingUploadStoreProvider.overrideWithValue(
          pendingStore ?? _FakePendingUploadStore(),
        ),
      ],
    );
  }

  test('selectFile keeps the file without uploading', () async {
    final container = createContainer(_FakeFileRepository(), _FakeLabTestRepository());
    addTearDown(container.dispose);

    await container.read(labTestControllerProvider.notifier).selectFile(file);

    final state = container.read(labTestControllerProvider);
    expect(state.status, LabTestProcessStatus.fileSelected);
    expect(state.selectedFile, same(file));
  });

  test('analysis failure keeps the file and retries without re-uploading', () async {
    final fileRepository = _FakeFileRepository();
    final labRepository = _FakeLabTestRepository()..failFirstExtract = true;
    final container = createContainer(fileRepository, labRepository);
    addTearDown(container.dispose);

    final controller = container.read(labTestControllerProvider.notifier);
    await controller.selectFile(file);
    await controller.startUpload();

    var state = container.read(labTestControllerProvider);
    expect(state.status, LabTestProcessStatus.error);
    expect(state.errorStage, LabTestErrorStage.analysis);
    expect(state.selectedFile, same(file));
    expect(state.savedFileId, 'file-1');
    expect(fileRepository.uploadCalls, 1);

    await controller.retry();

    state = container.read(labTestControllerProvider);
    expect(state.status, LabTestProcessStatus.success);
    expect(fileRepository.uploadCalls, 1);
    expect(labRepository.extractCalls, 2);
  });

  test('upload failure keeps the session and resumes on retry', () async {
    final fileRepository = _FakeFileRepository()..failFirstUpload = true;
    final labRepository = _FakeLabTestRepository();
    final container = createContainer(fileRepository, labRepository);
    addTearDown(container.dispose);

    final controller = container.read(labTestControllerProvider.notifier);
    await controller.selectFile(file);
    await controller.startUpload();

    var state = container.read(labTestControllerProvider);
    expect(state.status, LabTestProcessStatus.error);
    expect(state.errorStage, LabTestErrorStage.upload);
    expect(state.selectedFile, same(file));
    expect(state.uploadSession, isNotNull);

    await controller.retry();

    state = container.read(labTestControllerProvider);
    expect(state.status, LabTestProcessStatus.success);
    expect(fileRepository.uploadCalls, 2);
    expect(fileRepository.lastResumeFrom, isNotNull);
  });

  test('reset clears the selected file and session', () async {
    final container = createContainer(_FakeFileRepository(), _FakeLabTestRepository());
    addTearDown(container.dispose);

    final controller = container.read(labTestControllerProvider.notifier);
    await controller.selectFile(file);
    controller.reset();

    final state = container.read(labTestControllerProvider);
    expect(state.status, LabTestProcessStatus.initial);
    expect(state.selectedFile, isNull);
    expect(state.uploadSession, isNull);
  });

  test('saves the edited draft instead of the raw extraction', () async {
    final fileRepository = _FakeFileRepository();
    final labRepository = _FakeLabTestRepository();
    final container = createContainer(fileRepository, labRepository);
    addTearDown(container.dispose);

    final controller = container.read(labTestControllerProvider.notifier);
    await controller.selectFile(file);
    await controller.startUpload();

    controller.updateDraft(
      const LabTestDraft(
        testDate: '2024-05-20',
        doctorName: 'Dr. Edited',
        labName: 'Edited Lab',
        labAddress: 'Edited Address',
        testNumber: '999',
        categories: [
          LabTestDraftCategory(
            name: 'Lipids',
            parameters: [
              LabTestDraftParameter(
                name: 'HDL',
                value: '60',
                unit: 'mg/dL',
                refMin: '40',
                refMax: '60',
              ),
            ],
          ),
        ],
      ),
    );

    await controller.saveLabTest();

    expect(container.read(labTestControllerProvider).status, LabTestProcessStatus.saveSuccess);
    final saved = labRepository.lastSavedData;
    expect(saved, isNotNull);
    expect(saved!.doctorName, 'Dr. Edited');
    expect(saved.labAddress, 'Edited Address');
    expect(saved.testNumber, '999');
    expect(saved.categories!.single.parameters!.single.name, 'HDL');
  });

  test('retrying a failed save reuses the created test id', () async {
    final fileRepository = _FakeFileRepository();
    final labRepository = _FakeLabTestRepository()..failFirstSave = true;
    final container = createContainer(fileRepository, labRepository);
    addTearDown(container.dispose);

    final controller = container.read(labTestControllerProvider.notifier);
    await controller.selectFile(file);
    await controller.startUpload();

    await controller.saveLabTest();
    var state = container.read(labTestControllerProvider);
    expect(state.status, LabTestProcessStatus.error);
    expect(state.errorStage, LabTestErrorStage.save);
    expect(state.createdTestId, 'test-1');

    await controller.retry();

    state = container.read(labTestControllerProvider);
    expect(state.status, LabTestProcessStatus.saveSuccess);
    expect(labRepository.saveCalls, 2);
    expect(labRepository.lastExistingTestId, 'test-1');
  });

  test('restores a pending upload and its resume position', () async {
    final pendingStore = _FakePendingUploadStore()
      ..pending = PendingUploadData(
        originalName: 'report.pdf',
        filePath: file.path,
        uploadId: 'upload-1',
        chunkSize: 4,
        totalSize: 8,
        receivedBytes: 4,
      );
    final container = createContainer(
      _FakeFileRepository(),
      _FakeLabTestRepository(),
      pendingStore: pendingStore,
    );
    addTearDown(container.dispose);

    final restored = await container
        .read(labTestControllerProvider.notifier)
        .restorePendingUpload();

    final state = container.read(labTestControllerProvider);
    expect(restored, isTrue);
    expect(state.status, LabTestProcessStatus.fileSelected);
    expect(state.selectedFile?.path, file.path);
    expect(state.uploadSession?.receivedBytes, 4);
    expect(state.uploadProgress, 0.5);
  });
}

/// Fake [FileRepository] used by the controller tests.
class _FakeFileRepository implements FileRepository {
  bool failFirstUpload = false;
  int uploadCalls = 0;
  FileUploadSession? lastResumeFrom;

  @override
  Future<FileResponse> uploadFile(
    File file, {
    FileUploadSession? resumeFrom,
    void Function(double progress)? onProgress,
    void Function(int attempt, int maxAttempts)? onAttempt,
    void Function(FileUploadSession session)? onSession,
  }) async {
    uploadCalls++;
    lastResumeFrom = resumeFrom;
    final session = resumeFrom ??
        const FileUploadSession(
          uploadId: 'upload-1',
          chunkSize: 4,
          totalSize: 8,
          receivedBytes: 0,
        );
    onSession?.call(session);
    if (failFirstUpload && uploadCalls == 1) {
      throw ApiException(message: 'upload failed', type: ApiErrorType.noInternet);
    }
    onProgress?.call(1);
    return const FileResponse(
      id: 'file-1',
      url: 'https://mock.local/file-1.pdf',
      originalName: 'report.pdf',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake [LabTestRepository] used by the controller tests.
class _FakeLabTestRepository implements LabTestRepository {
  bool failFirstExtract = false;
  bool failFirstSave = false;
  int extractCalls = 0;
  int saveCalls = 0;
  ExtractedLabTest? lastSavedData;
  String? lastExistingTestId;

  @override
  Future<ExtractedLabTest> extractLabTest(List<String> fileIds) async {
    extractCalls++;
    if (failFirstExtract && extractCalls == 1) {
      throw ApiException(message: 'analysis failed', type: ApiErrorType.server);
    }
    return const ExtractedLabTest();
  }

  @override
  Future<void> saveLabTest(
    List<String> fileIds,
    ExtractedLabTest extractedData, {
    String? existingTestId,
    void Function(String id)? onTestCreated,
  }) async {
    saveCalls++;
    lastSavedData = extractedData;
    lastExistingTestId = existingTestId;
    if (existingTestId == null) onTestCreated?.call('test-1');
    if (failFirstSave && saveCalls == 1) {
      throw ApiException(message: 'save failed', type: ApiErrorType.server);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake [PendingUploadStore] that keeps the pending upload in memory.
class _FakePendingUploadStore implements PendingUploadStore {
  PendingUploadData? pending;
  bool cleared = false;
  int stageCalls = 0;

  @override
  Future<PendingUploadData?> stageFile(File source) async {
    stageCalls++;
    pending = PendingUploadData(
      originalName: source.path.split(Platform.pathSeparator).last,
      filePath: source.path,
    );
    return pending;
  }

  @override
  Future<void> saveSession(FileUploadSession session) async {
    final current = pending;
    if (current == null) return;
    pending = PendingUploadData(
      originalName: current.originalName,
      filePath: current.filePath,
      uploadId: session.uploadId,
      chunkSize: session.chunkSize,
      totalSize: session.totalSize,
      receivedBytes: session.receivedBytes,
      expiresAt: session.expiresAt,
    );
  }

  @override
  Future<PendingUploadData?> load() async => pending;

  @override
  Future<void> clear() async {
    cleared = true;
    pending = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
