import 'dart:io';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nanoid/nanoid.dart';
import 'package:order_booking_shop/API/Globals.dart';
import 'package:order_booking_shop/Views/HomePage.dart';
import 'package:order_booking_shop/Views/ShopListPage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart' as io;
import 'package:share/share.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/OrderDatabase/DBHelperOrderMaster.dart';
import '../Models/OrderModels/OrderDetailsModel.dart';
import '../Models/OrderModels/OrderMasterModel.dart';
import '../View_Models/OrderViewModels/OrderDetailsViewModel.dart';
import '../View_Models/OrderViewModels/OrderMasterViewModel.dart';

List<String> creditLimitOptions = ['Option 1', 'Option 2', 'Option 3'];


class OrderBooking_2ndPage extends StatefulWidget {
  @override
  _OrderBooking_2ndPageState createState() => _OrderBooking_2ndPageState();
}

class _OrderBooking_2ndPageState extends State<OrderBooking_2ndPage> {
  bool isDataSavedInApex = true;
  bool isReConfirmButtonPressed = false;

  bool isOrderConfirmed = false;
  final ordermasterViewModel = Get.put(OrderMasterViewModel());
  final orderdetailsViewModel = Get.put(OrderDetailsViewModel());
  String currentUserId = '';
  int serialCounter = 1;
  String currentMonth = DateFormat('MMM').format(DateTime.now());
  final TextEditingController orderIDController = TextEditingController();
  String currentOrderId = '';

// String currentMonth = DateFormat('MMM').format(DateTime.now());


  @override
  void initState() {
    // Initially add two rows

    _loadCounter();


  }

  // // You can maintain this as a global variable or retrieve it from somewhere
  // _loadCounter() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState((){
  //     serialCounter = prefs.getInt('serialCounter') ?? 1;
  //     currentMonth = prefs.getString('currentMonth') ?? currentMonth;
  //     currentUserId = prefs.getString('currentUserId') ?? ''; // Add this line
  //   });
  // }
  //
  // _saveCounter() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setInt('serialCounter', serialCounter);
  //   await prefs.setString('currentMonth', currentMonth);
  //   await prefs.setString('currentUserId', currentUserId); // Add this line
  // }
  //
  // String generateNewOrderId( String userId, String currentMonth) {
  //   if (this.currentUserId != userId) {
  //     // Reset serial counter when the userId changes
  //     serialCounter = 1;
  //     this.currentUserId = userId;
  //   }
  //
  //   if (this.currentMonth != currentMonth) {
  //     // Reset serial counter when the month changes
  //     serialCounter = 1;
  //     this.currentMonth = currentMonth;
  //   }
  //
  //   String orderId =
  //       "$userId-$currentMonth-${serialCounter.toString().padLeft(3, '0')}";
  //   serialCounter++;
  //   _saveCounter(); // Save the updated counter value, current month, and userId
  //   return orderId;
  // }

  @override
  Widget build(BuildContext context) {

    print(orderMasterid);
    final data =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

   // final orderId = data['orderId'];
    final orderDate = data['orderDate'];
    final user_name = data ['userName'];
    final shopName = data ['shopName'];
    final creditLimit = data['creditLimit'];
    final discount = data['discount'];
    final subTotal = data['subTotal'];
    final brand = data ['brand'];
    final ownerName= data['ownerName'];
    final phoneNo= data['phoneNo'];
    final total = data ['total'];
    final date = data ['date'];

    final requiredDelivery = data['requiredDelivery'];
    final rowDataDetails = data['rowDataDetails'] as List<Map<String, dynamic>>;
    print(creditLimit);
    print(discount);
    print(subTotal);
    print(requiredDelivery);
    //orderMasterid= orderId;

    final selectedItems = <String>[];
    final quantities = <int>[];
    final rates = <int>[];
    final totalAmounts = <int>[];

    for (final rowData in rowDataDetails) {
      final selectedItem = rowData['selectedItem'] as String;
      final quantity = rowData['quantity'] as int;
      final rate = rowData['rate'] as int;
      final totalAmount = rowData['totalAmount'] as int;

      selectedItems.add(selectedItem);
      quantities.add(quantity);
      rates.add(rate);
      totalAmounts.add(totalAmount);
    }

    final totalAmount =
    totalAmounts.fold<int>(0, (sum, amount) => sum + amount);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildSizedBox(30),
              buildText('Order#'),
              buildTextFormField(30, orderMasterid, readOnly: true),
              buildSizedBox(10),
              buildText('Booker Name'),
              buildTextFormField(30, user_name, readOnly: true),
              buildSizedBox(10),
              buildText('Order Date'),
              buildTextFormField(30, orderDate.toString(), readOnly: true),
              buildSizedBox(20),
              buildHeading('Order Summary', 15),
              buildSizedBox(10),
              buildRow([
                buildExpandedColumn('Description', 50, readOnly: true),
                buildSizedBox(10),
                buildExpandedColumn('Qty', 20, readOnly: true),
                buildSizedBox(10),
                buildExpandedColumn('Amount', 20, readOnly: true),
              ]),
              for (int i = 0; i < selectedItems.length; i++)
                buildRow([
                  buildExpandedColumn(selectedItems[i], 50, readOnly: true),
                  buildSizedBox(10),
                  buildExpandedColumn(quantities[i].toString(), 20,
                      readOnly: true),
                  buildSizedBox(10),
                  buildExpandedColumn(totalAmounts[i].toString(), 20,
                      readOnly: true),
                ]),
              buildSizedBox(10),
              buildRow([
                buildText('Total                      '),
                buildSizedBox(10),
                buildExpandedColumn(totalAmount.toString(), 10, readOnly: true),
              ]),
              buildSizedBox(10),

              buildRow([
                buildText('Credit limit            '),
                buildSizedBox(10),
                buildExpandedColumn(creditLimit, 10, readOnly: true),
              ]),

              buildSizedBox(10),

              // buildDropdownRow('Credit Limit', 10, creditLimitOptions,
              //     onChanged: (value) {
              //       // Handle the selected credit limit value
              //       // You can save the selected value to your state or perform any other action.
              //     } ),
              // buildSizedBox(10),
              buildRow([
                buildText('Discount               '),
                buildSizedBox(10),
                buildExpandedColumn(discount.toString(), 10,
                    readOnly: true, controller: TextEditingController()),
              ]),
              buildSizedBox(10),
              buildRow([
                buildText('Net Total              '),
                buildSizedBox(10),
                buildExpandedColumn(subTotal.toString(), 10,
                    readOnly: true, controller: TextEditingController()),
              ]),

              buildSizedBox(10),
              buildRow([
                buildText('Required Delivery '),
                buildSizedBox(10),
                buildExpandedColumn(requiredDelivery.toString(), 10,
                    readOnly: true, controller: TextEditingController()),
              ]),buildSizedBox(10),
              Column(
                children: [
                  buildSizedBox(10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 170,
                      child: buildElevatedButton('Re Confirm', () async {
    if (!isReConfirmButtonPressed) {
    isReConfirmButtonPressed = true; // Mark the button as pressed

    isOrderConfirmed = true;

    ordermasterViewModel.addOrderMaster(OrderMasterModel(
    orderId: orderMasterid,
    shopName: shopName,
    ownerName: ownerName,
    phoneNo: phoneNo,
    brand: brand,
    date: date,
    userId: userId.toString(),
    userName: userNames.toString(),
    total: total,
    creditLimit: creditLimit,
    discount: discount,
    subTotal: subTotal,
    requiredDelivery: requiredDelivery,
    ));

    List<OrderDetailsModel> orderDetailsList = [];

    await saveRowDataDetailsToDatabase(rowDataDetails);

    await DBHelperOrderMaster().addOrderDetails(orderDetailsList);

    DBHelperOrderMaster dbmaster = DBHelperOrderMaster();

    await dbmaster.postMasterTable();
    await dbmaster.postOrderDetails();


    Fluttertoast.showToast(
      msg: "Order confirmed!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
    } else {
      Fluttertoast.showToast(
        msg: "Order has already been confirmed.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
                      }),
                      ),

                    ],
                  ),

                  buildSizedBox(20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        child: buildElevatedButton('PDF Share', () {
                          if (isOrderConfirmed) {
                            // Order is confirmed, generate and share the PDF
                            generateAndSharePDF(orderMasterid, user_name, shopName, orderDate, selectedItems, quantities, rates, totalAmounts, totalAmount, creditLimit, discount, subTotal, requiredDelivery);
                          } else {
                            // Order is not confirmed, show a toast message
                            Fluttertoast.showToast(
                              msg: "Please confirm the order before sharing the PDF.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                          }
                        }),
                      ),
                    ],
                  ),
                ],
              ),

              Column(children: [
                buildSizedBox(10),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 100,
                    child: buildElevatedButton('Close', () {
                          if (isOrderConfirmed) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );

                          } else {
                            // Order is not confirmed, show a toast message
                            Fluttertoast.showToast(
                              msg: "Please confirm the order before Closing.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                          }
                    }
                    ),

                  ),
                ),
              ]
              ),
            ],
          ),
        ),
      ),
    );
  }

  // String currentMonth = DateFormat('MMM').format(DateTime.now());
  // You can maintain this as a global variable or retrieve it from somewhere
  _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      serialCounter = prefs.getInt('serialCounter') ?? 1;
      currentMonth = prefs.getString('currentMonth') ?? currentMonth;
      currentUserId = prefs.getString('currentUserId') ?? ''; // Add this line
    });
  }

  _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('serialCounter', serialCounter);
    await prefs.setString('currentMonth', currentMonth);
    await prefs.setString('currentUserId', currentUserId); // Add this line
  }

  String generateNewOrderId( String userId, String currentMonth) {
    if (this.currentUserId != userId) {
      // Reset serial counter when the userId changes
      serialCounter = 1;
      this.currentUserId = userId;
    }

    if (this.currentMonth != currentMonth) {
      // Reset serial counter when the month changes
      serialCounter = 1;
      this.currentMonth = currentMonth;
    }

    String orderId =
        "$userId-$currentMonth-${serialCounter.toString().padLeft(3, '0')}";
    serialCounter++;
    _saveCounter(); // Save the updated counter value, current month, and userId
    return orderId;
  }


  // New method to save rowDataDetails to the order details database
  Future<void> saveRowDataDetailsToDatabase(List<Map<String, dynamic>> rowDataDetails) async {
    final orderdetailsViewModel = Get.put(OrderDetailsViewModel());

    for (var rowData in rowDataDetails) {
      var id = await customAlphabet('1234567890', 5);
      orderdetailsViewModel.addOrderDetail(OrderDetailsModel(
        id: double.parse(id),
        orderMasterId: orderMasterid,
        productName: rowData['selectedItem'],
        quantity: rowData['quantity'],
        price: rowData['rate'],
        amount:  rowData['totalAmount'],
        // Populate other fields based on your data model
      ));
    }
  }

  Widget buildText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        color: Colors.black,
      ),
    );
  }

  Widget buildTextFormField(double height, String text,
      {bool readOnly = false, TextEditingController? controller}) {
    return Container(
      height: height,
      child: TextFormField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        maxLines: 1,
        style: TextStyle(fontSize: 15),
        initialValue: text,
        readOnly: readOnly,
      ),
    );
  }

  Widget buildSizedBox(double height) {
    return SizedBox(height: height);
  }

  Widget buildHeading(String text, double fontSize) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget buildExpandedColumn(String Text, double width,
      {bool readOnly = false, TextEditingController? controller}) {
    return Expanded(
      flex: width != null ? width.toInt() : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (Text != null)
            buildTextFormField(30, Text,
                readOnly: readOnly, controller: controller),
        ],
      ),
    );
  }

  Widget buildRow(List<Widget> children) {
    return Row(
      children: children,
    );
  }

  Widget buildDropdownRow(String labelText, double width, List<String> options,
      {String? value, void Function(String?)? onChanged}) {
    return Row(
      children: [
        buildText(labelText),
        buildSizedBox(10),
        buildExpandedColumn(
          DropdownButton<String>(
            value: value,
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: onChanged,
          ).toString(),
          width,
        ),
      ],
    );
  }

  int calculateTotalQuantity(List<int> quantities) {
    return quantities.fold<int>(0, (sum, quantity) => sum + quantity);
  }

  Future<void> generateAndSharePDF(dynamic orderId, dynamic user_name, dynamic shopName,
      dynamic order_date, List<dynamic> selectedItems, List<dynamic> quantities,List<dynamic> rates,
      List<dynamic> totalAmounts, dynamic totalAmount, dynamic creditLimit,
      dynamic discount, dynamic subTotal, dynamic requiredDelivery) async {
    final pdf = pw.Document();
    final image = pw.Image(pw.MemoryImage(Uint8List.fromList((await rootBundle.load('assets/images/p1.png')).buffer.asUint8List())));
    final totalQuantity = calculateTotalQuantity(quantities.cast<int>());

    // Add content to the PDF document
    pdf.addPage(pw.Page(
      pageFormat: pw.PdfPageFormat.a4,
      build: (pw.Context context){
        return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                margin: const pw.EdgeInsets.only(top: -60), // Adjust margin here
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row (
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        // Add your logo image from assets
                        pw.Container(
                          child: image,
                          height: 150,
                          width: 150,
                        ),
                        pw.Text('Courage ERP', style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
                      ],
                    ),
                  ],
                ),
              ),
              // Page Content
              pw.SizedBox(height: 20),
              // Order# , Date, Booker

              pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Text('Order#: $orderId', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Booker Name: $user_name', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Shop Name: $shopName', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
                        ]
                    ),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text('Date: $order_date', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Req. Delivery: $requiredDelivery', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Credit Limit: $creditLimit', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
                        ]
                    ),
                  ]
              ),
              pw.Column(
                children: [
                  pw.SizedBox(height: 30),
                  // Invoice Heading
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Text('Invoice', style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                      ]
                  ),
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [

                        // Order Summary
                        pw.Text('Order Summary..', style: pw.TextStyle(fontSize: 15)),
                        pw.SizedBox(height: 20),
                      ]
                  ),
                  pw.SizedBox(height: 30),

                  // Table
                  pw.Table(

                    border: pw.TableBorder.symmetric(),
                    columnWidths: {
                      0: pw.FlexColumnWidth(1),
                      1: pw.FlexColumnWidth(4),
                      2: pw.FlexColumnWidth(1),
                      3: pw.FlexColumnWidth(1),
                      4: pw.FlexColumnWidth(2),
                      5: pw.FlexColumnWidth(2),
                    },

                    children: [
                      pw.TableRow(

                        children: [
                          pw.Text('S.N.', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Descr. of Goods', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Qty.', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Unit', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Price', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Amount(Rs.)', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),

                        ],

                      ),

                      for (var i = 0; i < selectedItems.length; i++)
                        pw.TableRow(

                          children: [
                            pw.Text((i + 1).toString()),
                            pw.Text(selectedItems[i]),
                            pw.Text(quantities[i].toString()),
                            pw.Text(('PCS').toString()),
                            pw.Text(rates[i].toString()),
                            //pw.Text(order_date.toString()),
                            pw.Text(totalAmounts[i].toString()),
                          ],
                        ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  // Total
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [

                      pw.Text('Total: $totalAmount', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),

                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text('Discount: ', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
                          pw.Text(discount.toString(), style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                      pw.Container(
                        height: 1,
                        color: PdfColors.grey,
                        margin: const pw.EdgeInsets.symmetric(vertical: 5),
                      ),
                      pw.SizedBox(height: 20),
                      // Total Quantity
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Grand Total: ${totalQuantity.toString()} PCS', style: pw.TextStyle(fontSize: 15)),
                          pw.Text('Net Total: ${subTotal.toString()}', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),


                      pw.SizedBox(height: 10),
                      pw.Container(
                        height: 1,
                        color: PdfColors.grey,
                        margin: const pw.EdgeInsets.symmetric(vertical: 5),
                      ),
                      pw.SizedBox(height: 10),
                      // pw.Row(
                      //   mainAxisAlignment: pw.MainAxisAlignment.end,
                      //   children: [
                      //     pw.Text('Credit Limit: ', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
                      //     pw.Text(creditLimit.toString(), style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
                      //   ],
                      // ),
                    ],
                  ),
                  // Footer
                  pw.Container(
                    margin: const pw.EdgeInsets.only(top: 30),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Developed by MetaXperts', style: pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              )]);
      },
    ));

    // Get the directory for temporary files
    final directory = await getTemporaryDirectory();

    // Create a temporary file in the directory
    final output = File('${directory.path}/order_summary_$orderId.pdf');
    await output.writeAsBytes(await pdf.save());

    // Share the PDF
    await Share.shareFiles([output.path], text: 'PDFDocument');
    }

  Widget buildElevatedButton(String txt, [Function()? onPressed]) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.green,
        onPrimary: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        minimumSize: Size(200, 50),
      ),
      child: Text(txt),
    );
  }
}