import 'package:audio_player/reuasble_widgets/selection_reusable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApplyLeaveScreen extends StatelessWidget {
  final List<LeaveType> leaveTypes = [
    LeaveType(title: "Casual", count: "41"),
    LeaveType(title: "Annual", count: "12"),
    LeaveType(title: "Annual", count: "12"),
    LeaveType(title: "Annual", count: "12"),
    LeaveType(title: "Annual", count: "12"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Apply For Leave")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SelectableListWidget<LeaveType>(
          items: leaveTypes,
          titleExtractor: (item) => item.title,
          countExtractor: (item) => item.count,
          onItemSelected: (selectedItem) {
            print("Selected: ${selectedItem.title}");
          },
        ),
      ),
    );
  }
}


class LeaveType {
  final String title;
  final String count;

  LeaveType({required this.title, required this.count});
}
