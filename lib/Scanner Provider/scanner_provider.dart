import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../HoneyWell Plugin/honeywell_scanner.dart';
import '../HoneyWell Plugin/scanned_data.dart';
import '../HoneyWell Plugin/code_format.dart';

final scannerProvider = Provider<HoneywellScanner>((ref) {
  final scanner = HoneywellScanner();
  return scanner;
});

final scannerEnabledProvider = StateProvider<bool>((ref) => false);
final scan1DProvider = StateProvider<bool>((ref) => true);
final scan2DProvider = StateProvider<bool>((ref) => true);
final scannedDataProvider = StateProvider<ScannedData?>((ref) => null);
final scannerErrorProvider = StateProvider<String?>((ref) => null);

final deviceSupportProvider = FutureProvider<bool>((ref) async {
  return await ref.read(scannerProvider).isSupported();
});
