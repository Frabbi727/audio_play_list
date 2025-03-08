import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'dart:io';

class FileDownloadService extends GetxService {
  final RxInt downloadProgress = 0.obs;
  final Rx<DownloadTaskStatus> currentStatus = DownloadTaskStatus.undefined.obs;
  final RxString currentTaskId = ''.obs;

  Future<FileDownloadService> init() async {
    print("FileDownloadService initialized via GetX Service.");
    return this;
  }

  Future<String?> downloadFile(String url, String savedDir, String fileName) async {
    try {
      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: savedDir,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );
      currentTaskId.value = taskId ?? '';
      print('Download started: $taskId');
      return taskId;
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }

  Future<void> pauseDownload() async {
    if (currentTaskId.value.isNotEmpty) {
      await FlutterDownloader.pause(taskId: currentTaskId.value);
      print('Download paused: ${currentTaskId.value}');
    }
  }

  Future<void> resumeDownload() async {
    if (currentTaskId.value.isNotEmpty) {
      await FlutterDownloader.resume(taskId: currentTaskId.value);
      print('Download resumed: ${currentTaskId.value}');
    }
  }

  Future<void> cancelDownload() async {
    if (currentTaskId.value.isNotEmpty) {
      await FlutterDownloader.cancel(taskId: currentTaskId.value);
      print('Download canceled: ${currentTaskId.value}');
      currentTaskId.value = '';
      downloadProgress.value = 0;
      currentStatus.value = DownloadTaskStatus.undefined;
    }
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final service = Get.find<FileDownloadService>();
    if (service.currentTaskId.value == id) {
      service.currentStatus.value = status;
      service.downloadProgress.value = progress;
    }
    print('TaskId: $id, Status: $status, Progress: $progress%');
  }

  Future<bool> isDownloaded(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }
}
