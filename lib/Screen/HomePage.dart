import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../HoneyWell Plugin/code_format.dart';
import '../HoneyWell Plugin/honeywell_scanner.dart';
import '../HoneyWell Plugin/scanned_data.dart';
import '../HoneyWell Plugin/scanner_callback.dart';
import '../IPPort/IPPort.dart';
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

  HoneywellScanner honeywellScanner = HoneywellScanner();
  ScannedData? scannedData;
  String? errorMessage;
  bool scannerEnabled = false;
  bool scan1DFormats = true;
  bool scan2DFormats = true;
  bool isDeviceSupported = false;

  String? selectedOrder;
  List<String> orderNumbers = [];
  Timer? orderRefreshTimer;

  @override
  void initState() {
    super.initState();
    honeywellScanner.setScannerCallback(this);
    initScanner();
    fetchOrderNumbers();

    orderRefreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      fetchOrderNumbers();
    });
  }

  Future<void> fetchOrderNumbers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ip = prefs.getString('ipAddress');
    String? port = prefs.getString('port');

    try {
      final response = await http.get(Uri.parse('http://$ip:$port/ordernumbers'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<String> fetchedOrders = data.cast<String>();

        if (!listEquals(orderNumbers, fetchedOrders)) {
          setState(() {
            orderNumbers = fetchedOrders;
          });
        }
      }
    } catch (_) {
      // Silent fail
    }
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
    orderRefreshTimer?.cancel();
    super.dispose();
  }

  Widget _buildOrderDropdown(List<String> orders) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedOrder,
          hint: const Text("Select Purchase Order"),
          dropdownColor: Colors.white,
          items: orders.isNotEmpty
              ? orders.map((order) {
            return DropdownMenuItem<String>(
              value: order,
              child: Text(order),
            );
          }).toList()
              : [
            const DropdownMenuItem<String>(
              value: null,
              child: Text("No Purchase Orders Available"),
            )
          ],
          onChanged: orders.isNotEmpty
              ? (String? newValue) {
            setState(() {
              selectedOrder = newValue;
            });
          }
              : null,
          icon: const Icon(Icons.arrow_drop_down, color: BlueColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        exit(0);
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: BlueColor,
          leading: Padding(
            padding: const EdgeInsets.all(12.0),
            child: GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const IPPortconfig()));
              },
            ),
          ],
        ),
        backgroundColor: BlueColor,
        body: Stack(
          children: [
            Positioned(
              right: 0.0,
              top: -20.0,
              child: Opacity(
                opacity: 0.5,
                child: Image.asset("assets/images/bk.png"),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
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
                              text: "Chevron",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                            )
                          ],
                        ),
                      ),
                      Image.asset("assets/images/user.png", height: 60, width: 60),
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
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10),
                            child: Text(
                              "Select Purchase Order",
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w800,
                                color: Color.fromRGBO(19, 22, 33, 1),
                              ),
                            ),
                          ),
                          _buildOrderDropdown(orderNumbers),
                          const Padding(
                            padding: EdgeInsets.only(left: 20.0, top: 10.0, bottom: 16),
                            child: Text(
                              "Select Options",
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w800,
                                color: Color.fromRGBO(19, 22, 33, 1),
                              ),
                            ),
                          ),
                          ItemGrid(selectedOrder: selectedOrder ?? ''),
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
