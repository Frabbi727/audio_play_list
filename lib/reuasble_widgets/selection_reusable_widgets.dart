import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectableListWidget<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T) titleExtractor;
  final String Function(T) countExtractor;
  final Function(T) onItemSelected;

  SelectableListWidget({
    required this.items,
    required this.titleExtractor,
    required this.countExtractor,
    required this.onItemSelected,
  });

  final SelectableListController<T> controller = Get.put(SelectableListController<T>());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Type", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Obx(() => GestureDetector(
                onTap: () {
                  controller.selectItem(item);
                  onItemSelected(item);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: controller.selectedItem.value == item ? Colors.blue.withOpacity(0.2) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: controller.selectedItem.value == item ? Colors.blue : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // ekane chnage koren icon er jonne
                          Icon(
                            controller.selectedItem.value == item
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: controller.selectedItem.value == item ? Colors.blue : Colors.grey,
                          ),
                          SizedBox(width: 10),
                          Text(titleExtractor(item), style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      // ekhane update koren left side er data dekhite
                      CircleAvatar(
                        backgroundColor: Colors.black54,
                        radius: 14,
                        child: Text(
                          countExtractor(item),
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      )
                    ],
                  ),
                ),
              ));
            },
          ),
        ),
      ],
    );
  }
}


class SelectableListController<T> extends GetxController {
  var selectedItem = Rxn<T>();

  void selectItem(T item) {
    selectedItem.value = item;
  }
}