// import 'package:flutter/material.dart';
//
// import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:nanoid/async.dart';
// import 'package:order_booking_shop/API/Globals.dart';
// import 'package:order_booking_shop/Databases/DBHelperShopVisit.dart';
// import 'package:order_booking_shop/View_Models/StockCheckItems.dart';
// import 'package:order_booking_shop/Views/HomePage.dart';
// import '../API/DatabaseOutputs.dart';
// import '../Databases/OrderDatabase/DBHelperOwner.dart';
// import '../Databases/OrderDatabase/DBHelperProducts.dart';
// import '../Databases/OrderDatabase/DBProductCategory.dart';
// import '../Models/ProductsModel.dart';
// import '../Models/ShopVisitModels.dart';
// import '../Models/StockCheckItems.dart';
// import '../View_Models/OrderViewModels/ProductsViewModel.dart';
// import '../View_Models/ShopVisitViewModel.dart';
// import 'FinalOrderBookingPage.dart';
//
// void main() {
//   runApp( MaterialApp(
//       home: ShopVisit( onBrandItemsSelected: (String ) {  })
//
//   ),
//   );
// }
//
// class ShopVisit extends StatefulWidget {
//   final Function(String) onBrandItemsSelected;
// // Add this line
//
//   const ShopVisit({
//     Key? key,
//     required this.onBrandItemsSelected,
//
//   }) : super(key: key);
//
//   @override
//   _ShopVisitState createState() => _ShopVisitState();
// }
//
// class _ShopVisitState extends State<ShopVisit> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   //final productsViewModel = Get.put(ProductsViewModel());
//   TextEditingController ShopNameController = TextEditingController();
//   TextEditingController _brandDropDownController = TextEditingController();
//   TextEditingController BookerNameController = TextEditingController();
//
//   final shopisitViewModel = Get.put(ShopVisitViewModel());
//   final stockcheckitemsViewModel = Get.put(StockCheckItemsViewModel());
//   int? shopVisitId;
//   int? stockcheckitemsId;
//   String selectedShopOwner = '';
//   String selectedOwnerContact= '';
//   String selectedShopOrderNo = '';
//   List<Map<String, dynamic>> shopOwners = [];
//
//   DBHelperOwner dbHelper = DBHelperOwner();
//   List<String> dropdownItems5 = [];
//   List<String> dropdownItems = [];
//   List<String> brandDropdownItems = [];
//   String selectedItem ='';
//   String? selectedDropdownValue;
//   String selectedBrand = '';
//   List<String> selectedProductNames = [];
//   // Add an instance of ProductsViewModel
//   ProductsViewModel productsViewModel = Get.put(ProductsViewModel());
//
//   get shopData => null;
//
//   void navigateToNewOrderBookingPage(String selectedBrandName) async {
//     // Set the selected shop name without navigation
//     setState(() {
//       selectedItem = selectedBrandName;
//     });
//   }
//   List<StockCheckItem> stockCheckItems = [StockCheckItem()];
//   int serialNo = 1;
//   final shopVisitViewModel = Get.put(ShopVisitViewModel());
//   ImagePicker _imagePicker = ImagePicker();
//   File? _imageFile;
//   bool checkboxValue1 = false;
//   bool checkboxValue2 = false;
//   bool checkboxValue3 = false;
//   bool checkboxValue4 = false;
//   String feedbackController = '';
//   Uint8List? _imageBytes;
//
//
//   @override
//   void initState() {
//
//     super.initState();
//     //selectedDropdownValue = dropdownItems[0]; // Default value
//     _fetchBrandItemsFromDatabase();
//     //fetchShopData();
//     fetchShopNames();
//     onCreatee();
//     fetchProductsNamesByBrand();
//
//   }
//   // void fetchShopData() async {
//   //   List<dynamic> shopNames = await dbHelper.getShopNames();
//   //
//   //   setState(() {
//   //     // Explicitly cast each element to String
//   //     dropdownItems = shopNames.map((dynamic item) => item.toString()).toSet().toList();
//   //   });
//   // }
//
//   Future<void> onCreatee() async {
//     DatabaseOutputs db = DatabaseOutputs();
//     await db.showShopVisit();
//     await db.showStockCheckItems();
//     // DatabaseOutputs outputs = DatabaseOutputs();
//     //  outputs.checkFirstRun();
//   }
//   Future<void> fetchShopNames() async {
//     String userCity = userCitys;
//     List<dynamic> shopNames = await dbHelper.getShopNamesForCity(userCity);
//     shopOwners = (await dbHelper.getOwnersDB())!;
//     setState(() {
//       // Explicitly cast each element to String
//       dropdownItems = shopNames.map((dynamic item) => item.toString()).toSet().toList();
//     });
//   }
//
//   // Method to fetch brand items from the database.
//   void _fetchBrandItemsFromDatabase() async {
//     DBHelperProducts dbHelper = DBHelperProducts();
//     List<String> brandItems = await dbHelper.getBrandItems();
//
//     // Remove duplicates from the shopNames list
//     List<String> uniqueBrandNames = brandItems.toSet().toList();
//
//     // Set the retrieved brand items in the state.
//     setState(() {
//       brandDropdownItems = uniqueBrandNames;
//     });
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     // final shopData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
//     //
//     // if (shopData != null) {
//     //   // Your code handling shopData when it's not null
//     // } else {
//     //   // Handle the case when shopData is null
//     // }
//
//     // final passedShopName = shopData['shopName']?? 'Defult shop';
//     // final passedOwnerName = shopData['ownerName']??' default owner';
//     // final userName = shopData['user_name']??'fgghf';
//     // final passedOwnerContact =shopData ['ownerContact']?? 'default';
//     // print('Selected Shop Name: $passedShopName');
//     // print('Selected Shop Owner: $passedOwnerName');
//     // print('Selected Owner Contact : $passedOwnerContact');
//     // print(userName);
//     //
//     ShopNameController.text= selectedItem;
//     BookerNameController.text= userNames;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Shop Visit'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Align(
//                       alignment: Alignment.topRight,
//                       child: Text(
//                         ' Date: ${_getFormattedDate()}',
//                         style: TextStyle(fontSize: 16, color: Colors.black),
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     Text(
//                       'Shop Name',
//                       style: TextStyle(fontSize: 16, color: Colors.black),
//                     ),
//                     Container(
//                       height: 30,
//                       child: TypeAheadField<String>(
//                         textFieldConfiguration: TextFieldConfiguration(
//                           controller: TextEditingController(text: selectedItem),
//                           decoration: InputDecoration(
//                             enabled: false,
//                             hintText: '---Select Shop---',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(5.0),
//                             ),
//                             contentPadding: EdgeInsets.symmetric(vertical: 8.0), // Adjust the vertical padding as needed
//                           ),
//                         ),
//                         suggestionsCallback: (pattern) {
//                           return dropdownItems
//                               .where((item) => item.toLowerCase().contains(pattern.toLowerCase()))
//                               .toList();
//                         },
//                         itemBuilder: (context, suggestion) {
//                           return ListTile(
//                             title: Text(suggestion),
//                           );
//                         },
//                         onSuggestionSelected: (suggestion) {
//                           // Validate that the selected item is from the list
//                           if (dropdownItems.contains(suggestion)) {
//                             setState(() {
//                               selectedItem = suggestion;
//                             });
//
//                             for (var owner in shopOwners) {
//                               if (owner['shop_name'] == selectedItem) {
//                                 setState(() {
//                                   selectedShopOwner = owner['owner_name'];
//                                   selectedOwnerContact = owner['owner_contact'];
//                                 });
//                               }
//                             }
//                           }
//                         },
//                       ),
//                     ),
//
//
//                     SizedBox(height: 20.0),
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         'Booker Name',
//                         style: TextStyle(fontSize: 16, color: Colors.black),
//                       ),
//                     ),
//                     Container(
//                       height: 30,
//                       child: TextFormField(enabled: false,
//                         controller: BookerNameController,
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(5.0),
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value!.isEmpty) {
//                             return 'Please enter some text';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         'Brand',
//                         style: TextStyle(fontSize: 16, color: Colors.black),
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Container(
//                             height: 30,
//                             child: TypeAheadFormField<String>(
//                               textFieldConfiguration: TextFieldConfiguration(
//                                 decoration: InputDecoration(
//                                   enabled: false,
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(5.0),
//                                   ),
//                                 ),
//                                 controller: _brandDropDownController,
//                               ),
//                               suggestionsCallback: (pattern) {
//                                 return brandDropdownItems
//                                     .where((item) => item.toLowerCase().contains(pattern.toLowerCase()))
//                                     .toList();
//                               },
//                               itemBuilder: (context, itemData) {
//                                 return ListTile(
//                                   title: Text(itemData),
//                                 );
//                               },
//                               onSuggestionSelected: (itemData) {
//                                 // Validate that the selected item is from the list
//                                 if (brandDropdownItems.contains(itemData)) {
//                                   setState(() {
//                                     _brandDropDownController.text = itemData;
//                                     globalselectedbrand = itemData;
//                                   });
//                                   // Call the callback to pass the selected brand to FinalOrderBookingPage
//                                   widget.onBrandItemsSelected(itemData);
//                                   print('Selected Brand: $itemData');
//                                   print(globalselectedbrand);
//                                 }
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     SizedBox(height: 20),
//                     Align(
//                       alignment: Alignment.center,
//                       child: Text(
//                         'Checklist',
//                         style: TextStyle(fontSize: 16, color: Colors.black),
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         '1-Stock Check (Current Balance)',
//                         style: TextStyle(fontSize: 16, color: Colors.black),
//                       ),
//                     ),
//                     SizedBox(height: 25),
//                     Column(
//                       children: [
//                         Row(
//                           children: [
//                             SizedBox(height: 10),
//                             Text(
//                               'Sr',
//                               style: TextStyle(fontSize: 16, color: Colors.black),
//                             ),
//                             SizedBox(width: 20),
//                             Text(
//                               'Item Description',
//                               style: TextStyle(fontSize: 16, color: Colors.black),
//                             ),
//                             SizedBox(width: 20),
//                             Text(
//                               '            Qty',
//                               style: TextStyle(fontSize: 16, color: Colors.black),
//                             ),
//
//
//                           ],
//                         ),
//                         SizedBox(height: 5),
//                         for (int index = 0; index < stockCheckItems.length; index++)
//                           StockCheckItemRow(
//                             stockCheckItem: stockCheckItems[index],
//                             serialNo: index + 1,
//                             onDelete: () {
//                               deleteStockCheckItem(index);
//                             },
//                             dropdownItems: dropdownItems,
//                             selectedProductNames: selectedProductNames,
//                           ),
//                         SizedBox(height: 10),
//                         ElevatedButton(
//                           onPressed: () {
//                             // Check if all previous rows are filled before adding a new row
//                             bool allRowsFilled = true;
//                             for (int index = 0; index < stockCheckItems.length; index++) {
//                               StockCheckItem item = stockCheckItems[index];
//                               if (item.itemDescriptionController.text.isEmpty || item.qtyController.text.isEmpty) {
//                                 allRowsFilled = false;
//                                 break;
//                               }
//                             }
//
//                             // If all previous rows are filled, add a new row
//                             if (allRowsFilled) {
//                               addStockCheckItem();
//                             } else {
//                               // Show an error message or take appropriate action
//                               // For example, you can display a snackbar or toast indicating that all previous rows must be filled.
//                               print('Please fill all previous rows before adding a new row.');
//                             }
//
//                             // Then, check form validation
//                             if (_formKey.currentState!.validate()) {
//                               // Validation successful, proceed to the next page or save data
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             primary: Colors.green,
//                             onPrimary: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                           ),
//                           child: Text(
//                             'Add Item',
//                             style: TextStyle(
//                               fontSize: 13,
//                             ),
//                           ),
//                         ),
//
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     Column(
//                       children: [
//                         buildRow('2-Performed Store Walkthrough', checkboxValue1, (bool? value) {
//                           if (value != null) {
//                             setState(() {
//                               checkboxValue1 = value;
//                             });
//                           }
//                         }),
//                         buildRow('3-Update Store Planogram', checkboxValue2, (bool? value) {
//                           if (value != null) {
//                             setState(() {
//                               checkboxValue2 = value;
//                             });
//                           }
//                         }),
//                         buildRow('4-Shelf tags and price signage check', checkboxValue3, (bool? value) {
//                           if (value != null) {
//                             setState(() {
//                               checkboxValue3 = value;
//                             });
//                           }
//                         }),
//                         buildRow('5-Expiry date on product reviewed', checkboxValue4, (bool? value) {
//                           if (value != null) {
//                             setState(() {
//                               checkboxValue4 = value;
//                             });
//                           }
//                         }),
//                         SizedBox(height: 20),
//                         ElevatedButton(
//                           onPressed: () async {
//                             try {
//                               final image = await _imagePicker.getImage(source: ImageSource.camera);
//
//                               if (image != null) {
//                                 setState(() {
//                                   _imageFile = File(image.path);
//
//                                   shopData?['imagePath'] = _imageFile!.path;
//
//                                   // Convert the image file to bytes and store it in _imageBytes
//                                   List<int> imageBytesList = _imageFile!.readAsBytesSync();
//                                   _imageBytes = Uint8List.fromList(imageBytesList);
//                                 });
//                                 Fluttertoast.showToast(
//                                   msg: 'Image captured successfully',
//                                 );
//                               } else {
//                                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                                   content: Text('No image selected.'),
//                                 ));
//                               }
//                             } catch (e) {
//                               print('Error capturing image: $e');
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             primary: Colors.green,
//                             onPrimary: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                           ),
//                           child: Text('+ Add Photo'),
//                         ),
//                         SizedBox(height: 10),
// // Display the image
//                         Container(
//                           height: 300,
//                           width: 300,
//                           child: _imageBytes != null
//                               ? Image.memory(
//                             _imageBytes!,
//                             height: 300,
//                             width: 300,
//                             fit: BoxFit.cover,
//                           )
//                               : Icon(
//
//                             Icons.warning,
//                             color: Colors.red,
//                             size: 48,
//                           ),
//                         ),
//
//                         SizedBox(height: 20),
//                         Text('Feedback/ Special Note'),
//                         SizedBox(height: 20.0),
//                         // Feedback or Note Box
//                         Container(
//                           width: double.infinity,
//                           padding: EdgeInsets.all(10.0),
//
//                           decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: TextField(
//                             decoration: InputDecoration(
//                               hintText: 'Feedback or Note',
//                               border: InputBorder.none,
//                             ),
//                             maxLines: 3,
//                             onChanged: (text) {
//                               setState(() {
//                                 feedbackController = text;
//                               });
//                             },
//                           ),
//                         ),
//                         SizedBox(height: 20),
//                         ElevatedButton(
//                           onPressed: () async {  bool allRowsFilled = stockCheckItems.every((item) =>
//                           item.itemDescriptionController.text.isNotEmpty &&
//                               item.qtyController.text.isNotEmpty);
//
//                           if (!allRowsFilled) {
//                             Fluttertoast.showToast(
//                               msg: 'Please fill all stock check items before proceeding.',
//                               toastLength: Toast.LENGTH_SHORT,
//                               gravity: ToastGravity.BOTTOM,
//                               backgroundColor: Colors.red,
//                               textColor: Colors.white,
//                             );
//                             return;
//                           }
//                           if (!checkboxValue1 || !checkboxValue2 || !checkboxValue3 || !checkboxValue4 )  {
//                             Fluttertoast.showToast(
//                               msg: 'Please complete all tasks before proceeding.',
//                               toastLength: Toast.LENGTH_SHORT,
//                               gravity: ToastGravity.BOTTOM,
//                               backgroundColor: Colors.red,
//                               textColor: Colors.white,
//                             );
//
//                             setState(() {
//                               checkboxValue1 = false;
//                               checkboxValue2 = false;
//                               checkboxValue3 = false;
//                               checkboxValue4 = false;
//                             });
//
//                             return;
//                           }  if (_imageFile == null ||
//                               ShopNameController.text.isEmpty ||
//                               BookerNameController.text.isEmpty ||
//                               _brandDropDownController.text.isEmpty) {
//                             Fluttertoast.showToast(
//                               msg: 'Please fulfill all requirements before proceeding.',
//                               toastLength: Toast.LENGTH_SHORT,
//                               gravity: ToastGravity.BOTTOM,
//                               backgroundColor: Colors.red,
//                               textColor: Colors.white,
//                             );
//                             return;
//                           }
//
//
//
//                           if (_imageFile != null || ShopNameController.text.isEmpty || BookerNameController.text.isNotEmpty || BookerNameController.text.isNotEmpty) {
//                             Uint8List imagePath =  _imageBytes!;
//                             var id = await customAlphabet('1234567890', 12);
//                             shopVisitViewModel.addShopVisit(ShopVisitModel(
//                               id: int.parse(id),
//                               shopName: ShopNameController.text,
//                               bookerName: BookerNameController.text,
//                               brand:BookerNameController.text,
//                               date:_getFormattedDate(),
//                               walkthrough: checkboxValue1,
//                               planogram: checkboxValue2,
//                               signage: checkboxValue3,
//                               productReviewed: checkboxValue4,
//                               body: _imageFile!.readAsBytesSync(),
//
//
//                             ));
//
//                             String visitid =
//                             await shopisitViewModel.fetchLastShopVisitId();
//                             shopVisitId = int.parse(visitid);
//
//                             List<Map<String, dynamic>> stockCheckItemsDetails = [];
//                             for (var stockCheckItem in stockCheckItems) {
//                               String selectedItem =
//                                   stockCheckItem.itemDescriptionController.text;
//                               int quantity =
//                                   int.tryParse(stockCheckItem.qtyController.text) ?? 0;
//
//                               stockCheckItemsDetails.add({
//                                 'selectedItem': selectedItem,
//                                 'quantity': quantity,
//                               });
//                             }
//
//
//                             saveStockCheckItems();
//
//                             DBHelperShopVisit dbshop = DBHelperShopVisit();
//
//                             await dbshop.postShopVisitData();
//                             await dbshop.postStockCheckItems();
//
//
//                             Fluttertoast.showToast(
//                               msg: 'Data saved successfully',
//                               toastLength: Toast.LENGTH_SHORT,
//                               gravity: ToastGravity.BOTTOM,
//                               backgroundColor: Colors.green,
//                               textColor: Colors.white,
//                             );
//                           } else {
//                             Fluttertoast.showToast(
//                               msg: 'Please fulfill all requirements before proceeding.',
//                               toastLength: Toast.LENGTH_SHORT,
//                               gravity: ToastGravity.BOTTOM,
//                               backgroundColor: Colors.red,
//                               textColor: Colors.white,
//                             );
//                             return;
//                           }
//
//
//                           Map<String, dynamic> dataToPass = {
//                             'shopName': ShopNameController.text ,
//                             'ownerName': selectedShopOwner.toString(), //'date': _getFormattedDate(),
//                             'selectedBrandName': _brandDropDownController.text,
//                             'userName': BookerNameController.text,
//                             'ownerContact': selectedOwnerContact.toString(),
//
//                             // 'itemDescription':stockCheckItems[0].itemDescriptionController.text,
//                             // 'quantity':stockCheckItems[0].qtyController.text
//
//                           };
//
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => FinalOrderBookingPage(),settings: RouteSettings(arguments: dataToPass)),
//                           ); // Navigate to the FinalOrderBookingPage
//                           }, style: ElevatedButton.styleFrom(
//                           primary: Colors.green,
//                           onPrimary: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                         ),
//                           child: Text('+ Order Booking Form'),
//                         ),
//                         SizedBox(height: 20),
//
//
//
//                         ElevatedButton(
//                           onPressed: () async {  bool allRowsFilled = stockCheckItems.every((item) =>
//                           item.itemDescriptionController.text.isNotEmpty &&
//                               item.qtyController.text.isNotEmpty);
//
//                           if (!allRowsFilled) {
//                             Fluttertoast.showToast(
//                               msg: 'Please fill all stock check items before proceeding.',
//                               toastLength: Toast.LENGTH_SHORT,
//                               gravity: ToastGravity.BOTTOM,
//                               backgroundColor: Colors.red,
//                               textColor: Colors.white,
//                             );
//                             return;
//                           }
//                           if (!checkboxValue1 || !checkboxValue2 || !checkboxValue3 || !checkboxValue4 ) {
//                             Fluttertoast.showToast(
//                               msg: 'Please complete all tasks before proceeding.',
//                               toastLength: Toast.LENGTH_SHORT,
//                               gravity: ToastGravity.BOTTOM,
//                               backgroundColor: Colors.red,
//                               textColor: Colors.white,
//                             );
//
//                             setState(() {
//                               checkboxValue1 = false;
//                               checkboxValue2 = false;
//                               checkboxValue3 = false;
//                               checkboxValue4 = false;
//                             });
//
//                             return;
//                           }  if (_imageFile == null ||
//                               ShopNameController.text.isEmpty ||
//                               BookerNameController.text.isEmpty ||
//                               _brandDropDownController.text.isEmpty) {
//                             Fluttertoast.showToast(
//                               msg: 'Please fulfill all requirements before proceeding.',
//                               toastLength: Toast.LENGTH_SHORT,
//                               gravity: ToastGravity.BOTTOM,
//                               backgroundColor: Colors.red,
//                               textColor: Colors.white,
//                             );
//                             return;
//                           }
//
//
//
//                           if (_imageFile != null || ShopNameController.text.isEmpty || BookerNameController.text.isNotEmpty || BookerNameController.text.isNotEmpty) {
//                             Uint8List imagePath =  _imageBytes!;
//                             var id = await customAlphabet('1234567890', 12);
//                             shopVisitViewModel.addShopVisit(ShopVisitModel(
//                               id: int.parse(id),
//                               shopName: ShopNameController.text,
//                               bookerName: BookerNameController.text,
//                               brand:BookerNameController.text,
//                               date:_getFormattedDate(),
//                               walkthrough: checkboxValue1,
//                               planogram: checkboxValue2,
//                               signage: checkboxValue3,
//                               productReviewed: checkboxValue4,
//                               body: _imageFile!.readAsBytesSync(),
//
//
//                             ));
//
//                             String visitid =
//                             await shopisitViewModel.fetchLastShopVisitId();
//                             shopVisitId = int.parse(visitid);
//
//                             List<Map<String, dynamic>> stockCheckItemsDetails = [];
//                             for (var stockCheckItem in stockCheckItems) {
//                               String selectedItem =
//                                   stockCheckItem.itemDescriptionController.text;
//                               int quantity =
//                                   int.tryParse(stockCheckItem.qtyController.text) ?? 0;
//
//                               stockCheckItemsDetails.add({
//                                 'selectedItem': selectedItem,
//                                 'quantity': quantity,
//                               });
//                             }
//
//
//                             saveStockCheckItems();
//
//                             DBHelperShopVisit dbshop = DBHelperShopVisit();
//
//                             await dbshop.postShopVisitData();
//                             await dbshop.postStockCheckItems();
//
//
//                             Fluttertoast.showToast(
//                               msg: 'Data saved successfully',
//                               toastLength: Toast.LENGTH_SHORT,
//                               gravity: ToastGravity.BOTTOM,
//                               backgroundColor: Colors.green,
//                               textColor: Colors.white,
//                             );
//                           } else {
//                             Fluttertoast.showToast(
//                               msg: 'Please fulfill all requirements before proceeding.',
//                               toastLength: Toast.LENGTH_SHORT,
//                               gravity: ToastGravity.BOTTOM,
//                               backgroundColor: Colors.red,
//                               textColor: Colors.white,
//                             );
//                             return;
//                           }
//
//
//                           Map<String, dynamic> dataToPass = {
//                             'shopName': ShopNameController.text ,
//                             'ownerName': selectedShopOwner.toString(), //'date': _getFormattedDate(),
//                             'selectedBrandName': _brandDropDownController.text,
//                             'userName': BookerNameController.text,
//                             'ownerContact': selectedOwnerContact.toString(),
//
//                             // 'itemDescription':stockCheckItems[0].itemDescriptionController.text,
//                             // 'quantity':stockCheckItems[0].qtyController.text
//
//                           };
//
//
//                           DBHelperShopVisit dbshop = DBHelperShopVisit();
//
//                           await dbshop.postShopVisitData();
//                           await dbshop.postStockCheckItems();
//                           Navigator.pop(context);
//                           // Stop the timer on the home page
//                           HomePage();
//                           },  style: ElevatedButton.styleFrom(
//                           primary: Colors.green,
//                           onPrimary: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                         ),
//                           child: Text('No Order'),
//                         ),
//                         SizedBox(height: 50),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void saveStockCheckItems() async {
//     List<StockCheckItemsModel> stockCheckItemsList = [];
//
//     for (var stockCheckItem in stockCheckItems) {
//       final stockCheckItems = StockCheckItemsModel(
//         shopvisitId: shopVisitId ?? 0,
//         itemDesc: stockCheckItem.itemDescriptionController.text, // Access the text value
//         qty: int.tryParse(stockCheckItem.qtyController.text) ?? 0,
//       );
//       stockCheckItemsList.add(stockCheckItems);
//     }
//
//     await DBHelperShopVisit().addStockCheckItems(stockCheckItemsList);
//   }
//
//
//   Widget buildRow(String text, bool value, void Function(bool?) onChanged) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           text,
//           style: TextStyle(fontSize: 14, color: Colors.black),
//         ),
//         Row(
//           children: [
//             Checkbox(
//               value: value,
//               onChanged: onChanged,
//               checkColor: Colors.white,
//               activeColor: Colors.green,
//             ),
//             if (!value)
//               Icon(
//                 Icons.warning,
//                 color: Colors.red,
//                 size: 24,
//               ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   void addStockCheckItem() {
//     setState(() {
//       stockCheckItems.add(StockCheckItem());
//     });
//   }
//
//   void deleteStockCheckItem(int index) {
//     setState(() {
//       stockCheckItems.removeAt(index);
//     });
//   }
//
//   String _getFormattedDate() {
//     final now = DateTime.now();
//     final formatter = DateFormat('dd-MMM-yyyy [HH:mm a]');
//     return formatter.format(now);
//   }
//
//   void onBrandSelected(String selectedBrand) {
//     setState(() {
//       _brandDropDownController.text = selectedBrand;
//     });
//   }
//
//   Future<void> fetchProductsNamesByBrand() async {
//     String selectedBrand = globalselectedbrand;
//     DBHelperProducts dbHelper = DBHelperProducts();
//     List<dynamic> productNames = await dbHelper.getProductsNamesByBrand(selectedBrand);
//
//     setState(() {
//       // Explicitly cast each element to String
//       dropdownItems5 = productNames.map((dynamic item) => item.toString()).toSet().toList();
//     });
//   }
//
//
//
//
// }
//
// class StockCheckItem {
//   TextEditingController itemDescriptionController = TextEditingController();
//   TextEditingController qtyController = TextEditingController();
//   String? selectedDropdownValue;
// }
//
// class StockCheckItemRow extends StatelessWidget {
//   final StockCheckItem stockCheckItem;
//   final int serialNo;
//   final VoidCallback onDelete;
//   final List<String> dropdownItems;
//   final List<String> selectedProductNames;
//   final productsViewModel = Get.put(ProductsViewModel());
//   StockCheckItemRow({
//     required this.stockCheckItem,
//     required this.serialNo,
//     required this.onDelete,
//     required this.dropdownItems,
//     required this.selectedProductNames,
//
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//     Row(
//     children: [
//     Text(
//     '$serialNo',
//       style: TextStyle(fontSize: 16, color: Colors.black),
//     ),
//     SizedBox(width: 20),
//     Container(
//     width: 200,
//     height: 50,
//     margin: const EdgeInsets.all(0.5),
//     child: Padding(
//     padding: const EdgeInsets.symmetric(vertical: 0.50, horizontal: 0.10),
//     child: TypeAheadFormField<ProductsModel>(
//     textFieldConfiguration: TextFieldConfiguration(
//     decoration: InputDecoration(
//     border: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(5.0),
//     ),
//     contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 3.0),
//     ),
//     controller: stockCheckItem.itemDescriptionController,
//     style: TextStyle(fontSize: 12),
//     maxLines: null,
//     ),
//     suggestionsCallback: (pattern) async {
//     await productsViewModel.fetchProductsByBrand(globalselectedbrand);
//
//     return productsViewModel.allProducts
//         .where((product) =>
//     product.product_name?.toLowerCase().contains(pattern.toLowerCase()) ?? false)
//         .toList();
//     },
//     itemBuilder: (context, itemData) {
//     return ListTile(
//     title: Text(itemData.product_name ?? ''),
//     tileColor: stockCheckItem.selectedDropdownValue == itemData.product_name
//     ? Colors.grey
//         : Colors.transparent,
//     );
//     },
//     onSuggestionSelected: (itemData) {
//     // Only set the state if the selected item is in the suggestions list
//     if (productsViewModel.allProducts.contains(itemData)) {
//     stockCheckItem.selectedDropdownValue = itemData.product_name;
//     stockCheckItem.itemDescriptionController.text = itemData.product_name ?? '';
//     }
//     },
//     suggestionsBoxDecoration: SuggestionsBoxDecoration(),
//     ),
//     ),
//     ),
//     SizedBox(width: 10),
//     Container(
//     width: 60,
//     height: 50,
//     child: TextFormField(
//     controller: stockCheckItem.qtyController,
//     decoration: InputDecoration(
//     border: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(5.0),
//     ),
//     ),
//     keyboardType: TextInputType.number,
//     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//     style: TextStyle(fontSize: 12), // Only allow digits
//     ),
//     ),
//     SizedBox(width: 0),
//     IconButton(
//     icon: Icon(Icons.delete_outline, size: 20, color: Colors.red),
//     onPressed: onDelete,
//     ),
//     ],
//     ),
//     // Optionally, you can add a SizedBox for spacing between columns
//     SizedBox(height: 10),
//     ],
//     );
//     }}