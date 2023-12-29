import 'dart:io' as io;
import 'package:intl/intl.dart';
import 'package:order_booking_shop/Models/ReturnFormDetails.dart';
import 'package:order_booking_shop/Models/ReturnFormModel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import '../../API/ApiServices.dart';
import '../../Models/OrderModels/OrderDetailsModel.dart';
import '../../Models/OrderModels/OrderMasterModel.dart';


class DBHelperReturnForm{

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
    String path = join(documentDirectory.path,'returnForm.db');
    var db = openDatabase(path,version: 1,onCreate: _onCreate);
    return db;
  }
  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE returnForm (returnId INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, shopName TEXT)");

    await db.execute('''
      CREATE TABLE return_form_details(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        returnFormId TEXT,
        productName TEXT,
        quantity TEXT,
        reason TEXT,
        FOREIGN KEY (returnFormId) REFERENCES returnForm(returnId)
      )
    ''');
  }
  //
  // Future<void> addOrderMaster(OrderMasterModel orderMaster) async {
  //   final db = await _db;
  //
  //   // Get user ID and current month
  //   String userId = orderMaster.userId;
  //   String currentMonth = DateFormat('MMM').format(DateTime.now());
  //
  //   // Concatenate "userId+month+counter" to form the new orderId
  //   int counter = await getNextOrderIdCounter(db);
  //   String newOrderId = "$userId-${currentMonth}-${counter.toString().padLeft(3, '0')}";
  //
  //   orderMaster.orderId = newOrderId;
  //
  //   await db?.insert('orderMaster', orderMaster.toMap());
  // }
  //
  // Future<int> getNextOrderIdCounter(Database? db) async {
  //   if (db != null) {
  //     // Get current month
  //     String currentMonth = DateFormat('MMM').format(DateTime.now());
  //     try {
  //       // Get the maximum counter value for the current month
  //       List<Map<String, dynamic>> result = await db.rawQuery(
  //           "SELECT MAX(CAST(SUBSTR(orderId, -3) AS INTEGER)) as maxCounter FROM orderMaster WHERE orderId LIKE '%$currentMonth%'");
  //
  //       int maxCounter = (result[0]['maxCounter'] ?? 0) + 1;
  //
  //       return maxCounter;
  //     } catch (e) {
  //       print("Error getting max counter: $e");
  //       return 1; // If an error occurs, default to 1
  //     }
  //   } else {
  //     return 1; // If the database is null, default to 1
  //   }
  // }

  // Future<void> addOrderDetails(List<OrderDetailsModel> orderDetailsList) async {
  //   final db = await _db;
  //   for (var orderDetails in orderDetailsList) {
  //     await db?.insert('order_details', orderDetails.toMap());
  //   }
  // }

  Future<List<Map<String, dynamic>>> getReturnFormDetailsDB() async {
    final db = await _db;
    try {
      if (db != null) {
        final List<Map<String, dynamic>> products = await db.rawQuery('SELECT * FROM return_form_details');
        return products;
      } else {
        // Handle the case where the database is null
        return [];
      }
    } catch (e) {
      // Let the calling code handle the error
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>?> getReturnFormDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> products = await db.query('returnForm');
      return products;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }

  Future<void> postReturnFormTable() async {
    final Database db = await initDatabase();
    final ApiServices api = ApiServices();

    try {
      final products = await db.rawQuery('select * from returnForm');
      var count = 0;

      for (var i in products) {
        print("FIRST ${i.toString()}");

        ReturnFormModel v =  ReturnFormModel(
          returnId: i['returnId'].toString(),
          shopName: i['shopName'].toString(),
          date: i['date'].toString(),

        );

        var result = await api.masterPost(
          v.toMap(),
          'https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/return/post/',
        );

        if (result == true) {
          db.rawQuery("DELETE FROM returnForm WHERE returnId = '${i['returnId']}'");

        }
      }
    } catch (e) {
      print("ErrorRRRRRRRRR: $e");
      return null;
    }
  }

  Future<void> postReturnFormDetails() async {
    final Database db = await initDatabase();
    final ApiServices api = ApiServices();
    try {
      final products = await db.rawQuery('select * from return_form_details');
      var count = 0;
      for(var i in products){
        print(i.toString());
        count++;
        ReturnFormDetailsModel v =ReturnFormDetailsModel(
            id: "${i['id']}".toString(),
            returnformId: i['returnFormId'].toString(),
            productName: i['productName'].toString(),
            reason: i['reason'].toString(),
            quantity: i['quantity'].toString(),

        );
        var result = await api.masterPost(v.toMap(), 'https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/returndetail/post/');
        if(result == true){
          db.rawQuery('DELETE FROM return_form_details WHERE id = ${i['id']}');
        }
      }
    } catch (e) {
      print("ErrorRRRRRRRRR: $e");
      return null;
    }
  }
}