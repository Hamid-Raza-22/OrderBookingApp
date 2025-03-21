import 'package:order_booking_shop/Databases/DBHelper.dart';

import 'package:order_booking_shop/Models/ShopModel.dart';

import '../Databases/Util.dart';

class ShopRepository {

  DBHelper dbHelper = DBHelper();

  Future<List<ShopModel>> getShop() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient!.query('shop', columns: ['id', 'shopName' , 'city' ,'date', 'shopAddress' , 'ownerName' , 'ownerCNIC' , 'phoneNo' , 'alternativePhoneNo', 'latitude', 'longitude','userId']);
    List<ShopModel> shop = [];

    for (int i = 0; i < maps.length; i++) {
      shop.add(ShopModel.fromMap(maps[i]));
    }
    return shop;
  }

  Future<List<ShopModel>> getShopName() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient!.query('shop', columns: ['id', 'shopName']);
    List<ShopModel> shop = [];

    for (int i = 0; i < maps.length; i++) {
      shop.add(ShopModel.fromMap(maps[i]));
    }
    return shop;
  }


  Future<String> getLastid() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient!.query(
      'shop',
      columns: ['id'],
      orderBy: 'Id DESC',
      limit: 1,
    );
    if (maps.isEmpty) {
      // Handle the case when no records are found
      return "";
    }

    // Convert the orderId to a string and return
    return maps[0]['id'].toString();
  }



  Future<int> add(ShopModel shopModel) async{
    var dbClient = await dbHelper.db;
    return await dbClient!.insert('shop' , shopModel.toMap());
  }

  Future<int> update(ShopModel shopModel) async{
    var dbClient = await dbHelper.db;
    return await dbClient!.update('shop', shopModel.toMap(),
        where: 'id=?', whereArgs: [shopModel.id] );
  }

  Future<int> delete(int id) async{
    var dbClient = await dbHelper.db;
    return await dbClient!.delete('shop',
        where: 'id=?', whereArgs: [id] );
  }
}



