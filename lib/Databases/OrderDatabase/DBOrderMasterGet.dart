import 'dart:io';
import 'package:order_booking_shop/API/Globals.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../Views/ReturnFormPage.dart';

class DBOrderMasterGet {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDatabase();
    return _db!;
  }

  Future<Database> initDatabase() async {
    var documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'orderMasterData.db');
    var db = openDatabase(path,version: 1,onCreate: _onCreate);
    return db;
  }
  _onCreate(Database db, int version) async {
   await db.execute("CREATE TABLE orderMasterData(order_no TEXT, shop_name TEXT, user_id TEXT)");
   await  db.execute("CREATE TABLE orderDetailsData(order_no TEXT, product_name TEXT, quantity_booked INTEGER)");
   await db.execute("CREATE TABLE orderBookingStatusData(order_no TEXT, status TEXT, order_date TEXT, shop_name TEXT, amount TEXT)");
   await db.execute("CREATE TABLE netBalance(shop_name TEXT, debit TEXT,credit TEXT)");
   await db.execute("CREATE TABLE accounts(account_id INTEGER, shop_name TEXT, order_date TEXT, credit TEXT, booker_name TEXT)");
  }

  Future<bool> insertAccoutsData(List<dynamic> dataList) async {
    final Database db = await initDatabase();
    try {
      for (var data in dataList) {
        await db.insert('accounts', data);
      }
      return true;
    } catch (e) {
      print("Error inserting Accounts: ${e.toString()}");
      return false;
    }
  }


  Future<bool> insertNetBalanceData(List<dynamic> dataList) async {
    final Database db = await initDatabase();
    try {
      for (var data in dataList) {
        await db.insert('netBalance', data);
      }
      return true;
    } catch (e) {
      print("Error inserting netBalanceData: ${e.toString()}");
      return false;
    }
  }



  Future<bool> insertOrderBookingStatusData(List<dynamic> dataList) async {
    final Database db = await initDatabase();
    try {
      for (var data in dataList) {
        await db.insert('orderBookingStatusData', data);
      }
      return true;
    } catch (e) {
      print("Error inserting orderBookingStatusData: ${e.toString()}");
      return false;
    }
  }


  Future<List<String>?> getShopNamesFromNetBalance() async {
    try {
      final List<Map<String, dynamic>>? netBalanceData = await getNetBalanceDB();
      return netBalanceData?.map((map) => map['shop_name'] as String).toList();
    } catch (e) {
      print("Error retrieving shop names from netBalance: $e");
      return [];
    }
  }
  Future<Map<String, dynamic>> getDebitsAndCreditsTotal() async {
    try {
      final List<Map<String, dynamic>>? netBalanceData = await getNetBalanceDB();
      Map<String, double> shopDebits = {};
      Map<String, double> shopCredits = {};

      for (var row in netBalanceData!) {
        String shopName = row['shop_name'];
        double debit = double.parse(row['debit'] ?? '0');
        double credit = double.parse(row['credit'] ?? '0');

        shopDebits[shopName] = (shopDebits[shopName] ?? 0) + debit;
        shopCredits[shopName] = (shopCredits[shopName] ?? 0) + credit;
      }

      return {'debits': shopDebits, 'credits': shopCredits};
    } catch (e) {
      print("Error calculating debits and credits total: $e");
      return {'debits': {}, 'credits': {}};
    }
  }


  Future<Map<String, double>> getDebitsMinusCreditsPerShop() async {
    try {
      final List<Map<String, dynamic>>? netBalanceData = await getNetBalanceDB();
      Map<String, double> shopDebitsMinusCredits = {};

      for (var row in netBalanceData!) {
        String shopName = row['shop_name'];
        double debit = double.parse(row['debit'] ?? '0');
        double credit = double.parse(row['credit'] ?? '0');

        double debitsMinusCredits = debit - credit;

        shopDebitsMinusCredits[shopName] = (shopDebitsMinusCredits[shopName] ?? 0) + debitsMinusCredits;
      }

      return shopDebitsMinusCredits;
    } catch (e) {
      print("Error calculating debits minus credits per shop: $e");
      return {};
    }
  }

  Future<bool> insertOrderMasterData(List<dynamic> dataList) async {
    final Database db = await initDatabase();
    try {
      for (var data in dataList) {
        await db.insert('orderMasterData', data);
      }
      return true;
    } catch (e) {
      print("Error inserting orderMaster data: ${e.toString()}");
      return false;
    }
  }

  Future<bool> insertOrderDetailsData(List<dynamic> dataList) async {
    final Database db = await initDatabase();
    try {
      for (var data in dataList) {
        await db.insert('orderDetailsData', data);
      }
      return true;
    } catch (e) {
      print("Error inserting orderDetailsGet data: ${e.toString()}");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> getNetBalanceDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> netbalance = await db.query('netBalance');
      return  netbalance;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }


  Future<List<Map<String, dynamic>>?> getAccoutsDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> account = await db.query('accounts');
      return  account;
    } catch (e) {
      print("Error retrieving accounts: $e");
      return null;
    }
  }


  Future<List<Map<String, dynamic>>?> getOrderBookingStatusDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> orderbookingstatus = await db.query('orderBookingStatusData');
      return  orderbookingstatus;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getOrderMasterDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> ordermaster = await db.query('orderMasterData');
      return ordermaster;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getOrderDetailsDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> orderdetails = await db.query('orderDetailsData');
      return orderdetails;
    } catch (e) {
      print("Error retrieving orderDetailsGet: $e");
      return null;
    }
  }

  Future<List<String>> getOrderMasterShopNames() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> shopNames = await db.query('orderMasterData', where: 'user_id = ?', whereArgs: [userId]);
      return shopNames.map((map) => map['shop_name'] as String).toList();
    } catch (e) {
      print("Error retrieving shop names: $e");
      return [];
    }
  }


  //
  // Future<List<String>> getShopNamesForCity(String userCity) async {
  //   final Database db = await initDatabase();
  //   try {
  //     final List<Map<String, dynamic>> shopNames = await db.query(
  //       'ownerData',
  //       where: 'city = ?',
  //       whereArgs: [userCitys],
  //     );
  //     return shopNames.map((map) => map['shop_name'] as String).toList();
  //   } catch (e) {
  //     print("Error retrieving shop names for city: $e");
  //     return [];
  //   }
  // }
  //
  Future<List<String>> getOrderDetailsProductNames() async {
    final Database db = await initDatabase();
    try {
      // Retrieve product names where order_no matches the global variable
      final List<Map<String, dynamic>> productNames = await db.query(
        'orderDetailsData',
        where: 'order_no = ?',
        whereArgs: [selectedorderno],
      );
      return productNames.map((map) => map['product_name'] as String).toList();
    } catch (e) {
      print("Error retrieving Products names: $e");
      return [];
    }
  }

  Future<String?> fetchQuantityForProduct(String productName) async {
    try {
      final Database db = await initDatabase();
      final List<Map<String, dynamic>> result = await db.query(
        'orderDetailsData',
        columns: ['quantity_booked'],
        where: 'product_name = ?',
        whereArgs: [productName],
      );

      if (result.isNotEmpty) {
        return result[0]['quantity_booked'].toString();
      } else {
        return null; // Handle the case where quantity is not found
      }
    } catch (e) {
      print("Error fetching quantity for product: $e");
      return null;
    }
  }

  Future<void> deleteAllRecords() async {

    final db = await initDatabase();
    await db.delete('orderMasterData');
    await db.delete('orderDetailsData');
    await db.delete('orderBookingStatusData');
    await db.delete('netBalance');
    await db.delete('accounts');
  }
}
