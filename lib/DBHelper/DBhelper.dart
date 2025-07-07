import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class BarcodeDatabaseHelper {
  static final BarcodeDatabaseHelper _instance = BarcodeDatabaseHelper._internal();
  factory BarcodeDatabaseHelper() => _instance;
  BarcodeDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'barcode_data.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Table 1: scanned_barcodes
    await db.execute('''
      CREATE TABLE scanned_barcodes (
        sid INTEGER PRIMARY KEY AUTOINCREMENT,
        productName TEXT,
        batchNumber TEXT,
        productionDate TEXT,
        serialNumber TEXT,
        rawBarcode TEXT
      )
    ''');

    // Table 2: pushed_barcodes (with purchaseOrder)
    await db.execute('''
      CREATE TABLE pushed_barcodes (
        pid INTEGER PRIMARY KEY AUTOINCREMENT,
        purchaseOrder TEXT,
        productName TEXT,
        batchNumber TEXT,
        productionDate TEXT,
        serialNumber TEXT,
        rawBarcode TEXT
      )
    ''');
  }

  // Insert into scanned_barcodes
  Future<int> insertBarcode(Map<String, String> barcodeData) async {
    final db = await database;
    return await db.insert(
      'scanned_barcodes',
      {
        'productName': barcodeData['91'] ?? '',
        'batchNumber': barcodeData['10'] ?? '',
        'productionDate': barcodeData['11'] ?? '',
        'serialNumber': barcodeData['21'] ?? '',
        'rawBarcode': barcodeData['rawBarcode'] ?? '',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  // Insert into pushed_barcodes
  Future<int> insertPushedBarcode(Map<String, String> barcodeData, String purchaseOrder) async {
    final db = await database;
    return await db.insert(
      'pushed_barcodes',
      {
        'purchaseOrder': purchaseOrder,
        'productName': barcodeData['91'] ?? '',
        'batchNumber': barcodeData['10'] ?? '',
        'productionDate': barcodeData['11'] ?? '',
        'serialNumber': barcodeData['21'] ?? '',
        'rawBarcode': barcodeData['rawBarcode'] ?? '',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<void> deleteById(int sid) async {
    final db = await database;
    await db.delete(
      'scanned_barcodes',
      where: 'sid = ?',
      whereArgs: [sid],
    );
  }

  Future<void> deletepushdataById(int pid) async {
    final db = await database;
    await db.delete(
      'pushed_barcodes',
      where: 'pid = ?',
      whereArgs: [pid],
    );
  }


  Future<Map<String, dynamic>?> getBarcodeById(int sid) async {
    final db = await database;
    final result = await db.query(
      'scanned_barcodes',
      where: 'sid = ?',
      whereArgs: [sid],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getPushedBarcodeById(int pid) async {
    final db = await database;
    final result = await db.query(
      'pushed_barcodes',
      where: 'pid = ?',
      whereArgs: [pid],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllBarcodes() async {
    final db = await database;
    return await db.query('scanned_barcodes', orderBy: 'sid DESC');
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete('scanned_barcodes');
  }

  Future<List<Map<String, dynamic>>> getAllPushedBarcodes() async {
    final db = await database;
    return await db.query('pushed_barcodes', orderBy: 'pid DESC');
  }

  Future<void> deleteAllPushed() async {
    final db = await database;
    await db.delete('pushed_barcodes');
  }
}
