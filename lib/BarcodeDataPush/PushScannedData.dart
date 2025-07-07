import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../DBHelper/DBhelper.dart'; // Make sure this import path is correct

class PushScannedData extends ConsumerStatefulWidget {
  const PushScannedData({super.key});

  @override
  ConsumerState<PushScannedData> createState() => _ScannedDataScreenState();
}

class _ScannedDataScreenState extends ConsumerState<PushScannedData> {
  List<Map<String, String>> parsedBarcodeData = [];

  final Map<String, String> aiDescriptions = {
    '91': 'P Name',
    '11': 'Prod Date',
    '10': 'Batch No',
    '21': 'Serial No',
  };

  @override
  void initState() {
    super.initState();
    loadPushedBarcodes();
  }


  Future<void> loadPushedBarcodes() async {
    final dbHelper = BarcodeDatabaseHelper();
    final pushedBarcodes = await dbHelper.getAllPushedBarcodes();

    setState(() {
      parsedBarcodeData = pushedBarcodes.map<Map<String, String>>((barcode) {
        return {
          'pid': barcode['pid'].toString(),
          'Pur Order': barcode['purchaseOrder'] ?? '',
          '91': barcode['productName'] ?? '',
          '10': barcode['batchNumber'] ?? '',
          '11': barcode['productionDate'] ?? '',
          '21': barcode['serialNumber'] ?? '',
          'rawBarcode': barcode['rawBarcode'] ?? '',
        };
      }).toList();
    });
  }




  void _showSnackBar(String message, Color color) {
    final snackBar = SnackBar(
      content: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 1),
      margin: const EdgeInsets.only(left: 05, bottom : 05, right: 05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BlueColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "All Scanned Data",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 05.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(09),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade800),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Scanned Barcodes :',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${parsedBarcodeData.length}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: RedColor),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: parsedBarcodeData.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/NoBarcode.png',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No Barcode Scanned Data Yet',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              itemCount: parsedBarcodeData.length,
              itemBuilder: (context, index) {
                final barcodeData = parsedBarcodeData[index];
                return Padding(
                  padding:
                  const EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 5.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade800),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.01),
                          blurRadius: 1,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding:
                          const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: const BoxDecoration(
                            color: BlueColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(9.0),
                              topRight: Radius.circular(9.0),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                "Scanned Barcode",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: Colors.black,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.black),
                                onPressed: () async {
                                  final pid = int.tryParse(barcodeData['pid'] ?? '');
                                  if (pid != null) {
                                    final dbHelper = BarcodeDatabaseHelper();
                                    await dbHelper.deletepushdataById(pid);

                                    setState(() {
                                      parsedBarcodeData.removeAt(index);
                                    });
                                    _showSnackBar('Deleted Barcode Successfully', RedColor);
                                  }
                                },

                              ),
                            ],
                          ),
                        ),
                        for (var key in barcodeData.keys)
                          if (key != 'rawBarcode' && key != 'pid')
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 5.0, right: 5.0, bottom: 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      aiDescriptions[key] ?? key,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      barcodeData[key] ?? 'N/A',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black),
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
