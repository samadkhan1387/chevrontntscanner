import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';  // Import intl for date formatting
import '../DBHelper/DBhelper.dart';
import '../GS1 Barcode Parser/barcode_parser.dart';
import '../HoneyWell Plugin/code_format.dart';
import '../HoneyWell Plugin/scanned_data.dart';
import '../HoneyWell Plugin/scanner_callback.dart';
import '../Scanner Provider/scanner_provider.dart';
import '../utils/constants.dart';

class ScanDataMatrixData extends ConsumerStatefulWidget {
  const ScanDataMatrixData({super.key});

  @override
  ConsumerState<ScanDataMatrixData> createState() => _ScanDataMatrixPushDataState();
}

class _ScanDataMatrixPushDataState extends ConsumerState<ScanDataMatrixData> with WidgetsBindingObserver implements ScannerCallback {
  List<Map<String, String>> parsedBarcodeData = [];


  // Add aiDescriptions map for human-readable keys
  final Map<String, String> aiDescriptions = {
    '10': 'Batch No',
    '21': 'Serial No',
    '11': 'Prod Date',
    '91': 'PName',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final scanner = ref.read(scannerProvider);
    scanner.setScannerCallback(this);
    applyScannerSettings();
  }


  void applyScannerSettings() {
    final scanner = ref.read(scannerProvider);
    final scan2D = ref.read(scan2DProvider);

    List<CodeFormat> formats = [];
    if (scan2D) formats.addAll(CodeFormatUtils.ALL_2D_FORMATS);

    scanner.setProperties({
      ...CodeFormatUtils.getAsPropertiesComplement(formats),
      'DEC_CODABAR_START_STOP_TRANSMIT': true,
      'DEC_EAN13_CHECK_DIGIT_TRANSMIT': true,
    });
  }

  Future<void> onDecoded(ScannedData? data) async {
    if (data != null) {
      final barcode = data.code;
      // final barcodeType = data.codeType; // Get the barcode type
      //
      // // Check if barcode type is DataMatrix
      // if (barcodeType != 'DataMatrix') {
      //   _showSnackBar('Invalid barcode type. Please scan a DataMatrix barcode.', const Color(0xFFED1C24));
      //   return;
      // }
      // Check if the barcode has already been scanned
      bool isAlreadyScanned = parsedBarcodeData.any((element) => element['rawBarcode'] == barcode);
      if (isAlreadyScanned) {
        _showSnackBar('This Barcode has Already Been Scanned.', RedColor);
        return; // Exit the function if the barcode is already scanned
      }

      try {
        final parser = GS1BarcodeParser.defaultParser();
        final parsedData = parser.parse(barcode!);

        print("Parsed Data: $parsedData");

        // Convert parsed data to Map
        // Map<String, String> barcodeData = {};
        // parsedData.elements.forEach((key, element) {
        //   barcodeData[key] = element.data.toString();
        // });
        // barcodeData['rawBarcode'] = barcode;

        Map<String, String> barcodeData = {};
        parsedData.elements.forEach((key, element) {
          if (key == '11') {
            // Format GS1 AI 11 (Production Date) to yyyy-MM-dd
            DateTime parsedDate = element.data;
            barcodeData[key] = parsedDate.toIso8601String().split('T').first; // '2025-07-02'
          } else {
            barcodeData[key] = element.data.toString();
          }
        });
        barcodeData['rawBarcode'] = barcode;


        // Check if the required fields are available
        if (barcodeData.containsKey('10') &&
            barcodeData.containsKey('21') &&
            barcodeData.containsKey('11') &&
            barcodeData.containsKey('91')) {

          // Save to local ListView
          setState(() {
            parsedBarcodeData.insert(0, barcodeData);
          });

          // Save to SQLite database
          // Insert into DB and get sid
          final dbHelper = BarcodeDatabaseHelper();
          int sid = await dbHelper.insertBarcode(barcodeData);
          // Retrieve inserted record
          final savedRecord = await dbHelper.getBarcodeById(sid);
          print('📦 Barcode Saved to DB: $savedRecord');

        } else {
          // If any required field is missing
          _showSnackBar('Missing Required Data Fields. Please Scan a Complete Barcode.', RedColor);
        }

        // Update scannedData provider
        ref.read(scannedDataProvider.notifier).state = data; // Update the provider with the decoded data
      } catch (e) {
        _showSnackBar('Failed to Parse Barcode', RedColor);
        print("Error parsing barcode: $e");
      }
    }
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
  void onError(Exception error) {
    ref.read(scannerErrorProvider.notifier).state = error.toString();
  }

  @override
  void dispose() {
    final scanner = ref.read(scannerProvider);
    scanner.stopScanning();
    scanner.disposeScanner();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final scanner = ref.read(scannerProvider);
    if (state == AppLifecycleState.resumed) {
      scanner.resumeScanner();
    } else {
      scanner.pauseScanner();
    }
  }

  // Function to format the date
  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    final scannedData = ref.watch(scannedDataProvider); // Get scanned data
    final errorMessage = ref.watch(scannerErrorProvider); // Get error message
    final isScannerEnabled = ref.watch(scannerEnabledProvider); // Check scanner status

    // Initial placeholder values if no data has been scanned
    final String scannedCode = scannedData?.code ?? 'Please Scan';
    final String scannedCodeType = scannedData?.codeType ?? 'Type Unknown';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: BlueColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("DataMatrix Scan", style: TextStyle(fontSize: 18, color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Center(
              child: Text(
                '${parsedBarcodeData.length}',  // Display the count of scanned barcodes
                style: const TextStyle(fontSize: 16, color: Colors.white, ),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // === Status Container ===
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 05.0),
            child: Container(
              padding: const EdgeInsets.all(05),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade800),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 1,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Scanner Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Scanner Status :', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text(isScannerEnabled ? 'Active' : 'InActive', style: TextStyle(color: isScannerEnabled ? Colors.green : RedColor, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Code Type :', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text(scannedCodeType, style: const TextStyle(color: RedColor, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 05.0, bottom: 05.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(05),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade800),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 1,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Scanned Code:', style: TextStyle( fontSize: 12, color:Colors.black, fontWeight: FontWeight.bold)),
                  Text(scannedCode, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          // === Error Message ===
          if (errorMessage != null)
            Text('Error: $errorMessage', textAlign: TextAlign.center, style: const TextStyle(color: RedColor, fontWeight: FontWeight.bold)),

          // === Parsed Data ListView ===
          // === Parsed Data ListView ===
          Expanded(
            child: parsedBarcodeData.isEmpty
            // Show "No barcode scanned yet" message and icon when the list is empty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/NoBarcode.png', // Replace with your actual image path
                    width: 80, // You can adjust the size as needed
                    height: 80,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No Barcode Scanned Yet',
                    style: TextStyle(fontSize: 14,color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
            // Display the ListView when there are items in the list
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
                                "Scanned Barcode",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: Colors.black,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.black),
                                onPressed: () {
                                  setState(() {
                                    parsedBarcodeData.removeAt(index); // Remove item on cross click
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        // Display each key and its description using aiDescriptions map
                        for (var key in barcodeData.keys)
                          if (key != 'rawBarcode')
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 0),
                              child: Row(
                                children: [
                                  // Description on the left side
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      aiDescriptions[key] ?? key,
                                      style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),
                                    ),
                                  ),

                                  // Data on the right side, formatted if date
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      key == '11' // Assuming '11' is the Prod Date field (Production Date)
                                          ? formatDate(DateTime.parse(barcodeData[key]!))
                                          : barcodeData[key] ?? 'N/A',
                                      style: const TextStyle(fontSize: 13, color: Colors.black),
                                      overflow: TextOverflow.visible, // Handle overflow
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
                onPressed: () async {
                  final scanner = ref.read(scannerProvider);
                  await scanner.startScanning();
                },
                label: const Text("Start Scanning"),
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
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final scanner = ref.read(scannerProvider);
                  await scanner.stopScanning();
                },
                label: const Text("Stop Scanning"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RedColor,
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