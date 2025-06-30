import 'dart:io';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../HoneyWell Plugin/code_format.dart';
import '../HoneyWell Plugin/honeywell_scanner.dart';
import '../HoneyWell Plugin/scanned_data.dart';
import '../HoneyWell Plugin/scanner_callback.dart';
import '../Scanner Provider/scanner_provider.dart';
import '../utils/constants.dart';
import '../widgets/Item_Grid.dart';
import 'login.dart';

class HomePage extends ConsumerStatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> implements ScannerCallback {
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

  // Future<void> _logout(BuildContext context) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.clear();
  //   Navigator.pushAndRemoveUntil(
  //     context,
  //     MaterialPageRoute(builder: (context) => Login()),
  //         (route) => false,
  //   );
  // }

  Future<bool?> _showExitConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit the app?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                exit(0);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    honeywellScanner.disposeScanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _showExitConfirmationDialog(context);
        return shouldExit ?? false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: BlueColor,
          leading: Padding(
            padding: const EdgeInsets.all(12.0),
            child: GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Image.asset("assets/images/chevron.png"),
                ),
              ),
            ),
          ),
          title: const Text(
            "Chevron TNT",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Image.asset(
                'assets/images/logout.png',
                height: 34,
                width: 34,
              ),
              onPressed: () => _showExitConfirmationDialog,
            ),
          ],
        ),
        backgroundColor: BlueColor,
        drawer: Drawer(
          backgroundColor: Colors.white,
          width: MediaQuery.of(context).size.width * 0.71,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: const Color(0xFF4183B2),
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Image.asset('assets/images/chevron.png', height: 50),
                    const SizedBox(height: 10),
                    const Text('Chevron TNT',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      'Device Supported:',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      isDeviceSupported ? 'Yes' : 'No',
                      style: TextStyle(
                        color: isDeviceSupported ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              SwitchListTile(
                activeColor: BlueColor,
                inactiveThumbColor: Colors.red,
                title: const Text("Scanner", style: TextStyle(fontSize: 16, color: Colors.black),),
                subtitle: Text(ref.watch(scannerEnabledProvider) ? "Started" : "Stopped", style: const TextStyle(fontSize: 14),),
                value: ref.watch(scannerEnabledProvider),
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
                    ref.read(scannerErrorProvider.notifier).state = e.toString();
                  }
                },
              ),
              // SwitchListTile(
              //   activeColor: BlueColor,
              //   inactiveThumbColor: Colors.red,
              //   title: const Text("Scan 1D", style: TextStyle(fontSize: 16, color: Colors.black),),
              //   subtitle: const Text("Code-128", style: TextStyle(fontSize: 14),),
              //   value: ref.watch(scan1DProvider),
              //   onChanged: (value) {
              //     ref.read(scan1DProvider.notifier).state = value;
              //   },
              // ),
              SwitchListTile(
                activeColor: BlueColor,
                inactiveThumbColor: Colors.red,
                title: const Text("Scan 2D", style: TextStyle(fontSize: 16, color: Colors.black),),
                subtitle: const Text("Gs1 Data Matrix", style: TextStyle(fontSize: 14),),
                value: ref.watch(scan2DProvider),
                onChanged: (value) {
                  ref.read(scan2DProvider.notifier).state = value;
                },
              ),
              const Spacer(),
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
        ),
        body: Stack(
          children: [
            Positioned(
              right: 0.0,
              top: -20.0,
              child: Opacity(
                opacity: 0.8,
                child: Image.asset("assets/images/bk.png"),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Welcome Back,\n",
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                            TextSpan(
                              text: "Chevron!",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                            )
                          ],
                        ),
                      ),
                      Image.asset("assets/images/user.png", height: 50, width: 50),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Constants.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                    ),
                    child: const SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16.0, top: 10.0, bottom: 16),
                            child: Text(
                              "Select Options",
                              style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w800,
                                color: Color.fromRGBO(19, 22, 33, 1),
                              ),
                            ),
                          ),
                          SizedBox(height: 0),
                          ItemGrid(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}