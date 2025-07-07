import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import '../utils/constants.dart';

class IPPortconfig extends StatefulWidget {
  const IPPortconfig({Key? key}) : super(key: key);

  @override
  _IPPortconfigPageState createState() => _IPPortconfigPageState();
}

class _IPPortconfigPageState extends State<IPPortconfig> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController ipController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController deviceIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString('ipAddress') ?? '';
    String port = prefs.getString('port') ?? '';
    setState(() {
      ipController.text = ip;
      portController.text = port;
    });
  }

  Future<void> _saveConfiguration() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('ipAddress', ipController.text);
      await prefs.setString('port', portController.text);
      print("Saved IP Address: ${ipController.text}");
      print("Saved Port: ${portController.text}");
      _showSnackBar('Configuration Saved! IP: ${ipController.text}, Port: ${portController.text}', Colors.green);
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('IP Port Configuration', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: BlueColor,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white), // Set back icon color to white
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('IP Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: ipController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: "IP Address",
                  prefixIcon: const Icon(Icons.wifi, size: 20, color: Colors.black),
                  filled: true,
                  fillColor: Colors.blueGrey.withOpacity(.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  errorStyle: const TextStyle(color: Colors.red),
                ),
                cursorColor: Colors.red, // Red cursor
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter IP Address';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('Port Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: portController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: "Port Address",
                  prefixIcon: const Icon(Icons.dns, size: 20, color: Colors.black),
                  filled: true,
                  fillColor: Colors.blueGrey.withOpacity(.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  errorStyle: const TextStyle(color: Colors.red),
                ),
                cursorColor: Colors.red, // Red cursor
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter Port Address';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveConfiguration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BlueColor,
                    fixedSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Save Configuration',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}