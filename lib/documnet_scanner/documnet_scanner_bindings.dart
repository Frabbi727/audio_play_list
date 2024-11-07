import 'package:get/get.dart';

import 'documnet_scanner_controller.dart';

class DocumnetScannerBindings extends Bindings{
  @override
  void dependencies() {
   Get.put(DocumentScannerController());
  }
  
}