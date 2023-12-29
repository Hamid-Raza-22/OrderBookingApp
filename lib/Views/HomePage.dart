import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nanoid/nanoid.dart';
import 'package:order_booking_shop/API/Globals.dart';
import 'package:order_booking_shop/Databases/OrderDatabase/DBProductCategory.dart';
import 'package:order_booking_shop/Models/AttendanceModel.dart';
import '../API/DatabaseOutputs.dart';
import '../View_Models/AttendanceViewModel.dart';
import 'login.dart';
import 'OrderBookingStatus.dart';
import 'RecoveryFormPage.dart';
import 'ReturnFormPage.dart';
import 'ShopPage.dart';
import 'ShopVisit.dart';
import '../Databases/OrderDatabase/DBHelperOwner.dart';
//tracker
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';
// import 'dart:js';
import 'package:flutter_background/flutter_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:gpx/gpx.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../API/Globals.dart';


//tarcker
final FirebaseAuth auth = FirebaseAuth.instance;
final User? user = auth.currentUser;
final myUid = userId;
final name = userNames;
bool showButton = false;


class MyIcons {
  static const IconData addShop = IconData(0xf52a, fontFamily: 'MaterialIcons');
  static const IconData store = Icons.store;
  static const IconData returnForm = IconData(0xee93, fontFamily: 'MaterialIcons');
  static const IconData person = Icons.person;
  static const IconData orderBookingStatus = IconData(0xf52a, fontFamily: 'MaterialIcons');
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>with WidgetsBindingObserver {
  final attendanceViewModel = Get.put(AttendanceViewModel());
  late TimeOfDay _currentTime; // Add this line
  late DateTime _currentDate;
  List<String> shopList = [];
  String? selectedShop2;
  int? attendanceId;
  int? attendanceId1;
  double? globalLatitude1;
  double? globalLongitude1;
  DBHelperOwner dbHelper = DBHelperOwner();
  //tracker
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      // Handle the case when permission is denied
      Fluttertoast.showToast(
        msg: "Location permissions are required to clock in.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _toggleClockInOut() async {
    Completer<void> completer = Completer<void>();


    showDialog(
      context: context,
      barrierDismissible: false, // Prevent users from dismissing the dialog
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );


    bool isLocationEnabled = await _isLocationEnabled();

    if (!isLocationEnabled) {
      Fluttertoast.showToast(
        msg: "Please enable GPS or location services before clocking in.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      completer.complete();
      return completer.future;
    }

    bool isLocationPermissionGranted = await _checkLocationPermission();
    if (!isLocationPermissionGranted) {
      await _requestLocationPermission();
      completer.complete();
      return completer.future;
    }

    var id = await customAlphabet('1234567890', 10);
    await _getCurrentLocation();

    setState(() {
      isClockedIn = !isClockedIn;

      if (isClockedIn) {
        attendanceViewModel.addAttendance(AttendanceModel(
          id: int.parse(id),
          timeIn: _getFormattedtime(),
          date: _getFormattedDate(),
          userId: userId.toString(),
          latIn: globalLatitude1,
          lngIn: globalLongitude1,
        ));

        _startTimer();
        _getLocation();
        _listenLocation();

        isClockedIn = true;

        DBHelperProductCategory dbmaster = DBHelperProductCategory();
        dbmaster.postAttendanceTable();
      } else {
        attendanceViewModel.addAttendanceOut(AttendanceOutModel(
          id: int.parse(id),
          timeOut: _getFormattedtime(),
          totalTime: _stopTimer(),
          date: _getFormattedDate(),
          userId: userId.toString(),
          latOut: globalLatitude1,
          lngOut: globalLongitude1,
        ));
        isClockedIn = false;
        DBHelperProductCategory dbmaster = DBHelperProductCategory();
        dbmaster.postAttendanceOutTable();
        _stopTimer();
        setState(() async {
          _stopListening();
          await saveGPXFile();
          await postFile();
        });
      }
    });

    // Wait for 10 seconds
    await Future.delayed(Duration(seconds: 3));

    Navigator.pop(context); // Close the loading indicator dialog

    completer.complete();
    return completer.future;
  }


  Future<bool> _isLocationEnabled() async {
    // Add your logic to check if location services are enabled
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    return isLocationEnabled;
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    fetchShopList();
    _currentDate = DateTime.now(); // Initialize _currentDate
    _currentTime = TimeOfDay.now();
    _initializeDateTime(); // Initialize both date and time
    //trac
    _requestPermission();
    location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high);
    location.enableBackgroundMode(enable: true);
    if(isClockedIn){
      _clockrefresh();


    }
    _getFormattedDate();
    // _getFormattedTime();
  }
  String _getFormattedtime() {
    final now = DateTime.now();
    final formatter = DateFormat('HH:mm:ss a');
    return formatter.format(now);
  }

  void _initializeDateTime() {
    final now = DateTime.now();
    _currentDate = now;
    _currentTime = TimeOfDay.fromDateTime(now);
  }

  void _startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        secondsPassed++;
      });
    });
  }

  void _clockrefresh(){
    timer = Timer.periodic(Duration(seconds: 0), (timer) {
      setState(() {

      });
    });
  }

  String _stopTimer() {
    timer.cancel();
    String totalTime = _formatDuration(secondsPassed.toString());
    setState(() {
      secondsPassed = 0;
    });
    return totalTime;
  }

  String _formatDuration(String secondsString) {
    int seconds = int.parse(secondsString);
    Duration duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$secondsFormatted';
  }


  @override
  void dispose() {
    timer.cancel();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     if (_isClockedIn) {
  //       _startTimer();
  //     }
  //   } else {
  //     _stopTimer();
  //   }
  // }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await _determinePosition();
      // Save the location into the database (you need to implement this part)
      globalLatitude1 = position.latitude;
      globalLongitude1 = position.longitude;
      // Show a toast
      Fluttertoast.showToast(
        msg: 'Location captured!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      print('Error getting current location: $e');
    }
  }


  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      throw Exception('Location services are disabled.');
    }

    // Check the location permission status.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Location permissions are denied
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Location permissions are permanently denied
      throw Exception('Location permissions are permanently denied.');
    }

    // Get the current position
    return await Geolocator.getCurrentPosition();
  }

  Future<void> fetchShopList() async {
    List<String> fetchShopList = await fetchData();
    if (fetchShopList.isNotEmpty) {
      setState(() {
        shopList = fetchShopList;
        selectedShop2 = shopList.first;
      });
    }
  }

  Future<List<String>> fetchData() async {
    return [];
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('dd-MMM-yyyy');
    return formatter.format(now);
  }


  void handleShopChange(String? newShop) {
    setState(() {
      selectedShop2 = newShop;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Return false to prevent going back
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.green,
          toolbarHeight: 100.0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Text(
                  //   'Date: ${_getFormattedDate()}', // Add this line
                  //   style: TextStyle(
                  //     color: Colors.white,
                  //     fontSize: 16.0,
                  //   ),
                  // ),
                  // SizedBox(height: 10),
                  Text(
                    'Timer: ${_formatDuration(secondsPassed.toString())}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),

                  // SizedBox(height: 10),
                  // Text(
                  //   ' Time: ${_getFormattedtime()}',
                  //   style: TextStyle(
                  //     fontSize: 16.0,
                  //   ),
                  // ),
                ],
              ),
              PopupMenuButton<int>(
                icon: Icon(Icons.more_vert),
                color: Colors.white,
                onSelected: (value) async {
                  switch (value) {
                    case 1:

                      DatabaseOutputs outputs = DatabaseOutputs();
                      outputs.checkFirstRun();

                    case 2:
                    // Handle the action for the second menu item
                    // Add more cases for other menu items if needed
// Log Out logic
                      if (isClockedIn) {
                        // Check if the user is clocked in
                        Fluttertoast.showToast(
                          msg: "Please clock out before logging out.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else {
                        // If the user is not clocked in, proceed with logging out
                        Navigator.pushReplacement(
                          // Replace the current page with the login page
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginForm(),
                          ),
                        );

                      }
                      break;
                  // Add more cases for other menu items as needed
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<int>(
                      value: 1,
                      child: Text('Refresh'),

                    ),
                    PopupMenuItem<int>(
                      value: 2,
                      child: Text('Log Out'),
                    ),
                    // PopupMenuItem<int>(
                    //   value: 3,
                    //   child: Text('Option 3'),
                    // ),
                    // Add more PopupMenuItems as needed
                  ];
                },
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 150,
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isClockedIn) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShopPage(),
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Clock In Required'),
                                  content: Text('Turn on location.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                MyIcons.addShop,
                                color: Colors.white,
                                size: 50,
                              ),
                              SizedBox(height: 10),
                              Text('Add Shop'),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                            onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        height: 150,
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isClockedIn) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShopVisit(onBrandItemsSelected: (String) {}),
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Clock In Required'),
                                  content: Text('Please clock in before visiting a shop.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.store,
                                color: Colors.white,
                                size: 50,
                              ),
                              SizedBox(height: 10),
                              Text('Shop Visit'),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                            onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 150,
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isClockedIn) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ReturnFormPage()));
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Clock In Required'),
                                  content: Text('Please clock in before accessing the Return Form.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                MyIcons.returnForm,
                                color: Colors.white,
                                size: 50,
                              ),
                              SizedBox(height: 10),
                              Text('Return Form'),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                            onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        height: 150,
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isClockedIn) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => RecoveryFromPage()));
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Clock In Required'),
                                  content: Text('Please clock in before accessing the Recovery.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 50,
                              ),
                              SizedBox(height: 10),
                              Text('Recovery'),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                            onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
                      Container(
                        height: 150,
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isClockedIn) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderBookingStatus(),
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Clock In Required'),
                                  content: Text('Please clock in before checking Order Booking Status.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                MyIcons.orderBookingStatus,
                                color: Colors.white,
                                size: 50,
                              ),
                              SizedBox(height: 10),
                              Text('Order Booking Status'),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                            onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child:ElevatedButton.icon(
              onPressed: _toggleClockInOut,
              // onPressed: () {
              //   setState(() async {
              //     _isClockedIn = !_isClockedIn;
              //     if (_isClockedIn) {
              //       // Code for clocking in
              //       var id = await customAlphabet('1234567890', 10);
              //       attendanceViewModel.addAttendance(AttendanceModel(
              //         id: int.parse(id),
              //         timeIn: _getFormattedtime(),
              //         date: _getFormattedDate(),
              //         userId: userId.toString(),
              //         latIn: globalLatitude1,
              //         lngIn: globalLongitude1,
              //       ));
              //       _startTimer();
              //
              //       DBHelperProductCategory dbmaster = DBHelperProductCategory();
              //       await dbmaster.postAttendanceTable();
              //       // Start the timer when clocking in
              //     } else {
              //       // Code for clocking out
              //       var id = await customAlphabet('1234567890', 10);
              //       attendanceViewModel.addAttendanceOut(AttendanceOutModel(
              //           id: int.parse(id),
              //         timeOut: _getFormattedtime(),
              //         date: _getFormattedDate(),
              //         userId: userId.toString(),
              //         latOut: globalLatitude1,
              //         lngOut: globalLongitude1,
              //       ));
              //
              //       DBHelperProductCategory dbmaster = DBHelperProductCategory();
              //       await dbmaster.postAttendanceOutTable();
              //       _stopTimer();
              //       // Stop the timer when clocking out
              //     }
              //     _getCurrentLocation(); // Capture location when clocking in or out
              //   });
              // },
              icon: Icon(
                isClockedIn ? Icons.timer_off : Icons.timer,
                color: isClockedIn ? Colors.red : Colors.green,
              ),
              label: Text(
                isClockedIn ? 'Clock Out' : 'Clock In',
                style: TextStyle(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: isClockedIn ? Colors.red : Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

          ),
        ),
      ),
    );
  }

  var gpx;
  // Create a track
  var track;
  // Create a track segment
  var segment;
  var trkpt;
  _getLocation() async {
    try {
      final loc.LocationData _locationResult = await location.getLocation();
      await FirebaseFirestore.instance.collection('location').doc(myUid).set({
        'latitude': _locationResult.latitude,
        'longitude': _locationResult.longitude,
        'name': name.toString(),
        'isActive': false
      }, SetOptions(merge: true));
    } catch (e) {
      print(e);
    }
  }
  Future<void> _listenLocation() async {
    gpx = new Gpx();
    track = new Trk();
    segment = new Trkseg();

    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentlocation) async {
      await FirebaseFirestore.instance.collection('location').doc(myUid).set({
        'latitude': currentlocation.latitude,
        'longitude': currentlocation.longitude,
        'name': name.toString(),
        'isActive':true
      }, SetOptions(merge: true));

      // Create a track point with latitude, longitude, and time information
      final trackPoint = Wpt(
        lat: currentlocation.latitude,
        lon: currentlocation.longitude,
        time: DateTime.now(),
      );

      segment.trkpts.add(trackPoint);

      if (track.trksegs.isEmpty) {
        track.trksegs.add(segment);
        gpx.trks.add(track);
      }

      final gpxString = GpxWriter().asString(gpx, pretty: true);
      print("XXX $gpxString");
    });
  }
  Future<void> saveGPXFile() async {
    final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final gpxString = await GpxWriter().asString(gpx, pretty: true);
    final downloadDirectory = await getDownloadsDirectory();
    final filePath = "${downloadDirectory!.path}/track$date.gpx";
    final file = File(filePath);

    if (await file.exists()) {
      final existingGpx = await GpxReader().fromString(await file.readAsString());
      final newSegment = GpxReader().fromString(gpxString); // Replace this with the actual segment you want to add
      existingGpx.trks[0].trksegs.add(newSegment.trks[0].trksegs[0]);
      await file.writeAsString(GpxWriter().asString(existingGpx, pretty: true));
    } else {
      await file.writeAsString(gpxString);
    }

    print('GPX file saved successfully at ${file.path}');
    Fluttertoast.showToast(
      msg: "GPX file saved in the Downloads folder!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  Future<void> GPXinfo() async {
    final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final downloadDirectory = await getDownloadsDirectory();
    final filePath = "${downloadDirectory!.path}/track$date.gpx";

    final file = File(filePath);
    print("XXX    DATA    ${file.readAsStringSync()}");
  }

  Future<void> postFile() async {
    final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final downloadDirectory = await getDownloadsDirectory();
    //final directory = await getApplicationDocumentsDirectory();
    final filePath = File('${downloadDirectory?.path}/track$date.gpx');

    if (!filePath.existsSync()) {
      print('File does not exist');
      return;
    }
    var request = http.MultipartRequest("POST",
        Uri.parse("https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/location/post/"));
    var gpxFile = await http.MultipartFile.fromPath(
        'body', filePath.path);
    request.files.add(gpxFile);
    // Add other fields if needed
    request.fields['userId'] = userId;
    request.fields['userName'] = userNames;
    request.fields['fileName'] = "${_getFormattedDate()}.gpx";
    request.fields['date'] = _getFormattedDate();

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var result = String.fromCharCodes(responseData);
        print("Results: Post Successfully");
         //deleteGPXFile(); // Delete the GPX file after successful upload
        _deleteDocument();
      } else {
        print("Failed to upload file. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // Future<void> deleteGPXFile() async {
  //   try {
  //     final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
  //    // final gpxString = await GpxWriter().asString(gpx, pretty: true);
  //     final downloadDirectory = await getDownloadsDirectory();
  //     final filePath = "${downloadDirectory!.path}/track$date.gpx";
  //     final file = File(filePath);
  //
  //     if (file.existsSync()) {
  //       await file.delete();
  //       print('GPX file deleted successfully');
  //     } else {
  //       print('GPX file does not exist');
  //     }
  //   } catch (e) {
  //     print('Error deleting GPX file: $e');
  //   }
  // }

  _stopListening() {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
  }

  //delete document
  _deleteDocument() async {
    await FirebaseFirestore.instance
        .collection('location')
        .doc(myUid)
        .delete()
        .then(
          (doc) => print("Document deleted"),
      onError: (e) => print("Error updating document $e"),
    );
  }
  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('done');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}