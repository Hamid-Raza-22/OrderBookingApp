
import 'package:order_booking_shop/Databases/OrderDatabase/DBHelperOrderMaster.dart';


import '../../Databases/DBHelperReturnForm.dart';
import '../../Models/ReturnFormModel.dart';


class ReturnFormRepository{

  DBHelperReturnForm dbHelperReturnForm = DBHelperReturnForm();

  Future<List<ReturnFormModel>> getReturnForm() async{
    var dbClient = await dbHelperReturnForm.db;
    List<Map> maps = await dbClient.query('returnForm',columns: ['returnId','date','shopName']);
    List<ReturnFormModel> returnform = [];
    for(int i = 0; i<maps.length; i++)
    {
      returnform.add(ReturnFormModel.fromMap(maps[i]));
    }
    return returnform;
  }

  Future<String> getLastId() async {
    var dbClient = await dbHelperReturnForm.db;
    List<Map> maps = await dbClient.query(
      'returnForm',
      columns: ['returnId'],
      orderBy: 'returnId DESC',
      limit: 1,
    );

    if (maps.isEmpty) {
      // Handle the case when no records are found
      return "";
    }

    // Convert the orderId to a string and return
    return maps[0]['returnId'].toString();
  }


  Future<int> add(ReturnFormModel returnform) async{
    var dbClient = await dbHelperReturnForm.db;
    return await dbClient.insert('returnForm', returnform.toMap());
  }

  Future<int> update(ReturnFormModel returnform) async{
    var dbClient = await dbHelperReturnForm.db;
    return await dbClient.update('returnForm',returnform.toMap(),
        where: 'returnId = ?', whereArgs: [returnform.returnId]);
  }


  Future<int> delete(int returnId) async{
    var dbClient = await dbHelperReturnForm.db;
    return await dbClient.delete('returnForm',
        where: 'returnId = ?', whereArgs: [returnId]);
  }




}

