import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io' as io;
import 'dart:async';

import '../API/ApiServices.dart';
import '../Models/ShopModel.dart';

class DBHelper {
  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDatabase();
    return _db!;
  }


  Future<Database> initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'shop.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate ,);
    return db;
  }
_onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE shop(id INTEGER PRIMARY KEY AUTOINCREMENT, shopName TEXT, city TEXT,date TEXT, shopAddress TEXT, ownerName TEXT, ownerCNIC TEXT, phoneNo TEXT, alternativePhoneNo INTEGER, latitude TEXT, longitude TEXT, userId TEXT)");

  }
  // Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  //   print('Database upgrade: from $oldVersion to $newVersion');
  //   if (oldVersion < 2) {
  //     print('Adding columns: city and alternativePhoneNo');
  //     // Add the "city" column in version 2.
  //     await db.execute('ALTER TABLE shop ADD COLUMN city TEXT');
  //     // Add the "alternativePhoneNo" column in version 2.
  //     await db.execute('ALTER TABLE shop ADD COLUMN alternativePhoneNo INTEGER');
  //   }
  // }

  Future<ShopModel?> getShopData(int id) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient!.query(
      'shop',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ShopModel.fromMap(maps.first);
    } else {
      return null;
    }
  }


  Future<List<Map<String, dynamic>>?> getShopDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> products = await db.query('shop');
      return products;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }
  Future<void> postShopTable() async {
    final Database db = await initDatabase();
    final ApiServices api = ApiServices();

    try {
      final products = await db.rawQuery('select * from shop');
      var count = 0;

      for (var i in products) {

        print("FIRST ${i.toString()}");


        ShopModel v = ShopModel(
            id: "${i['id']}",
            shopName: i['shopName'].toString(),
            city: i['city'].toString(),
            date: i['date'].toString(),
            shopAddress: i['shopAddress'].toString(),
            ownerName: i['ownerName'].toString(),
            ownerCNIC: i['ownerCNIC'].toString(),
            phoneNo: i['phoneNo'].toString(),
            alternativePhoneNo: i['alternativePhoneNo'].toString(),
            latitude: i['latitude'].toString(),
             longitude: i['longitude'].toString(),
             userId: i['userId'].toString()


        );

        var result = await api.masterPost(
          v.toMap(),
          'https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/shoppost/post/',
        );

        if (result == true) {
          db.rawQuery("DELETE FROM shop WHERE id = '${i['id']}'");
        }
      }
    } catch (e) {
      print("ErrorRRRRRRRRR: $e");
      return null;
    }
  }
  Future<bool> entershopdata(String shopName) async {
    final Database db = await initDatabase();
    try {
      await db.rawInsert("INSERT INTO shops (shopName) VALUES ('$shopName')");
      return true;
    } catch (e) {
      print("Error inserting product: $e");
      return false;
    }
  }
  Future<Object> getrow() async {
    final Database db = await initDatabase();
    try {
      var results = await db.rawQuery("SELECT * FROM shops");
      if (results.isNotEmpty) {
        return results;
      } else {
        print("No rows found in the 'shops' table.");
        return false;
      }
    } catch (e) {
      print("Error retrieving product: $e");
      return false;
    }
  }
  Future<bool> enterownerdata(ShopModel shopModel) async {
    final Database db = await initDatabase();
    try {
      await db.rawQuery("INSERT INTO  owner(owner_name,owner_contact  VALUES ('${shopModel.ownerName.toString()}','${shopModel.phoneNo.toString()}'}') ");
      return true;
    } catch (e) {
      print("Error inserting product: $e");
      return false;
    }
    }

// Define a function to perform a migration if necessary.

  // Create a shop
  Future<int> createShop(ShopModel shop) async {
    final dbClient = await db;
    return dbClient!.insert('shop', shop.toMap());
  }

  // Read all shops
  Future<List<ShopModel>> getShop() async {
    final dbClient = await db;
    final List<Map<dynamic, dynamic>> maps = await dbClient!.query('shop');
    return List.generate(maps.length, (index) {
      return ShopModel.fromMap(maps[index]);
    });
  }

  //
  // // Update a shop
  // Future<int> updateShop(ShopModel shop) async {
  //   final dbClient = await db;
  //   return dbClient!.update('shop', shop.toMap(),
  //       where: 'id = ?', whereArgs: [shop.id]);
  // }

  // Delete a shop
  Future<int> deleteShop(int id) async {
    final dbClient = await db;
    return dbClient!.delete('shop', where: 'id = ?', whereArgs: [id]);
  }
}
