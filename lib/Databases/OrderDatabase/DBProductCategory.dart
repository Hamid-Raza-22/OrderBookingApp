import 'dart:io' as io;
import 'package:order_booking_shop/Models/AttendanceModel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

import '../../API/ApiServices.dart';

class DBHelperProductCategory{

  static Database? _db;

  Future<Database> get db async{
    if(_db != null)
    {
      return _db!;
    }
    _db = await initDatabase();
    return _db!;
  }

  Future<Database>initDatabase() async{
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path,'productCategory.db');
    var db = openDatabase(path,version: 1,onCreate: _onCreate);
    return db;
  }
  _onCreate(Database db, int version) async{
    await db.execute("CREATE TABLE productCategory(product_brand TEXT)");
    await db.execute("CREATE TABLE attendance(id INTEGER PRIMARY KEY , date TEXT, timeIn TEXT, userId TEXT, latIn TEXT, lngIn TEXT)");
    await db.execute("CREATE TABLE attendanceOut(id INTEGER PRIMARY KEY , date TEXT, timeOut TEXT, totalTime TEXT, userId TEXT,latOut TEXT, lngOut TEXT)");

  }

  Future<void> postAttendanceTable() async {
    final Database db = await initDatabase();
    final ApiServices api = ApiServices();
    try {
      final products = await db.rawQuery('select * from attendance');
      var count = 0;

      for (var i in products) {
        print("FIRST ${i.toString()}");

        AttendanceModel v = AttendanceModel(
            id: i['id'].toString(),
            date: i['date'].toString(),
            userId: i['userId'].toString(),
            timeIn: i['timeIn'].toString(),
            latIn: i['latIn'].toString(),
            lngIn: i['lngIn'].toString(),
        );
        var result = await api.masterPost(
          v.toMap(),
          'https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/attendance/post/',
        );

        if (result == true) {
          db.rawQuery("DELETE FROM attendance WHERE id = '${i['id']}'");

        }
      }
    } catch (e) {
      print("ErrorRRRRRRRRR: $e");
      return null;
    }
  }


  Future<void> postAttendanceOutTable() async {
    final Database db = await initDatabase();
    final ApiServices api = ApiServices();
    try {
      final products = await db.rawQuery('select * from attendanceOut');
      var count = 0;

      for (var i in products) {
        print("FIRST ${i.toString()}");

        AttendanceOutModel v = AttendanceOutModel(
          id: i['id'].toString(),
          date: i['date'].toString(),
          userId: i['userId'].toString(),
          timeOut: i['timeOut'].toString(),
          totalTime: i['totalTime'].toString(),
          latOut: i['latOut'].toString(),
          lngOut: i['lngOut'].toString(),
        );
        var result = await api.masterPost(
          v.toMap(),
          'https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/attendanceend/post/',
        );

        if (result == true) {
          db.rawQuery("DELETE FROM attendanceOut WHERE id = '${i['id']}'");

        }
      }
    } catch (e) {
      print("ErrorRRRRRRRRR: $e");
      return null;
    }
  }



  Future<bool> insertProductCategory(List<dynamic> dataList) async {
    final Database db = await initDatabase();
    try {
      for (var data in dataList) {
        await db.insert('productCategory', data);
      }
      return true;
    } catch (e) {
      print("Error inserting product category data: ${e.toString()}");
      return false;
    }
  }


  // Future<List<String>> getBrandItems() async {
  //   final Database db = await initDatabase();
  //   try {
  //     final List<Map<String, dynamic>> result = await db.query('productCategory');
  //     return result.map((data) => data['product_brand'] as String).toList();
  //   } catch (e) {
  //     print("Error fetching brand items: $e");
  //     return [];
  //   }
  // }

  Future<void> deleteAllRecords() async{
    final db = await initDatabase();
    await db.delete('productCategory');
  }

  Future<List<Map<String, dynamic>>?> getAllPCs() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> PCs = await db.query('productCategory');
      return PCs;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }
  Future<List<Map<String, dynamic>>?> getAllAttendance() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> PCs = await db.query('attendance');
      return PCs;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getAllAttendanceOut() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> PCs = await db.query('attendanceOut');
      return PCs;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }
}