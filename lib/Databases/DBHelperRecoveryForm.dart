import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

import '../API/ApiServices.dart';
import '../Models/RecoveryFormModel.dart';



class DBHelperRecoveryForm {

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDatabase();
    return _db!;
  }

  Future<Database> initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'recoveryForm.db');
    var db = openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE recoveryForm (recoveryId TEXT, date TEXT, shopName TEXT, cashRecovery REAL, netBalance REAL, userId TEXT )");
  }

  Future<List<Map<String, dynamic>>?> getRecoveryFormDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> products = await db.query('recoveryForm');
      return products;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }

  Future<void> postRecoveryFormTable() async {
    final Database db = await initDatabase();
    final ApiServices api = ApiServices();

    try {
      final products = await db.rawQuery('select * from recoveryForm');
      var count = 0;

      for (var i in products) {
        print("FIRST ${i.toString()}");

        RecoveryFormModel v =  RecoveryFormModel(
          recoveryId: i['recoveryId'].toString(),
          shopName: i['shopName'].toString(),
          date: i['date'].toString(),
          cashRecovery: i['cashRecovery'].toString(),
         netBalance: i['netBalance'].toString(),
          userId: i['userId'].toString()

        );

        var result = await api.masterPost(
          v.toMap(),
          'https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/recovery/post/',
        );

        if (result == true) {
          db.rawQuery("DELETE FROM recoveryForm WHERE recoveryId = '${i['recoveryId']}'");

        }
      }
    } catch (e) {
      print("ErrorRRRRRRRRR: $e");
      return null;
    }
  }




}