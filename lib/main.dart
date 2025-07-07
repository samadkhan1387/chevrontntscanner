import 'package:chevrontntscanner/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Screen/Welcome.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const ProviderScope(child: MyApp()));
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          title: 'Chevron TNT',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: BlueColor),
            useMaterial3: true,
          ),
          home: const Welcome(), // Start here directly
        );
      },
    );
  }
}


// bottomNavigationBar: Container(
// padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
// decoration: BoxDecoration(
// color: Colors.white,
// boxShadow: [
// BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 1, offset: const Offset(0, 0)),
// ],
// ),
// child: Row(
// mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// children: [
// Expanded(
// child: ElevatedButton.icon(
// onPressed: () async {
// final scanner = ref.read(scannerProvider);
// await scanner.startScanning();
// },
// label: const Text("Start Scanning"),
// style: ElevatedButton.styleFrom(
// backgroundColor: Colors.green,
// foregroundColor: Colors.white,
// padding: const EdgeInsets.symmetric(vertical: 12),
// shape: RoundedRectangleBorder(
// borderRadius: BorderRadius.circular(10), // Set the border radius to 5
// ),
// ),
// ),
// ),
// const SizedBox(width: 12),
// Expanded(
// child: ElevatedButton.icon(
// onPressed: () async {
// final scanner = ref.read(scannerProvider);
// await scanner.stopScanning();
// },
// label: const Text("Stop Scanning"),
// style: ElevatedButton.styleFrom(
// backgroundColor: RedColor,
// foregroundColor: Colors.white,
// padding: const EdgeInsets.symmetric(vertical: 12),
// shape: RoundedRectangleBorder(
// borderRadius: BorderRadius.circular(10), // Set the border radius to 5
// ),
// ),
// ),
// ),
// ],
// ),
// ),
