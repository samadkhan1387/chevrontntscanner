import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../DBHelper/DBhelper.dart';
import '../utils/constants.dart';

class ExcelGeneration extends ConsumerStatefulWidget {
  const ExcelGeneration({super.key});

  @override
  ConsumerState<ExcelGeneration> createState() => _ExcelGenerationState();
}

class _ExcelGenerationState extends ConsumerState<ExcelGeneration> {
  final dbHelper = BarcodeDatabaseHelper();
  List<Map<String, dynamic>> parsedBarcodeData = [];
  String? selectedProduct;
  String? selectedBatch;
  String? selectedDate;
  bool filtersApplied = false;

  final Map<String, String> fieldLabels = {
    'productName': 'P Name',
    'productionDate': 'Prod Date',
    'batchNumber': 'Batch No',
    'serialNumber': 'Serial No',
  };

  final List<String> fieldOrder = [
    'productName',
    'batchNumber',
    'productionDate',
    'serialNumber',
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> applyFilters() async {
    final all = await dbHelper.getAllBarcodes();
    setState(() {
      filtersApplied = true;
      parsedBarcodeData = all.where((entry) {
        final productMatch = selectedProduct == null || entry['productName'] == selectedProduct;
        final batchMatch = selectedBatch == null || entry['batchNumber'] == selectedBatch;
        final dateMatch = selectedDate == null || entry['productionDate'] == selectedDate;
        return productMatch && batchMatch && dateMatch;
      }).toList();
    });
  }

  Widget _styledDropdown({
    required String label,
    required List<String> options,
    required String? selectedValue,
    required void Function(String?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(.1),
        borderRadius: BorderRadius.circular(10),
        // border: Border.all(color: Colors.grey.shade600),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(label, style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.bold)),
          value: selectedValue,
          isExpanded: true,
          dropdownColor: Colors.white,
          items: options.map((e) => DropdownMenuItem(value: e, child: Text(e,style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
              ),))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Future<void> saveAllDataInExcel() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      _showSnackBar('Storage Permission Denied', RedColor);
      return;
    }

    // 🔁 Fetch all data directly here instead of using `parsedBarcodeData`
    final allData = await dbHelper.getAllBarcodes();

    if (allData.isEmpty) {
      _showSnackBar('No Data Found to Export', RedColor);
      return;
    }

    var excel = Excel.createExcel();
    final sheetName = excel.getDefaultSheet();
    final sheet = excel[sheetName ?? 'Sheet1'];

    // Add headers
    sheet.appendRow(fieldOrder.map((k) => fieldLabels[k] ?? k).toList());

    // Add all data rows
    for (var data in allData) {
      sheet.appendRow(fieldOrder.map((k) => data[k]?.toString() ?? '').toList());
    }

    // Get Downloads directory
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
    } else {
      directory = await getDownloadsDirectory();
    }

    final now = DateTime.now();
    final timestamp = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}";
    final fileName = 'AllScannedData_$timestamp.xlsx';
    final filePath = '${directory!.path}/$fileName';

    final fileBytes = excel.encode();
    if (fileBytes == null) return;

    final file = File(filePath);
    await file.writeAsBytes(fileBytes, flush: true);

    _showSnackBar('Excel saved to Downloads: $fileName', Colors.green);
  }


  Future<void> generateExcelFile() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      _showSnackBar('Storage Permission Denied', RedColor);
      return;
    }

    // Create a new Excel file and use the default (main) sheet
    var excel = Excel.createExcel();
    final sheetName = excel.getDefaultSheet(); // get main/default sheet name
    final sheet = excel[sheetName ?? 'Sheet1'];

    // Add headers
    sheet.appendRow(fieldOrder.map((k) => fieldLabels[k] ?? k).toList());

    // Add filtered data rows
    for (var data in parsedBarcodeData) {
      sheet.appendRow(fieldOrder.map((k) => data[k]?.toString() ?? '').toList());
    }

    // Get Downloads directory
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
    } else {
      directory = await getDownloadsDirectory(); // fallback for iOS/macOS
    }

    // Create filename with filters and datetime
    final now = DateTime.now();
    final timestamp = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}";

    final filterSuffix = [
      selectedProduct ?? '',
      selectedBatch ?? '',
      selectedDate ?? ''
    ].where((e) => e.isNotEmpty).join('_');

    final fileName = 'ScannedBarcodes-${filterSuffix.isEmpty ? 'All' : filterSuffix}_$timestamp.xlsx';
    final filePath = '${directory!.path}/$fileName';

    // Save Excel file
    final fileBytes = excel.encode();
    if (fileBytes == null) return;

    final file = File(filePath);
    await file.writeAsBytes(fileBytes, flush: true);

    _showSnackBar('Excel saved to Downloads: $fileName', Colors.green);
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
          "Save Scanned Data",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.getAllBarcodes(),
        builder: (context, snapshot) {
          final allBarcodes = snapshot.data ?? [];

          final products = allBarcodes.map((e) => e['productName']).whereType<String>().toSet().toList();
          final batches = allBarcodes.map((e) => e['batchNumber']).whereType<String>().toSet().toList();
          final dates = allBarcodes.map((e) => e['productionDate']).whereType<String>().toSet().toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _styledDropdown(
                label: 'By Product',
                options: products,
                selectedValue: selectedProduct,
                onChanged: (val) {
                  selectedProduct = val;
                  applyFilters();
                },
              ),
              _styledDropdown(
                label: 'By Batch',
                options: batches,
                selectedValue: selectedBatch,
                onChanged: (val) {
                  selectedBatch = val;
                  applyFilters();
                },
              ),
              _styledDropdown(
                label: 'By Date',
                options: dates,
                selectedValue: selectedDate,
                onChanged: (val) {
                  selectedDate = val;
                  applyFilters();
                },
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                child: Text(
                  'Filtered Data',
                  style: TextStyle(fontSize: 15,color: RedColor, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: !filtersApplied
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/NoBarcode.png', // Replace with your actual image path
                        width: 60, // You can adjust the size as needed
                        height: 60,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Please Apply a Filter to View Data',
                        style: TextStyle(fontSize: 14,color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
                    : parsedBarcodeData.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/NoBarcode.png', // Replace with your actual image path
                        width: 60, // You can adjust the size as needed
                        height: 60,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'No Barcode Scanned Data Found',
                        style: TextStyle(fontSize: 14,color: Colors.black, fontWeight: FontWeight.bold),
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
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          // border: Border.all(color: Colors.grey.shade800),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.01),
                              blurRadius: 1,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
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
                                    "Saved Barcode",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.qr_code, color: Colors.black),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                            for (var key in fieldOrder)
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 5.0, right: 5.0, bottom: 2),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        fieldLabels[key] ?? key,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Text(
                                        barcodeData[key]?.toString() ?? 'N/A',
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
          );
        },

      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 1, offset: const Offset(0, 0)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: generateExcelFile,
                label: const Text("Generate Excel"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Set the border radius to 5
                  ),
                ),
              ),
            ),
            const SizedBox(width: 08),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: saveAllDataInExcel,
                label: const Text("Save All Data In Excel"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BlueColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Set the border radius to 5
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
