import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class DownloadManager extends StatefulWidget {
  @override
  _DownloadManagerState createState() => _DownloadManagerState();
}

class _DownloadManagerState extends State<DownloadManager> {
  String? _taskId;
  int _progress = 0;

  Future<void> startDownload(String url) async {
    final directory = await getExternalStorageDirectory();
    _taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: directory!.path,
      showNotification: true,
      openFileFromNotification: true,
    );
  }

  void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    if (id == _taskId) {
      setState(() {
        _progress = progress;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    //FlutterDownloader.registerCallback(downloadCallback as DownloadCallback);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Download Manager')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Download Progress: $_progress%'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await startDownload('https://example.com/file.pdf');
                },
                child: Text('Start Download'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_taskId != null) await FlutterDownloader.pause(taskId: _taskId!);
                },
                child: Text('Pause'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_taskId != null) await FlutterDownloader.resume(taskId: _taskId!);
                },
                child: Text('Resume'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_taskId != null) await FlutterDownloader.cancel(taskId: _taskId!);
                },
                child: Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}