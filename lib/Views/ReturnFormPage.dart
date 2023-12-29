import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nanoid/async.dart';
import 'package:order_booking_shop/API/Globals.dart';
import 'package:order_booking_shop/Databases/DBHelperReturnForm.dart';
import 'package:order_booking_shop/Databases/OrderDatabase/DBOrderMasterGet.dart';
import 'package:order_booking_shop/Models/ReturnFormDetails.dart';
import 'package:order_booking_shop/View_Models/OrderViewModels/ReturnFormViewModel.dart';
import 'package:sqflite/sqflite.dart';
import '../API/DatabaseOutputs.dart';
import '../Models/ReturnFormModel.dart';
import '../View_Models/OrderViewModels/ReturnFormDetailsViewModel.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:order_booking_shop/Databases/OrderDatabase/DBOrderMasterGet.dart';

import 'HomePage.dart';

class ProductController extends GetxController {
  final DBOrderMasterGet dbHelper = DBOrderMasterGet();

  RxList<String> productNames = <String>[].obs;

  Future<void> fetchProductData(String shopName) async {
    List<String> names = await dbHelper.getOrderDetailsProductNames();
    productNames.assignAll(names);
  }
}


void main() {
  runApp(MaterialApp(
    home: ReturnFormPage(),
  ));
}


class ReturnFormPage extends StatefulWidget {
  @override
  _ReturnFormPageState createState() => _ReturnFormPageState();
}

class _ReturnFormPageState extends State<ReturnFormPage> {
  final returnformdetailsViewModel = Get.put(ReturnFormDetailsViewModel());
  final returnformViewModel = Get.put(ReturnFormViewModel());
  TextEditingController _selectedShopController = TextEditingController();
  List<Widget> dynamicRows = [];
  List<TextEditingController> firstTypeAheadControllers = [];
  List<TextEditingController> qtyControllers = [];
  List<TextEditingController> secondTypeAheadControllers = [];
  int? returnformid;
  int? returnformdetailsid;
  List<String> dropdownItems = [];
  List<Map<String, dynamic>> shopOwners = [];
  List<String> dropdownItems2 = [];
  List<Map<String, dynamic>> productOwners = [];
  DBOrderMasterGet dbHelper = DBOrderMasterGet();
  final ProductController productController = Get.put(ProductController());


  @override
  void initState() {
    super.initState();
    // Initialize with one row.
    addNewRowControllers();
    dynamicRows.add(buildTypeAheadRow(0));
    onCreatee();
    fetchShopData();
    //fetchProductData();
    // Fetch product data using GetX controller
    // Fetch product data using GetX controller
    // _fetchProductData();
    // Fetch product data using GetX controller
    fetchProductDataForSelectedShop(_selectedShopController.text);

  }
  Future<void> updateQuantityField(String selectedProductName, int index) async {
    String? quantity = await fetchQuantityForProduct(selectedProductName);
    if (quantity != null) {
      setState(() {
        qtyControllers[index].text = quantity;
      });
    }
  }


  // Future<void> _fetchProductData() async {
  //   await productController.fetchProductData();
  //   setState(() {
  //     dropdownItems2 = productController.productNames.toList();
  //   });
  //   return Future.value(); // or simply 'return;' to return a Future<void>
  // }
// Update this method to fetch product data for the selected shop
  void fetchProductDataForSelectedShop(String selectedShopName) async {
    await productController.fetchProductData(selectedShopName);
    setState(() {
      dropdownItems2 = productController.productNames.toList();
    });
  }

  void fetchShopData() async {
    List<String> shopNames = await dbHelper.getOrderMasterShopNames();
    shopOwners = (await dbHelper.getOrderMasterDB())!;

    setState(() {
      dropdownItems = shopNames.toSet().toList();
    });
  }

  String getOrderNoForSelectedShop() {
    String selectedShopName = _selectedShopController.text;
    for (var shop in shopOwners) {
      if (shop['shop_name'] == selectedShopName) {
        return shop['order_no'];
      }
    }
    return ''; // Return an empty string if not found (handle this case accordingly)
  }

  //
  // void fetchProductData() async {
  //   List<String> productNames = await dbHelper.getOrderDetailsProductNames();
  //   setState(() {
  //     dropdownItems2 =  productNames.toSet().toList();
  //   });
  // }

  Future<void> onCreatee() async {
    DatabaseOutputs db = DatabaseOutputs();
    await db.showReturnForm();
    await db.showReturnFormDetails();
    //DatabaseOutputs outputs = DatabaseOutputs();
    // outputs.checkFirstRun();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Return form'),
        backgroundColor: Colors.white10,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(10.0),
              color: Colors.white10,
              child: Column(
                children: [
                  // Added top row with serial number information
                  buildTypeaheadWithDateRow(),
                  buildTopSerialNoRow(),
                  ...dynamicRows,
                  buildAddRowButton(),
                  buildSubmitButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildTopSerialNoRow() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              '      Item',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              ' QTy',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          ),
          SizedBox(
            width: 150,
            child: Text(
              'Reason                                                  ',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTypeaheadWithDateRow() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black45,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white10,
              ),
              child: TypeAheadField<String>(
                suggestionsCallback: (pattern) async {
                  return dropdownItems
                      .where((option) =>
                      option.toLowerCase().contains(pattern.toLowerCase()))
                      .toList();
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(
                      suggestion,
                      style: TextStyle(fontSize: 12),
                    ),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    _selectedShopController.text = suggestion;
                    selectedorderno = getOrderNoForSelectedShop();
                    print('Selected Shop: $suggestion, Order No: ${selectedorderno}');
                    fetchProductDataForSelectedShop(suggestion);
                  });
                },

                textFieldConfiguration: TextFieldConfiguration(
                  controller: _selectedShopController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '--Select Shop--',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    filled: true,
                    fillColor: Colors.white10,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 25),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Date: ',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  _getCurrentDate(),
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTypeAheadRow(int index) {
    if (index >= firstTypeAheadControllers.length ||
        index >= qtyControllers.length ||
        index >= secondTypeAheadControllers.length) {
      addNewRowControllers();
    }

    TextEditingController firstController =
    firstTypeAheadControllers[index];
    TextEditingController qtyController = qtyControllers[index];
    TextEditingController secondController =
    secondTypeAheadControllers[index];

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${index + 1}. ',
                style: TextStyle(fontSize: 16),
              ),
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.white,
                  ),
                  child: TypeAheadField<String>(
                    suggestionsCallback: (pattern) async {
                      return dropdownItems2
                          .where((option) =>
                          option.toLowerCase().contains(pattern.toLowerCase()))
                          .toList();
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(
                          suggestion,
                          style: TextStyle(fontSize: 12),
                        ),
                      );
                    },
                    onSuggestionSelected: (suggestion) async {
                      setState(() {
                        firstController.text = suggestion;
                      });
                      await updateQuantityField(suggestion, index);

                    },
                    textFieldConfiguration: TextFieldConfiguration(
                      decoration: InputDecoration(
                        border: InputBorder.none, // Remove the underline beneath the border
                        contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                      ),
                      controller: firstController,
                      style: TextStyle(fontSize: 12),
                      maxLines: null,
                    ),
                  ),
                ),
              ),


              SizedBox(width: 5),
              Container(
                height: 50,
                width: 50,
                child: TextFormField(

                  controller: qtyController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    hintText: 'Qty', // Placeholder text
                    hintStyle: TextStyle(fontSize: 12), // Set the size of the placeholder
                    contentPadding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0), // Adjust padding as needed
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    TextInputFormatter.withFunction(
                          (oldValue, newValue) {
                        // Allowing backspace
                        if (newValue.text.isEmpty) {
                          return newValue;
                        }
                        // Allowing digits only
                        if (int.tryParse(newValue.text) != null) {
                          return newValue;
                        } else {
                          return oldValue;
                        }
                      },
                    ),
                  ],
                  style: TextStyle(fontSize: 12),
                ),
              ),



              SizedBox(width: 5),
              Container(
                height: 50,
                width: 115,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.white,
                ),
                child: TypeAheadField<String>(
                  suggestionsCallback: (pattern) async {
                    return ['Damage', 'Complaint', 'Expire', 'closed', 'Others']
                        .where((option) =>
                        option.toLowerCase().contains(pattern.toLowerCase()))
                        .toList();
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          suggestion,
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      secondController.text = suggestion;
                    });
                  },
                  textFieldConfiguration: TextFieldConfiguration(
                    decoration: InputDecoration(
                      border: InputBorder.none, // Remove the underline beneath the border
                      contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                    ),
                    controller: secondController,
                    style: TextStyle(fontSize: 12),
                    maxLines: null,
                  ),
                ),
              ),


              Container(
                child: IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red, size: 17),
                  onPressed: () {
                    setState(() {
                      dynamicRows.removeAt(index);
                      firstTypeAheadControllers.removeAt(index);
                      qtyControllers.removeAt(index);
                      secondTypeAheadControllers.removeAt(index);
                      // Update serial numbers after deletion
                      for (int i = index; i < dynamicRows.length; i++) {
                        dynamicRows[i] = buildTypeAheadRow(i);
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildAddRowButton() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            dynamicRows.add(buildTypeAheadRow(dynamicRows.length));
          });
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.green,
          onPrimary: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Add Row',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }
  Widget buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: () async {


          if (_selectedShopController.text.isNotEmpty) {
            var id = await customAlphabet('1234567890', 5);
            returnformViewModel.addReturnForm(ReturnFormModel(
              returnId:int.parse(id),
              shopName: _selectedShopController.text,
              date: _getCurrentDate(),
            ));

            String visitid =
            await returnformViewModel.fetchLastReturnFormId();
            returnformid = int.parse(visitid);

            for (int i = 0; i < firstTypeAheadControllers.length; i++) {
              var id = await customAlphabet('1234567890', 12);
              returnformdetailsViewModel.addReturnFormDetail(
                ReturnFormDetailsModel(
                  id: int.parse(id),
                  returnformId: returnformid ?? 0,
                  productName: firstTypeAheadControllers[i].text,
                  reason: secondTypeAheadControllers[i].text,
                  quantity: qtyControllers[i].text,
                ),
              );
            }
          }

          DBHelperReturnForm dbreturnform = DBHelperReturnForm();

          await dbreturnform.postReturnFormTable();
          await dbreturnform.postReturnFormDetails();

          onCreatee();

          // Move the navigation inside the onPressed callback
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        },

        style: ElevatedButton.styleFrom(
          primary: Colors.green,
          onPrimary: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Submit',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }


  String _getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MMM-yyyy').format(now);
    return formattedDate;
  }

  void addNewRowControllers() {
    firstTypeAheadControllers.add(TextEditingController());
    qtyControllers.add(TextEditingController());
    secondTypeAheadControllers.add(TextEditingController());
    }


  Future<String?> fetchQuantityForProduct(String productName) async {
    try {
      final Database db = await productController.dbHelper.db;
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

}