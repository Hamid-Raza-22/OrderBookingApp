import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';
import 'dart:typed_data';
import 'package:nanoid/async.dart';
import 'package:order_booking_shop/Models/StockCheckItems.dart';
import 'package:order_booking_shop/main.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../API/ApiServices.dart';
import '../Models/ShopVisitModels.dart';
// import '../main.dart';

class DBHelperShopVisit {
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
    String path = join(documentDirectory.path, 'shopvisit.db');
    var db = openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE shopVisit (
        id TEXT PRIMARY KEY,
        date TEXT,
        shopName TEXT,
        userId TEXT,
        bookerName TEXT,
        brand TEXT,
        walkthrough TEXT,
        planogram TEXT,
        signage TEXT,
        productReviewed TEXT,
        body BLOB,
        feedback TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Stock_Check_Items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shopvisitId TEXT,
        itemDesc TEXT,
        qty TEXT,
        FOREIGN KEY (shopvisitId) REFERENCES shopVisit(id)
      )
    ''');
  }

  Future<void> addStockCheckItems(List<StockCheckItemsModel> stockCheckItemsList) async {
    final db = await _db;
    for (var stockCheckItems in stockCheckItemsList) {
      await db?.insert('Stock_Check_Items',stockCheckItems.toMap());
    }
  }

  Future<List<Map<String, dynamic>>?> getShopVisitDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> shopVisit = await db.query('shopVisit');
      return shopVisit;
    } catch (e) {
      print("Error retrieving shopVisit: $e");
      return null;
    }
  }
  Future<List<Map<String, dynamic>>> getShopVisit({int limit = 0, int offset = 0}) async {
    final db = await _db;
    try {
      if (db != null) {
        String query = 'SELECT id, date, shopName, userId, bookerName, brand, walkthrough, planogram, signage, productReviewed, body, feedback FROM shopVisit';

        // Add LIMIT and OFFSET only if specified
        if (limit > 0) {
          query += ' LIMIT $limit';
        }
        if (offset > 0) {
          query += ' OFFSET $offset';
        }

        final List<Map<String, dynamic>> products = await db.rawQuery(query);

        // Fetch the body data separately
        // for (Map<String, dynamic> product in products) {
        //   final Uint8List body = await fetchBodyData(product['id']);
        //   product['body'] = body;
        // }

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

  // Future<Uint8List> fetchBodyData(String id) async {
  //   final db = await _db;
  //   try {
  //     if (db != null) {
  //       final List<Map<String, dynamic>> result = await db.query(
  //         'shopVisit',
  //         columns: ['body'],
  //         where: 'id = ?',
  //         whereArgs: [id],
  //       );
  //
  //       if (result.isNotEmpty) {
  //         return Uint8List.fromList(base64Decode(result[0]['body'].toString()));
  //       }
  //     }
  //
  //     // Handle the case where data is not found
  //     return Uint8List(0);
  //   } catch (e) {
  //     // Handle the error or rethrow it
  //     print('Error fetching body data: $e');
  //     rethrow;
  //   }
  // }

  Future<List<Map<String, dynamic>>> getStockCheckItems() async {
    final db = await _db;
    try {
      if (db != null) {
        final List<Map<String, dynamic>> products = await db.rawQuery('SELECT * FROM Stock_Check_Items');
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
  //
  // Future<void> addShopVisit(ShopVisitModel shopVisit) async {
  //   final db = await _db;
  //   try {
  //     await db?.insert(
  //       'shopVisit',
  //       shopVisit.toMap(),
  //       conflictAlgorithm: ConflictAlgorithm.replace,
  //     );
  //
  //     // Check if 'imagePath' is not null or empty
  //     if (shopVisit.imagePath != null && shopVisit.imagePath!.isNotEmpty) {
  //       // Read the image file and convert it to bytes
  //       File imageFile = File(shopVisit.imagePath! as String);
  //       List<int> imageBytesList = await imageFile.readAsBytes();
  //       Uint8List imagePathBytes = Uint8List.fromList(imageBytesList);
  //
  //       // Update the 'imagePath' field in the database with image bytes
  //       await db?.update(
  //         'shopVisit',
  //         {'imagePath': imagePathBytes},
  //         where: 'id = ?',
  //         whereArgs: [shopVisit.id],
  //       );
  //     }
  //   } catch (e) {
  //     print('Error adding shop visit: $e');
  //   }
  // }
  Future<void> postShopVisitData() async {
    final Database db = await initDatabase();
    final ApiServices api = ApiServices();

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/captured_image.jpg';


    try {
      final products = await db.rawQuery('''SELECT *, 
      CASE WHEN walkthrough = 1 THEN 'True' ELSE 'False' END AS walkthrough,
      CASE WHEN planogram = 1 THEN 'True' ELSE 'False' END AS planogram,
      CASE WHEN signage = 1 THEN 'True' ELSE 'False' END AS signage,
      CASE WHEN productReviewed = 1 THEN 'True' ELSE 'False' END AS productReviewed
      FROM shopVisit
      ''');

      await db.rawQuery('VACUUM');


      for (Map<dynamic, dynamic> i in products) {
        print("FIRST ${i}");

        ShopVisitModel v = ShopVisitModel(
          id: i['id'].toString(),
          date: i['date'].toString(),
          userId: i['userId'].toString(),
          shopName: i['shopName'].toString(),
          bookerName: i['bookerName'].toString(),
          brand: i['brand'].toString(),
          walkthrough: i['walkthrough'].toString(),
          planogram: i['planogram'].toString(),
          signage: i['signage'].toString(),
          productReviewed: i['productReviewed'].toString(),
          body: i['body'] != null && i['body'].toString().isNotEmpty
              ? Uint8List.fromList(base64Decode(i['body'].toString()))
              : Uint8List(0),
          feedback: i['feedback'].toString(),
        );

        // // Fetch the body data separately
        // final Uint8List body = await fetchBodyData(v.id);
        // v.body = body;

        // Print image path before trying to create the file
        print("Image Path from Database: ${i['body']}");

        // Declare imageBytes outside the if block
        Uint8List imageBytes;
        final directory = await getApplicationDocumentsDirectory();
        final filePath = File('${directory.path}/captured_image.jpg');

        if (filePath.existsSync()) {
          // File exists, proceed with reading the file
          List<int> imageBytesList = await filePath.readAsBytes();
          imageBytes = Uint8List.fromList(imageBytesList);
        } else {
          print("File does not exist at the specified path: ${filePath.path}");
          continue; // Skip to the next iteration if the file doesn't exist
        }


// Rest of your code...

        // Print information before making the API request
        print("Making API request for shop visit ID: ${v.id}");





        var result = await api.masterPostWithImage(
          v.toMap(),
          'https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/report/post/',
          imageBytes,
        );
        if (result == true) {
          await db.rawQuery('DELETE FROM shopVisit');
          print("Successfully posted data for shop visit ID: ${v.id}");
        } else {
          print("Failed to post data for shop visit ID: ${v.id}");
        }
      }
    } catch (e) {
      print("Error processing shop visit data: $e");
      return null;
    }
  }


  Future<void> postStockCheckItems() async {
    final Database db = await initDatabase();
    final ApiServices api = ApiServices();
    try {
      final products = await db.rawQuery('select * from Stock_Check_Items');
      var count = 0;
      for(var i in products){
        print(i.toString());
        count++;
        StockCheckItemsModel v =StockCheckItemsModel(
          id: "${i['id']}${i['shopvisitId']}".toString(),
          shopvisitId: i['shopvisitId'].toString(),
          itemDesc: i['itemDesc'].toString(),
          qty: i['qty'].toString(),
        );
        var result = await api.masterPost(v.toMap(), 'https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/items/post/');
        if(result == true){
          db.rawQuery('DELETE FROM Stock_Check_Items WHERE id = ${i['id']}');
        }
      }
    } catch (e) {
      print("ErrorRRRRRRRRR: $e");
      return null;
    }
  }

}