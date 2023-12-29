import 'dart:io' as io;
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import '../../API/ApiServices.dart';
import '../../Models/OrderModels/OrderDetailsModel.dart';
import '../../Models/OrderModels/OrderMasterModel.dart';


class DBHelperOrderMaster{

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
    String path = join(documentDirectory.path,'ordermaster.db');
    var db = openDatabase(path,version: 1,onCreate: _onCreate);
    return db;
  }
  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE orderMaster (orderId TEXT PRIMARY KEY, date TEXT, shopName TEXT, ownerName TEXT, phoneNo TEXT, brand TEXT, userName TEXT, userId TEXT, total INTEGER, creditLimit TEXT, discount INTEGER, subTotal INTEGER, requiredDelivery TEXT)");

    await db.execute('''
      CREATE TABLE order_details(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_master_id TEXT,
        productName TEXT,
        quantity INTEGER,
        price INTEGER,
        amount INTEGER,
        FOREIGN KEY (order_master_id) REFERENCES orderMaster(orderId)
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

  Future<void> addOrderDetails(List<OrderDetailsModel> orderDetailsList) async {
    final db = await _db;
    for (var orderDetails in orderDetailsList) {
      await db?.insert('order_details', orderDetails.toMap());
    }
  }

  Future<List<Map<String, dynamic>>> getOrderDetails() async {
    final db = await _db;
    try {
      if (db != null) {
        final List<Map<String, dynamic>> products = await db.rawQuery('SELECT * FROM order_details');
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

  Future<List<Map<String, dynamic>>?> getOrderMasterDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> products = await db.query('orderMaster');
      return products;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }

  Future<void> postMasterTable() async {
    final Database db = await initDatabase();
    final ApiServices api = ApiServices();

    try {
      final products = await db.rawQuery('select * from orderMaster');
      var count = 0;

      for (var i in products) {
        print("FIRST ${i.toString()}");


        OrderMasterModel v = OrderMasterModel(
          orderId: i['orderId'].toString(),
          shopName: i['shopName'].toString(),
          ownerName: i['ownerName'].toString(),
          phoneNo: i['phoneNo'].toString(),
          brand: i['brand'].toString(),
          date: i['date'].toString(),
          userId: i['userId'].toString(),
            userName: i['userName'].toString(),

            total: i['total'].toString(),
            subTotal: i['subTotal'].toString(),

            discount: i['discount'].toString(),
            creditLimit: i['creditLimit'].toString(),
            requiredDelivery: i['requiredDelivery'].toString()
        );

        var result = await api.masterPost(
          v.toMap(),
          'https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/ordermaster/post',
        );

        if (result == true) {
          db.rawQuery("DELETE FROM orderMaster WHERE orderId = '${i['orderId']}'");

        }
      }
    } catch (e) {
      print("ErrorRRRRRRRRR: $e");
      return null;
    }
  }

  Future<void> postOrderDetails() async {
    final Database db = await initDatabase();
    final ApiServices api = ApiServices();
    try {
      final products = await db.rawQuery('select * from order_details');
      var count = 0;
      for(var i in products){
        print(i.toString());
        count++;
        OrderDetailsModel v = OrderDetailsModel(
            id: i['id'].toString(),
            orderMasterId: i['order_master_id'].toString(),
            productName: i['productName'].toString(),
            price: i['price'].toString(),
            quantity: i['quantity'].toString(),
            amount: i['amount'].toString()
        );
        var result = await api.masterPost(v.toMap(), 'https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/orderdetail/record/');
        if(result == true){
          db.rawQuery("DELETE FROM order_details WHERE id = '${i['id']}'");
        }
      }
    } catch (e) {
      print("ErrorRRRRRRRRR: $e");
      return null;
    }
  }
}