import 'package:audio_player/audio_player/audio_bindings.dart';
import 'package:audio_player/documnet_scanner/documnet_scanner_bindings.dart';
import 'package:audio_player/play_list/audio_play_list_view.dart';
import 'package:audio_player/play_list/play_list_bindings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'audio_player/view_page.dart';
import 'documnet_scanner/document_scanner_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      getPages: [
        GetPage(
            name: "/",
            page: () => DocumentScannerView (),
            binding: DocumnetScannerBindings(),
        ),
      ],


    );
  }
}