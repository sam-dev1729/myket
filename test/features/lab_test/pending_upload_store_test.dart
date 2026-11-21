import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:myket/features/lab_test/data/file_repository.dart';
import 'package:myket/features/lab_test/data/pending_upload_store.dart';

void main() {
  late Directory tempDir;
  late Directory storageDir;
  late File source;
  late PendingUploadStore store;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pending_upload_source');
    storageDir = await Directory.systemTemp.createTemp('pending_upload_storage');
    source = File('${tempDir.path}/report.pdf');
    await source.writeAsBytes(List<int>.generate(12, (index) => index));
    store = PendingUploadStore(directoryProvider: () async => storageDir);
  });

  tearDown(() async {
    for (final directory in [tempDir, storageDir]) {
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    }
  });

  test('stages a copy of the file and reloads it', () async {
    final staged = await store.stageFile(source);

    expect(staged, isNotNull);
    expect(staged!.originalName, 'report.pdf');
    expect(File(staged.filePath).existsSync(), isTrue);
    expect(await File(staged.filePath).length(), 12);

    final loaded = await store.load();
    expect(loaded?.filePath, staged.filePath);
    expect(loaded?.uploadId, isNull);
  });

  test('persists the session received bytes for resume', () async {
    await store.stageFile(source);
    await store.saveSession(
      const FileUploadSession(
        uploadId: 'upload-1',
        chunkSize: 4,
        totalSize: 12,
        receivedBytes: 8,
        expiresAt: '2030-01-01T00:00:00Z',
      ),
    );

    final loaded = await store.load();
    expect(loaded?.uploadId, 'upload-1');
    expect(loaded?.receivedBytes, 8);
    expect(loaded?.toSession()?.progress, closeTo(0.666, 0.01));
  });

  test('clear removes the copied file and metadata', () async {
    final staged = await store.stageFile(source);
    await store.clear();

    expect(File(staged!.filePath).existsSync(), isFalse);
    expect(await store.load(), isNull);
  });
}
