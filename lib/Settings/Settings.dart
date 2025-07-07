import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../HoneyWell Plugin/code_format.dart';
import '../HoneyWell Plugin/honeywell_scanner.dart';
import '../HoneyWell Plugin/scanned_data.dart';
import '../HoneyWell Plugin/scanner_callback.dart';
import '../Scanner Provider/scanner_provider.dart';
import '../utils/constants.dart';

class SettingsPage extends ConsumerStatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    implements ScannerCallback {
  int activeIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Scanner logic
  HoneywellScanner honeywellScanner = HoneywellScanner();
  ScannedData? scannedData;
  String? errorMessage;
  bool scannerEnabled = false;
  bool scan1DFormats = true;
  bool scan2DFormats = true;
  bool isDeviceSupported = false;

  @override
  void initState() {
    super.initState();
    honeywellScanner.setScannerCallback(this);
    initScanner();
  }

  Future<void> initScanner() async {
    updateScanProperties();
    isDeviceSupported = await honeywellScanner.isSupported();
    setState(() {});
  }

  void updateScanProperties() {
    List<CodeFormat> codeFormats = [];
    if (scan1DFormats) codeFormats.addAll(CodeFormatUtils.ALL_1D_FORMATS);
    if (scan2DFormats) codeFormats.addAll(CodeFormatUtils.ALL_2D_FORMATS);

    Map<String, dynamic> properties = {
      ...CodeFormatUtils.getAsPropertiesComplement(codeFormats),
      'DEC_CODABAR_START_STOP_TRANSMIT': true,
      'DEC_EAN13_CHECK_DIGIT_TRANSMIT': true,
    };
    honeywellScanner.setProperties(properties);
  }

  Future<void> toggleScanner(bool enable) async {
    errorMessage = null;
    try {
      if (enable) {
        await honeywellScanner.startScanner();
      } else {
        await honeywellScanner.stopScanner();
      }
      setState(() => scannerEnabled = enable);
    } catch (e) {
      errorMessage = e.toString();
      setState(() {});
    }
  }

  @override
  void onDecoded(ScannedData? data) {
    setState(() => scannedData = data);
  }

  @override
  void onError(Exception error) {
    setState(() => errorMessage = error.toString());
  }

  @override
  void dispose() {
    honeywellScanner.disposeScanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scannerEnabled = ref.watch(scannerEnabledProvider);
    final scan1D = ref.watch(scan1DProvider);
    final scan2D = ref.watch(scan2DProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: BlueColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 80.0),
              children: [
                _buildTileContainer(
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Device Supported:',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        Text(
                          isDeviceSupported ? 'Yes' : 'No',
                          style: TextStyle(
                            color:
                            isDeviceSupported ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildTileContainer(
                  child: SwitchListTile(
                    activeColor: BlueColor,
                    inactiveThumbColor: Colors.red,
                    title: const Text("Scanner",
                        style: TextStyle(fontSize: 16, color: Colors.black)),
                    subtitle: Text(
                        scannerEnabled ? "Started" : "Stopped",
                        style: const TextStyle(fontSize: 14)),
                    value: scannerEnabled,
                    onChanged: (value) async {
                      ref.read(scannerEnabledProvider.notifier).state = value;
                      final scanner = ref.read(scannerProvider);
                      try {
                        if (value) {
                          await scanner.startScanner();
                        } else {
                          await scanner.stopScanner();
                        }
                      } catch (e) {
                        ref
                            .read(scannerErrorProvider.notifier)
                            .state = e.toString();
                      }
                    },
                  ),
                ),
                _buildTileContainer(
                  child: SwitchListTile(
                    activeColor: BlueColor,
                    inactiveThumbColor: Colors.red,
                    title: const Text("Scan 2D",
                        style: TextStyle(fontSize: 16, color: Colors.black)),
                    subtitle: const Text("GS1 Data Matrix",
                        style: TextStyle(fontSize: 14)),
                    value: scan2D,
                    onChanged: (value) {
                      ref.read(scan2DProvider.notifier).state = value;
                      updateScanProperties();
                    },
                  ),
                ),
                // _buildTileContainer(
                //   child: SwitchListTile(
                //     activeColor: BlueColor,
                //     inactiveThumbColor: Colors.red,
                //     title: const Text("Scan 1D",
                //         style: TextStyle(fontSize: 16, color: Colors.black)),
                //     subtitle: const Text("Code-128, Code-39, etc.",
                //         style: TextStyle(fontSize: 14)),
                //     value: scan1D,
                //     onChanged: (value) {
                //       ref.read(scan1DProvider.notifier).state = value;
                //       updateScanProperties();
                //     },
                //   ),
                // ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Column(
              children: [
                Image.asset('assets/images/bg.png', height: 35),
                const SizedBox(height: 5),
                const Text(
                  'App Version 1.0.0(Beta)',
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTileContainer({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
      child: Container(
        padding: const EdgeInsets.all(0),
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
        child: child,
      ),
    );
  }
}
