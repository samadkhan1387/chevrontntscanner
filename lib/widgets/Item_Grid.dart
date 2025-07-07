import 'package:flutter/material.dart';
import '../BarcodeDataPush/PushExcelGeneration.dart';
import '../BarcodeDataPush/PushScannedData.dart';
import '../BarcodeDataPush/ScanDataMatrixPushData_Screen.dart';
import '../ExcelGeneration/ExcelGeneration.dart';
import '../SavedScannedData/ScannedData.dart';
import '../Settings/Settings.dart';
import '../models/Items.dart';

class ItemGrid extends StatelessWidget {
  final String selectedOrder; // This is the parameter passed to the grid

  const ItemGrid({super.key, required this.selectedOrder});

  @override
  Widget build(BuildContext context) {
    List<Item> items = [
      Item(
        name: "Scanner",
        type: "DataMatrix",
        color: const Color.fromRGBO(231, 76, 60, 1),
        imagePath: "assets/images/chevron.png",
      ),
      Item(
        name: "All Data",
        type: "Scanned Data",
        color: const Color.fromRGBO(237, 116, 41, 1),
        imagePath: "assets/images/chevron.png",
      ),
      Item(
        name: "Excel",
        type: "Download",
        color: const Color.fromRGBO(34, 153, 84, 1),
        imagePath: "assets/images/chevron.png",
      ),
      // Item(
      //   name: "Print Labels",
      //   type: "Label",
      //   color: const Color.fromRGBO(52, 73, 94, 1),
      //   imagePath: "assets/images/chevron.png",
      // ),
      // Item(
      //   name: "Scan Barcode",
      //   type: "Scanner",
      //   color: const Color.fromRGBO(89, 69, 199, 1),
      //   imagePath: "assets/images/chevron.png",
      // ),
      // Item(
      //   name: "Inventory Log",
      //   type: "Log",
      //   color: const Color.fromRGBO(155, 89, 182, 1),
      //   imagePath: "assets/images/chevron.png",
      // ),
      // Item(
      //   name: "Add Product",
      //   type: "Entry",
      //   color: const Color.fromRGBO(241, 196, 15, 1),
      //   imagePath: "assets/images/chevron.png",
      // ),
      Item(
        name: "Configuration",
        type: "Settings",
        color: const Color.fromRGBO(52, 152, 219, 1),
        imagePath: "assets/images/chevron.png",
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15.0,
          mainAxisSpacing: 15.0,
          childAspectRatio: 2.25,
        ),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              switch (items[index].name) {
                case "Scanner":
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ScanDataMatrixPushData( selectedOrder: selectedOrder!)));
                  break;
                case "All Data":
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PushScannedData()));
                  break;
                case "Excel":
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PushExcelGeneration()));
                  break;
                case "Configuration":
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
                  break;
                case "Scan Barcode":
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanBarcodePage()));
                  break;
                case "Inventory Log":
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => const InventoryLogPage()));
                  break;
                case "Add Product":
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductPage()));
                  break;
                case "Settings":
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                  break;
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: items[index].color,
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 05.0,
                horizontal: 10.0,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Positioned(
                  //   right: 0.0,
                  //   top: 0.0,
                  //   child: Opacity(
                  //     opacity: 1,
                  //     child: Image.asset(
                  //       items[index].imagePath,
                  //       width: 40,
                  //     ),
                  //   ),
                  // ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${items[index].type}\n",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            fontSize: 17.0,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: items[index].name,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
