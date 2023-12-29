

import 'package:order_booking_shop/Databases/DBHelper.dart';

import '../../Databases/DBHelperShopVisit.dart';
import '../../Models/StockCheckItems.dart';

class StockCheckItemsRepository {

  DBHelperShopVisit dbHelperStockCheckItems = DBHelperShopVisit();

  Future<List<StockCheckItemsModel>> getStockCheckItems() async {
    var dbClient = await dbHelperStockCheckItems.db;
    List<Map> maps = await dbClient!.query('Stock_Check_Items', columns: ['id','shopvisitId', 'itemDesc', 'qty' ]);
    List<StockCheckItemsModel> stockcheckitems = [];
    for (int i = 0; i < maps.length; i++) {

      stockcheckitems.add(StockCheckItemsModel.fromMap(maps[i]));
    }
    return stockcheckitems;
  }

  Future<int> add(StockCheckItemsModel stockcheckitemsModel) async {
    var dbClient = await dbHelperStockCheckItems.db;
    return await dbClient!.insert('Stock_Check_Items', stockcheckitemsModel.toMap());
  }

  Future<int> update(StockCheckItemsModel stockcheckitemsModel) async {
    var dbClient = await dbHelperStockCheckItems.db;
    return await dbClient!.update('Stock_Check_Items', stockcheckitemsModel.toMap(),
        where: 'id = ?', whereArgs: [stockcheckitemsModel.id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelperStockCheckItems.db;
    return await dbClient!.delete('Stock_Check_Items',
        where: 'id = ?', whereArgs: [id]);
  }
}