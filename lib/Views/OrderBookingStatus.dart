import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_shop/API/Globals.dart';
import 'package:order_booking_shop/Databases/OrderDatabase/DBOrderMasterGet.dart';

import '../API/DatabaseOutputs.dart';
import '../Databases/OrderDatabase/DBHelperOwner.dart';

void main() {
  runApp(MaterialApp(
    home: OrderBookingStatus(),
    debugShowCheckedModeBanner: false,
  ));
}

class OrderBookingStatus extends StatefulWidget {
  @override
  _OrderBookingStatusState createState() => _OrderBookingStatusState();
}

class _OrderBookingStatusState extends State<OrderBookingStatus> {
  TextEditingController shopController = TextEditingController();
  TextEditingController orderController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController totalAmountController = TextEditingController();
  List<String> dropdownItems = [];
  String selectedItem = '';
  String selectedOrderNo = '';
  List<String> dropdownItems2 = [];
  String selectedShopOwner = '';
  String selectedOwnerContact = '';
  List<Map<String, dynamic>> shopOwners = [];
  DBOrderMasterGet dbHelper = DBOrderMasterGet();
  String selectedOrderNoFilter = '';
  String selectedShopFilter = '';
  String selectedStatusFilter = '';

  Future<void> _selectDate(
      BuildContext context, TextEditingController dateController) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      String formattedDate = DateFormat('dd-MMM-yyyy').format(pickedDate);
      dateController.text = formattedDate;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchShopData();
    fetchOrderNumbers();
   // onCreatee();
  }
  // Future<void> onCreatee() async {
  //
  //   DatabaseOutputs outputs = DatabaseOutputs();
  //   outputs.checkFirstRun();
  // }

  void clearFilters() {
    setState(() {
      selectedShopFilter = '';
      selectedOrderNoFilter = '';
      selectedStatusFilter = '';
      shopController.clear();
      orderController.clear();
      statusController.clear();
      startDateController.clear();
      endDateController.clear();
      selectedOrderNo = ''; // Clear the selected order number
      selectedItem = ''; // Clear the selected shop
    });
  }

  void fetchOrderNumbers() async {
    List<Map<String, dynamic>> orderNumbers =
        await dbHelper.getOrderBookingStatusDB() ?? [];
    setState(() {
      dropdownItems2 =
          orderNumbers.map((map) => map['order_no'].toString()).toSet().toList();
    });
  }
  //
  void fetchShopData() async {
    List<String> shopNames = await dbHelper.getOrderMasterShopNames();
    shopOwners = (await dbHelper.getOrderMasterDB())!;

    setState(() {
      dropdownItems = shopNames.toSet().toList();
    });
  }
  Future<List<Map<String, dynamic>>> fetchOrderBookingStatusData() async {
    List<Map<String, dynamic>> data = await dbHelper.getOrderBookingStatusDB() ?? [];

    // Apply the filters
    if (selectedOrderNoFilter.isNotEmpty) {
      data = data.where((row) => row['order_no'] == selectedOrderNoFilter).toList();
    }
// Filter by date range
    if (startDateController.text.isNotEmpty && endDateController.text.isNotEmpty) {
      DateTime startDate = DateFormat('dd-MMM-yyyy').parse(startDateController.text);
      DateTime endDate = DateFormat('dd-MMM-yyyy').parse(endDateController.text);

      data = data.where((row) {
        DateTime orderDate = DateFormat('dd-MMM-yyyy').parse(row['order_date']);
        return orderDate.isAfter(startDate.subtract(Duration(days: 1))) &&
            orderDate.isBefore(endDate.add(Duration(days: 1)));
      }).toList();
    }


    if (selectedShopFilter.isNotEmpty) {
      data = data.where((row) => row['shop_name'] == selectedShopFilter).toList();
    }

    if (selectedStatusFilter.isNotEmpty) {
      // Check if the status filter is "All", if not, filter by status
      if (selectedStatusFilter != 'All') {
        data = data.where((row) => row['status'] == selectedStatusFilter).toList();
      }
    }

    // Check if shop field is empty, reset shop filter
    if (selectedShopFilter.isEmpty) {
      selectedShopFilter = '';
    }

    // Check if status field is empty, reset status filter
    if (statusController.text.isEmpty) {
      selectedStatusFilter = '';
    }

    // Check if order field is empty, reset order filter
    if (selectedOrderNoFilter.isEmpty) {
      selectedOrderNoFilter = '';
    }

    return data;
  }

  List<DataRow> buildDataRows(List<Map<String, dynamic>> data) {
    return data.map((map) {
      bool highlightRow =
          map['order_no'] == selectedOrderNoFilter ||
              map['shop_name'] == selectedShopFilter ||
              map['status'] == selectedStatusFilter;

      return DataRow(
        selected: highlightRow,
        cells: [
          DataCell(
            Text(map['order_no'].toString()),
          ),
          DataCell(Text(map['order_date'].toString())),
          DataCell(Text(map['shop_name'].toString())),
          DataCell(Text(map['amount'].toString())),
          DataCell(Text(map['status'].toString())),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          title: Text('Order Booking Status'),
          centerTitle: true,
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double screenWidth = constraints.maxWidth;

            return SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 5),
                        Text(
                          'Shop: ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 50,
                                width: screenWidth * 0.4,
                                padding: const EdgeInsets.all(8.0),
                                child: TypeAheadFormField(
                                  textFieldConfiguration: TextFieldConfiguration(
                                      controller: TextEditingController(text: selectedItem),
                                      decoration: InputDecoration(
                                        hintText: 'Select Shop',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.all(10),
                                      ), style: TextStyle(fontSize: 12)
                                  ),
                                  suggestionsCallback: (pattern) {
                                    return dropdownItems
                                        .where((item) =>
                                        item.toLowerCase().contains(pattern.toLowerCase()))
                                        .toList();
                                  },  itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    title: Text(
                                      suggestion,
                                      style: TextStyle(fontSize: 10), // Adjust the font size here
                                    ),
                                  );
                                },
                                  onSuggestionSelected: (suggestion) {
                                    setState(() {
                                      selectedItem = suggestion;
                                      selectedOrderNoFilter = ''; // Clear the order number filter
                                      selectedShopFilter = suggestion; // Update the shop filter
                                      print('Selected Shop: $selectedItem');
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Order:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 50,
                                width: screenWidth * 0.4,
                                padding: const EdgeInsets.all(8.0),
                                child: TypeAheadFormField(
                                  textFieldConfiguration: TextFieldConfiguration(
                                      controller: TextEditingController(text: selectedOrderNo),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.all(10),
                                      ),style: TextStyle(fontSize: 12)
                                  ),
                                  suggestionsCallback: (pattern) {
                                    return dropdownItems2
                                        .where((order) =>
                                        order.toLowerCase().contains(pattern.toLowerCase()))
                                        .toList();
                                  },  itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    title: Text(
                                      suggestion,
                                      style: TextStyle(fontSize: 10), // Adjust the font size here
                                    ),
                                  );
                                },
                                  onSuggestionSelected: (suggestion) {
                                    setState(() {
                                      selectedOrderNo = suggestion;
                                      selectedOrderNoFilter = suggestion; // Update the filter
                                    });
                                  },
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                        return 'Please enter digits only';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 5),
                        Text(
                          'Date Range:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 50,
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: startDateController,
                                  onTap: () async {
                                    await _selectDate(
                                        context, startDateController);
                                  },
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontFamily: 'YourFontFamily',
                                  ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.all(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'to',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: endDateController,
                              onTap: () async {
                                await _selectDate(context, endDateController);
                              },
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontFamily: 'YourFontFamily',
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 5),
                        Text(
                          'Status: ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 50,
                                width: screenWidth * 0.4,
                                padding: const EdgeInsets.all(8.0),
                                child: TypeAheadFormField(
                                  textFieldConfiguration: TextFieldConfiguration(
                                    controller: statusController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.all(10),
                                    ),
                                  ),
                                  suggestionsCallback: (pattern) {
                                    return ['DISPATCHED', 'RESCHEDULE', 'CANCELED']
                                        .where((status) =>
                                        status.toLowerCase().contains(
                                            pattern.toLowerCase()))
                                        .toList();
                                  },
                                  itemBuilder: (context, suggestion) {
                                    return ListTile(
                                      title: Text(suggestion),
                                    );
                                  },
                                  onSuggestionSelected: (suggestion) {
                                    setState(() {
                                      statusController.text = suggestion;
                                      selectedStatusFilter = suggestion; // Update the status filter
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ), Container(
                          margin: EdgeInsets.all(9.0), // Adjust the margin as needed
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                            onPressed: () {
                              clearFilters();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              elevation: 8.0,
                            ),
                            child: Container(
                              height: 30.0,
                              width: 70.0,
                              alignment: Alignment.center,
                              child: Text('Clear Filters', style: TextStyle(fontSize: 11, color: Colors.white)),
                            ),
                          ),
                        )



                      ],

                    ),
                    SizedBox(height: 20),
                    Card(
                      elevation: 0.0,
                      margin: EdgeInsets.all(5.0),
                      child: Container(
                        height: 420.0, // Set the desired height for the card
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              future: fetchOrderBookingStatusData(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  List<DataRow> dataRows = buildDataRows(snapshot.data ?? []);
                                  return DataTable(
                                    columns: [
                                      DataColumn(label: Text('Order No')),
                                      DataColumn(label: Text('Order Date')),
                                      DataColumn(label: Text('Shop Name')),
                                      DataColumn(label: Text('Amount')),
                                      DataColumn(label: Text('Status')),
                                    ],
                                    rows: dataRows,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    // SizedBox(height: 50),
                    // Align(
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.end,
                    //     children: [
                    //       Text(
                    //         'Total Amount',
                    //         style: TextStyle(fontSize: 16, color: Colors.black),
                    //       ),
                    //       SizedBox(width: 10),
                    //       Container(
                    //         height: 30,
                    //         width: 170,
                    //         child: TextFormField(
                    //           enabled: false,
                    //           controller: totalAmountController,
                    //           decoration: InputDecoration(
                    //             border: OutlineInputBorder(
                    //               borderRadius: BorderRadius.circular(5.0),
                    //             ),
                    //           ),
                    //           textAlign: TextAlign.right,
                    //           validator: (value) {
                    //             if (value!.isEmpty) {
                    //               return 'Please enter some text';
                    //             }
                    //             return null;
                    //           },
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(height: 10
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(color: Colors.green),
                          ),
                          elevation: 8.0,
                        ),
                        child: Text('Close', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

    );
    }
}