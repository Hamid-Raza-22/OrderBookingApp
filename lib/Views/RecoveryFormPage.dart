import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_shop/API/Globals.dart';
import 'package:order_booking_shop/Models/RecoveryFormModel.dart';
import 'package:order_booking_shop/View_Models/RecoveryFormViewModel.dart';
import 'package:order_booking_shop/Views/RecoveryForm_2ndPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/DatabaseOutputs.dart';
import '../Databases/DBHelperRecoveryForm.dart';
import '../Databases/OrderDatabase/DBOrderMasterGet.dart';

class RecoveryFromPage extends StatefulWidget {
  @override
  _RecoveryFromPageState createState() => _RecoveryFromPageState();
}

class _RecoveryFromPageState extends State<RecoveryFromPage> {
  bool isButtonPressed = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final recoveryformViewModel = Get.put(RecoveryFormViewModel());
  TextEditingController _dateController = TextEditingController();
  TextEditingController _currentBalanceController = TextEditingController();
  // TextEditingController _textField3Controller = TextEditingController();
  TextEditingController _cashRecoveryController = TextEditingController();
  TextEditingController _netBalanceController = TextEditingController();
  List<Map<String, dynamic>> accountsData = []; // Add this line
  String? selectedShopName;

  List<String> dropdownItems = [];
  String? selectedDropdownValue;
  List<Map<String, dynamic>> shopOwners = [];
  DBOrderMasterGet dbHelper = DBOrderMasterGet();
  int serialCounter = 1;
  double currentBalance = 0.0;
  String currentUserId = '';
  String currentMonth = DateFormat('MMM').format(DateTime.now());
  @override
  void initState() {
    super.initState();
    //selectedDropdownValue = dropdownItems[0];
    _dateController.text = getCurrentDate();
    _cashRecoveryController.text = '0'; // Assuming initial value is zero
    _netBalanceController.text = '0'; // Assuming initial value is zero
    //fetchShopData();
    onCreatee();
    _loadCounter();
    fetchShopNames();
    fetchShopNamesAndTotals();
    fetchAccountsData();
    // Add this line

  }
  String? validateCashRecovery(String value) {
    if (value.isEmpty) {
      showToast('Please enter some text');
      return 'Please enter some text';
    } else if (!RegExp(r'^[0-9.]+$').hasMatch(value)) {
      showToast('Please enter valid numbers');
      return 'Please enter valid numbers';
    }

    // Convert values to double for comparison
    double cashRecovery = double.parse(value);
    double currentBalance = double.parse(_currentBalanceController.text);

    // Check if cash recovery is greater than current balance
    if (cashRecovery > currentBalance) {
      showToast('Cash recovery cannot be greater than current balance');
         _cashRecoveryController.clear();
        _netBalanceController.clear();
      return 'Cash recovery cannot be greater than current balance';
    }

    return null;
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> fetchAccountsData() async {
    DBOrderMasterGet dbHelper = DBOrderMasterGet();
    List<Map<String, dynamic>>? accounts = await dbHelper.getAccoutsDB();

    setState(() {
      // Filter accountsData based on the selected shop name
      accountsData = accounts
          ?.where((account) =>
      account['order_date'] != null &&
          account['credit'] != null &&
          account['booker_name'] != null &&
          account['shop_name'] == selectedShopName)
          .toList() ??
          [];

      // Sort the accountsData based on order_date in descending order
      accountsData.sort((a, b) =>
          DateTime.parse(b['order_date']).compareTo(DateFormat('dd-MMM-yyyy').parse(a['order_date'])));

      // Limit to a maximum of three rows
      accountsData = accountsData.take(3).toList();
    });
  }


  Future<void> onCreatee() async {
    DatabaseOutputs db = DatabaseOutputs();
    await db.showRecoveryForm();

    // DatabaseOutputs outputs = DatabaseOutputs();
    // outputs.checkFirstRun();

  }


  // void fetchShopData() async {
  //   List<String> shopNames = await dbHelper.getOrderMasterShopNames();
  //   shopOwners = (await dbHelper.getOrderMasterDB())!;
  //   //final shopOwners = await dbHelper.getOwnersDB();
  //   print(shopOwners);
  //
  //   setState(() {
  //     dropdownItems = shopNames.toSet().toList();
  //   });
  // }

  Future<void> fetchShopNamesAndTotals() async {
    DBOrderMasterGet dbHelper = DBOrderMasterGet();

    // Calculate total debits, credits, and debits minus credits per shop
    Map<String, dynamic> debitsAndCredits = await dbHelper.getDebitsAndCreditsTotal();
    Map<String, double> debitsMinusCreditsPerShop = await dbHelper.getDebitsMinusCreditsPerShop();

    // Extract shop names, debits, credits, and debits minus credits per shop
    List<String> shopNames = debitsAndCredits['debits'].keys.toList();
    Map<String, double> shopDebits = debitsAndCredits['debits'];
    Map<String, double> shopCredits = debitsAndCredits['credits'];

    // Print or use the shop names, debits, credits, and debits minus credits per shop as needed
    print("Shop Names: $shopNames");
    print("Shop Debits: $shopDebits");
    print("Shop Credits: $shopCredits");
    print("Shop Debits - Credits: $debitsMinusCreditsPerShop");

    // You can update the state or perform other actions with the data here
  }
  Future<void> fetchNetBalanceForShop(String shopName) async {
    DBOrderMasterGet dbHelper = DBOrderMasterGet();
    double shopDebits = 0.0;
    double shopCredits = 0.0;

    // Fetch net balance for the selected shop
    List<Map<String, dynamic>>? netBalanceData = await dbHelper.getNetBalanceDB();
    for (var row in netBalanceData!) {
      if (row['shop_name'] == shopName) {
        shopDebits += double.parse(row['debit'] ?? '0');
        shopCredits += double.parse(row['credit'] ?? '0');
      }
    }

    // Calculate net balance (shop debits - shop credits)
    double netBalance = shopDebits - shopCredits;

    // Ensure net balance is not less than 0
    netBalance = netBalance < 0 ? 0 : netBalance;

    setState(() {
      // Update the current balance field with the calculated net balance
      currentBalance = netBalance;
      _currentBalanceController.text = currentBalance.toString();
    });
  }


  Future<void> fetchShopNames() async {
    DBOrderMasterGet dbHelper = DBOrderMasterGet();
    List<String>? shopNames = await dbHelper.getShopNamesFromNetBalance();

    // Remove duplicates from the shopNames list
    List<String> uniqueShopNames = shopNames!.toSet().toList();

    setState(() {
      dropdownItems = uniqueShopNames;
      // selectedDropdownValue = uniqueShopNames.isNotEmpty ? uniqueShopNames[0] : null;
    });
  }


  String getCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('dd-MMM-yyyy');
    return formatter.format(now);
  }

  void updateNetBalance() {
    double totalAmount = double.tryParse(_currentBalanceController.text) ?? 0;
    double cashRecovery = double.tryParse(_cashRecoveryController.text) ?? 0;
    double netBalance = totalAmount - cashRecovery;
    _netBalanceController.text = netBalance.toString();
  }

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


  String generateNewOrderId(String Receipt, String userId, String currentMonth) {
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
        "$Receipt-$userId-$currentMonth-${serialCounter.toString().padLeft(3, '0')}";
    serialCounter++;
    _saveCounter(); // Save the updated counter value and current month
    return orderId;
  }

  @override
  Widget build(BuildContext context) {
    double inputWidth = MediaQuery.of(context).size.width * 0.25;
    double dropdownWidth = 1000;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white10,
          title: Text(
            'Recovery Form',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Date:',
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        Text(
                          getCurrentDate(),
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Shop Name',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                        SizedBox(height: 10),
                        TypeAheadFormField(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: TextEditingController(text: selectedDropdownValue),
                            decoration: InputDecoration(
                              hintText: '--Select Shop--',
                              border: OutlineInputBorder(

                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                          ),
                          suggestionsCallback: (pattern) {
                            return dropdownItems
                                .where((item) =>
                                item.toLowerCase().contains(pattern.toLowerCase()))
                                .toList();
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                            );
                          },
                          onSuggestionSelected: (suggestion) {
                            setState(() {
                              selectedDropdownValue = suggestion;
                              selectedShopName = suggestion;
                              // Fetch and display the net balance for the selected shop
                              fetchNetBalanceForShop(selectedDropdownValue!);
                              fetchAccountsData();
                            });
                          },
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Text('Current Balance'),
                                    SizedBox(width: 10),
                                    Container(
                                      height: 30,
                                      width: 150,
                                      child: TextFormField(
                                        controller: _currentBalanceController,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                        ),
                                        textAlign: TextAlign.left,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter some text';
                                          }
                                          double currentBalance = double.parse(value);
                                          if (currentBalance < 1) {
                                            return 'Current balance should be at least 1';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            '----- Previous Payment History -----',
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                        ),
                        SizedBox(height: 20),

                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              columns: [
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Shop')),
                                DataColumn(label: Text('Amount')),
                              ],



                              // Modify the DataRow creation inside the DataTable
                              rows: accountsData
                                  .where((account) =>
                              account['order_date'] != null &&
                                  account['credit'] != null &&
                                  account['booker_name'] != null &&
                                  account['shop_name'] == selectedDropdownValue)
                                  .take(3) // Limit to a maximum of three rows
                                  .map(
                                    (account) => DataRow(
                                  cells: [
                                    DataCell(Text(account['order_date'] ?? '')),
                                    DataCell(Text(account['shop_name'] ?? '')),
                                    DataCell(Text(account['credit']?.toString() ?? '')),
                                  ],
                                ),
                              )
                                  .toList(),


                            ),
                          ),
                        ),

                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Text('Cash Recovery      '),
                                    SizedBox(width: 10),
                                    Container(
                                      height: 30,

                                      width: 175,
                                      child: TextFormField(
                                        controller: _cashRecoveryController,
                                        onChanged: (value) {
                                          updateNetBalance();
                                        },
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                        ),
                                        textAlign: TextAlign.left,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter some text';
                                          } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                            return 'Please enter digits only';
                                          }

                                          // Convert values to double for comparison
                                          double cashRecovery = double.parse(value);
                                          double currentBalance = double.parse(_currentBalanceController.text);

                                          // Check if cash recovery is greater than current balance
                                          if (cashRecovery > currentBalance) {
                                            selectedDropdownValue='';
                                            _currentBalanceController.clear();
                                            _cashRecoveryController.clear();
                                             _netBalanceController.clear();

                                            return 'Cash recovery cannot be greater than current balance';
                                          }
                                          return null;
                                        },
                                        keyboardType: TextInputType.number, // Restrict keyboard to numeric
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Text('Net Balance          '),
                                    SizedBox(width: 10),
                                    Container(
                                      height: 30,
                                      width: 175,
                                      child: TextFormField(
                                        controller: _netBalanceController,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                        ),
                                        textAlign: TextAlign.left,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter some text';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),


                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: () async {
                            if (!isButtonPressed && selectedDropdownValue!.isNotEmpty) {
                              // Set the flag to true to indicate that the button has been pressed
                              setState(() {
                                isButtonPressed = true;
                              });

                              String? cashRecoveryValidation = validateCashRecovery(_cashRecoveryController.text);

                              // Check if validation passes
                              if (cashRecoveryValidation == null) {
                                // Validation passed, proceed with your submission logic
                                if (currentBalance > 0.0) {
                                  try {
                                    String newOrderId2 = generateNewOrderId(
                                        Receipt, userId.toString(), currentMonth);

                                    recoveryformViewModel.addRecoveryForm(
                                      RecoveryFormModel(
                                        recoveryId: newOrderId2,
                                        shopName: selectedDropdownValue,
                                        cashRecovery: _cashRecoveryController.text,
                                        netBalance: _netBalanceController.text,
                                        date: getCurrentDate(),
                                        userId: userId,
                                      ),
                                    );

                                    DBHelperRecoveryForm dbrecoveryform = DBHelperRecoveryForm();
                                    await dbrecoveryform.postRecoveryFormTable();

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RecoveryForm_2ndPage(
                                          formData: {
                                            'recoveryId': newOrderId2,
                                            'shopName': selectedDropdownValue,
                                            'cashRecovery': _cashRecoveryController.text,
                                            'netBalance': _netBalanceController.text,
                                            'date': getCurrentDate(),
                                          },
                                        ),
                                      ),
                                    );

                                    // Clear text fields after submitting
                                    // _cashRecoveryController.clear();
                                    // _netBalanceController.clear();
                                  } catch (e) {
                                    print('Error during submission: $e');
                                  } finally {
                                    // Reset the flag to false after successful submission or any error
                                    setState(() {
                                      isButtonPressed = false;
                                    });
                                  }
                                } else {
                                  // Show a toast or display an error message for current balance <= 0.0
                                  print('Current balance must be greater than 0.0 for submission.');

                                  // Reset the flag to false after validation fails
                                  setState(() {
                                    isButtonPressed = false;
                                  });
                                }
                              } else {
                                // Validation failed, display an error message or take appropriate action
                                print(cashRecoveryValidation);

                                // Reset the flag to false if validation fails
                                setState(() {
                                  isButtonPressed = false;
                                });
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                            onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),



                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        );
    }
}