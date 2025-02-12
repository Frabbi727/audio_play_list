import 'dart:io';

import 'package:audio_player/documnet_scanner/documnet_scanner_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

class DocumentScannerView extends GetView<DocumentScannerController> {
  DocumentScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OCR '),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                return controller.isLoading.value
                    ? CircularProgressIndicator()
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.extractedName.value,
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      controller.extractedDateOfBirth.value,
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      controller.extractedIdNo.value,
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                );
              }),
              SizedBox(height: 20),
              InkWell(
                  onTap: () async {
                    debugPrint("Button Pressed");
                    // showDialog(
                    //   context: context,
                    //   builder: (BuildContext context) {
                    //     return AlertDialog(
                    //       content: _uploadNidFrontPhotoCard(),
                    //     );
                    //   },
                    // );
                    controller.getNidFrontImageFromCamera();
                  },
                  child: Obx((){
                    return ((controller.nidFrontImagePath.value.isEmpty)||(controller.imageIsNotClear.value))?Container(
                      height: 150,
                      width: Get.width,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(image:AssetImage("assets/images/id-card.png",),fit: BoxFit.contain)
                      ),


                    ):Container(
                      height: 150,
                      color: Colors.grey[200],
                      padding: EdgeInsets.only(top: 5,bottom: 5),
                      alignment: Alignment.center,
                      child:   Image.file(
                        File(controller.nidFrontImagePath.value),
                        // width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    );
                  })
              ),

              SizedBox(height: 20),
              InkWell(
                  onTap: () async {
                  controller.getNidBackImageFromCamera();
                  },
                  child: Obx((){
                    return controller.nidBackImagePath.value.isEmpty?Container(
                      height: 150,
                      width: Get.width,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(image:AssetImage("assets/images/credit-card.png",),fit: BoxFit.contain)
                      ),

                    ):Container(
                      height: 150,
                      padding: EdgeInsets.only(top: 5,bottom: 5),
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child:   Image.file(
                        File(controller.nidBackImagePath.value),
                        // width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    );
                  })
              ),

            ],
          ),
        ),
      ),
    );
  }


}


