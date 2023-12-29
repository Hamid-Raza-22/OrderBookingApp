//import 'package:order_booking_shop/Databases/DBHelper.dart';
import 'package:order_booking_shop/Databases/DBHelperReturnForm.dart';
import 'package:order_booking_shop/Databases/OrderDatabase/DBHelperOrderDetails.dart';
import 'package:order_booking_shop/Databases/OrderDatabase/DBHelperOrderMaster.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/DBHelper.dart';
import '../Databases/DBHelperRecoveryForm.dart';
import '../Databases/DBHelperShopVisit.dart';
import '../Databases/DBlogin.dart';
import '../Databases/OrderDatabase/DBHelperOwner.dart';
import '../Databases/OrderDatabase/DBHelperProducts.dart';
import '../Databases/OrderDatabase/DBOrderMasterGet.dart';
import '../Databases/OrderDatabase/DBProductCategory.dart';
import 'ApiServices.dart';

class DatabaseOutputs{
  Future<void> checkFirstRun() async {
    SharedPreferences SP = await SharedPreferences.getInstance();
    bool firstrun = await SP.getBool('firstrun') ?? true;
    if(firstrun == true){
      initializeData();
      await SP.setBool('firstrun', false);
    }else{
      print("UPDATING.......................................");
      await update();
      initializeData();
    }
  }
  Future<void> check_OB() async{
    SharedPreferences SP = await SharedPreferences.getInstance();
    bool firstrun = await SP.getBool('firstrun') ?? true;
    if(firstrun == true){
      initializeData();
      await SP.setBool('firstrun', false);
    }else{
      print("UPDATING.......................................");
      await update_orderbooking_status();
      initialize_orderbooking_status();
    }
  }
  Future<void> update_orderbooking_status() async{
    final dborderbookingstatus= DBOrderMasterGet();
    print("DELETING.......................................");
    await dborderbookingstatus.deleteAllRecords();
  }
  void initialize_orderbooking_status() async{
    final api = ApiServices();
    final dborderbookingstatus= DBOrderMasterGet();
    var OrderBookingStatusdata= await dborderbookingstatus.getOrderBookingStatusDB();


    if (OrderBookingStatusdata == null || OrderBookingStatusdata.isEmpty ) {
      var response2 = await api.getApi("https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/orderstatus/get/");
      var results2 = await dborderbookingstatus.insertOrderBookingStatusData(response2);   //return True or False
      if (results2) {
        print("Data inserted successfully.");
      } else {
        print("Error inserting data.");
      }
    } else {
      print("Data is available.");
    }
  }
  void initializeData() async {
    final api = ApiServices();
    final db = DBHelperProducts();
    final dbowner = DBHelperOwner();
    final dbordermaster= DBOrderMasterGet();
    final dborderdetails= DBOrderMasterGet();
    final dbnetbalance= DBOrderMasterGet();
    final dbaccounts= DBOrderMasterGet();
    final dborderbookingstatus= DBOrderMasterGet();
    final dblogin=DBHelperLogin();
    final dbProductCategory=DBHelperProductCategory();
    var Productdata = await db.getProductsDB();
    var OrderMasterdata = await dbordermaster.getOrderMasterDB();
    var OrderDetailsdata = await dborderdetails.getOrderDetailsDB();
    var NetBalancedata = await dbnetbalance.getNetBalanceDB();
    var Accountsdata = await dbaccounts.getAccoutsDB();
    var OrderBookingStatusdata= await dborderbookingstatus.getOrderBookingStatusDB();
    var Owerdata = await dbowner.getOwnersDB();
    var Logindata = await dblogin.getAllLogins();
    var PCdata = await dbProductCategory.getAllPCs();


    if (Accountsdata == null || Accountsdata.isEmpty ) {
      var response2 = await api.getApi("https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/account/get/");
      var results2 = await dbaccounts.insertAccoutsData(response2);   //return True or False
      if (results2) {
        print("Data inserted successfully.");
      } else {
        print("Error inserting data.");
      }
    } else {
      print("Data is available.");
    }


    if (NetBalancedata == null || NetBalancedata.isEmpty ) {
      var response2 = await api.getApi("https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/accountss/get/");
      var results2 = await dbnetbalance.insertNetBalanceData(response2);   //return True or False
      if (results2) {
        print("Data inserted successfully.");
      } else {
        print("Error inserting data.");
      }
    } else {
      print("Data is available.");
    }


    if (OrderBookingStatusdata == null || OrderBookingStatusdata.isEmpty ) {
      var response2 = await api.getApi("https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/orderstatus/get/");
      var results2 = await dborderbookingstatus.insertOrderBookingStatusData(response2);   //return True or False
      if (results2) {
        print("Data inserted successfully.");
      } else {
        print("Error inserting data.");
      }
    } else {
      print("Data is available.");
    }

    if (OrderMasterdata == null || OrderMasterdata.isEmpty ) {
      var response2 = await api.getApi("https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/ordermastershop/get/");
      var results2 = await dbordermaster.insertOrderMasterData(response2);   //return True or False
      if (results2) {
        print("Data inserted successfully.");
      } else {
        print("Error inserting data.");
      }
    } else {
      print("Data is available.");
    }

    if (OrderDetailsdata == null || OrderDetailsdata.isEmpty ) {
      var response2 = await api.getApi("https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/orderdetailproduct/get/");
      var results2 = await dborderdetails.insertOrderDetailsData(response2);   //return True or False
      if (results2) {
        print("Data inserted successfully.");
      } else {
        print("Error inserting data.");
      }
    } else {
      print("Data is available.");
    }


    if (Productdata == null || Productdata.isEmpty ) {
      var response = await api.getApi("https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/product/record");
      var results= await db.insertProductsData(response);  //return True or False
      if (results) {
        print("Data inserted successfully.");
      } else {
        print("Error inserting data.");
      }
    } else {
      print("Data is available.");
    }
    if (Owerdata == null || Owerdata.isEmpty ) {
      var response2 = await api.getApi("https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/AddAhop/record/");
      var results2 = await dbowner.insertOwnerData(response2);   //return True or False
      if (results2) {
        print("Data inserted successfully.");
      } else {
        print("Error inserting data.");
      }
    } else {
      print("Data is available.");
    }
    if (Logindata == null || Logindata.isEmpty ) {
      var response3 = await api.getApi("https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/login/get/");
      var results3= await dblogin.insertLogin(response3);//return True or False
      if (results3) {
        print("Data inserted successfully.");
      } else {
        print("Error inserting data.");
      }
    } else {
      print("Data is available.");
    }
    if (PCdata == null || PCdata.isEmpty ) {
      var response4 = await api.getApi("https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/product_brand/get/");
      var results4= await dbProductCategory.insertProductCategory(response4);//return True or False
      if (results4) {
        print("Data inserted successfully.");
      } else {
        print("Error inserting data.");
      }
    } else {
      print("Data is available.");
    }
    showAllTables();
  }


  // void initializeData() async{
  //    final api = ApiServices();
  //    final db = DBHelperProducts();
  //    final dbowner = DBHelperOwner();
  //    final dblogin=DBHelperLogin();
  //    final dbProductCategory=DBHelperProductCategory();
  //    var response = await api.getApi("https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/product/record");
  //    var results= await db.insertProductsData(response);  //return True or False
  //    //print(results.toString());
  //    var response2 = await api.getApi("https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/AddAhop/record/");
  //    var results2 = await dbowner.insertOwnerData(response2);   //return True or False
  //    //print(results2.toString());
  //    var response4 = await api.getApi("https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/login/get/");
  //    var results4= await dblogin.insertLogin(response4);//return True or False
  //    //print(results4.toString());
  //    var response5 = await api.getApi("https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/product_brand/get/");
  //    var results5= await dbProductCategory.insertProductCategory(response5);//return True or False
  //    print(results5.toString());
  //    showAllTables();
  // }
  Future<void> update() async {
    final db = DBHelperProducts();
    final dbowner = DBHelperOwner();
    final dblogin=DBHelperLogin();
    final dbordermaster= DBOrderMasterGet();
    final dborderdetails= DBOrderMasterGet();
    final dborderbookingstatus= DBOrderMasterGet();
    final dbProductCategory=DBHelperProductCategory();
    final dbnetbalance=DBOrderMasterGet();
    print("DELETING.......................................");
    await db.deleteAllRecords();
    await dbowner.deleteAllRecords();
    await dblogin.deleteAllRecords();
    await dbProductCategory.deleteAllRecords();
    await dbordermaster.deleteAllRecords();
    await dborderdetails.deleteAllRecords();
    await dbnetbalance.deleteAllRecords();
    await dborderbookingstatus.deleteAllRecords();
  }
  Future<void> showOrderMaster() async {
    print("************Tables SHOWING**************");
    print("************Order Master**************");
    final db = DBHelperOrderMaster();

    var data = await db.getOrderMasterDB();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Order Master is $co");

  }
  Future<void> showReturnForm() async {
    print("************Tables SHOWING**************");
    print("************Return Form**************");
    final db = DBHelperReturnForm();

    var data = await db.getReturnFormDB();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Return Form is $co");

  }

  Future<void> showRecoveryForm() async {
    print("************Tables SHOWING**************");
    print("************Recovery Form**************");
    final db = DBHelperRecoveryForm();

    var data = await db.getRecoveryFormDB();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Recovery Form is $co");

  }

  Future<void> showShop() async {
    print("************Tables SHOWING**************");
    print("************Shops**************");
    final db = DBHelper();

    var data = await db.getShopDB();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Add Shops is $co");
  }

  Future<void> showShopVisit() async {
    print("************Tables SHOWING**************");
    print("************SHOP VISIT**************");
    final db = DBHelperShopVisit();

    var data = await db.getShopVisit();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of SHOP VISIT is $co");

  }

  Future<void> showStockCheckItems() async {
    print("************Tables SHOWING**************");
    print("************Stock Check Items**************");
    final db = DBHelperShopVisit();

    var data = await db.getStockCheckItems();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Order Details is $co");

  }

  // Future<void> showShopVisit_2nd() async {
  //   print("************Tables SHOWING**************");
  //   print("************SHOP VISIT 2nd**************");
  //   final db = DBHelperShopVisit_2nd();
  //
  //   var data = await db.getShopVisit_2nd();
  //   int co = 0;
  //   for(var i in data!){
  //     co++;
  //     print("$co | ${i.toString()} \n");
  //   }
  //   print("TOTAL of SHOP VISIT 2nd is $co");
  //
  // }


  Future<void> showOrderDetails() async {
    print("************Tables SHOWING**************");
    print("************Order Details**************");
    final db = DBHelperOrderMaster();

    var data = await db.getOrderDetails();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Order Details is $co");

  }

  Future<void> showAttendance() async {
    print("************Tables SHOWING**************");
    print("************Attendance In**************");
    final db = DBHelperProductCategory();

    var data = await db.getAllAttendance();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Attendance In is $co");

  }
  Future<void> showAttendanceOut() async {
    print("************Tables SHOWING**************");
    print("************Attendance Out**************");
    final db = DBHelperProductCategory();

    var data = await db.getAllAttendanceOut();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Attendance Out is $co");

  }

  Future<void> showReturnFormDetails() async {
    print("************Tables SHOWING**************");
    print("************Return Form Details**************");
    final db = DBHelperReturnForm();

    var data = await db.getReturnFormDetailsDB();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Return Form Details is $co");

  }



  Future<void> showAllTables() async {
    print("************Tables SHOWING**************");
    print("************Tables Products**************");
    final db = DBHelperProducts();
    final dbowner = DBHelperOwner();
    final dblogin = DBHelperLogin();
    final dbPC = DBHelperProductCategory();
    final dbordermaster = DBOrderMasterGet();
    final dborderdetails = DBOrderMasterGet();
    final dborderbookingstatus = DBOrderMasterGet();
    final dbnetbalance = DBOrderMasterGet();
    final dbaccounts = DBOrderMasterGet();

    var data = await db.getProductsDB();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Products is $co");

    print("************Tables Owners**************");
    co=0;
    data = await dbowner.getOwnersDB();
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Owners is $co");

    print("************Logins Owners**************");
    co=0;
    data = await dblogin.getAllLogins();
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Logins is $co");

    print("************ProductsCategories Owners**************");
    co=0;
    data = await dbPC.getAllPCs();
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Products Categories is $co");

    print("************Tables OrderMaster**************");
    co=0;
    data = await dbordermaster.getOrderMasterDB();
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of OrderMaster is $co");

    print("************Tables Order Details**************");
    co=0;
    data = await dborderdetails.getOrderDetailsDB();
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of OrderDetails is $co");

    print("************Tables Order Booking Status**************");
    co=0;
    data = await dborderbookingstatus.getOrderBookingStatusDB();
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of OrderBooking Status is $co");

    print("TOTAL of netBalance is $co");

    print("************Tables Net Balance**************");
    co=0;
    data = await dbnetbalance.getNetBalanceDB();
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Net Balance is $co");

    print("************Tables Accounts**************");
    co=0;
    data = await dbaccounts.getAccoutsDB();
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Accounts is $co");

  }

}