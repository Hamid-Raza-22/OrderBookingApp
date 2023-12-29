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

//Flutter Background

final androidConfig = FlutterBackgroundAndroidConfig(
  notificationTitle: "Background Tracking",
  notificationText: "Background Notification",
  notificationImportance: AndroidNotificationImportance.Default,
  notificationIcon: AndroidResource(
      name: 'background_icon',
      defType: 'drawable'), // Default is ic_launcher from folder mipmap
);

final FirebaseAuth auth = FirebaseAuth.instance;
final User? user = auth.currentUser;
final myUid = user!.uid;
final name = user!.email;
bool showButton = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterBackground.initialize(androidConfig: androidConfig);
  await FlutterBackground.enableBackgroundExecution();

  //Flutter Background

  await Firebase.initializeApp();

  runApp(MaterialApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high);
    location.enableBackgroundMode(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        'name': name.toString()
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
        'name': name.toString()
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
      print("$gpxString");
    });
  }

  Future<void> saveGPXFile() async {
    final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final gpxString = await GpxWriter().asString(gpx, pretty: true);
    final downloadDirectory = await getDownloadsDirectory();
    final filePath = "${downloadDirectory!.path}/track$date.gpx";
    final file = File(filePath);
    if (await file.exists()) {
      final existingGpx =
      await GpxReader().fromString(await file.readAsString());
      final newSegment = GpxReader().fromString(
          gpxString); // Replace this with the actual segment you want to add
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
    var request = http.MultipartRequest(
        "POST",
        Uri.parse(
            "https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/location/post/"));
    var gpxFile = await http.MultipartFile.fromPath('body', filePath.path);
    request.files.add(gpxFile);
    // Add other fields if needed
    request.fields['userId'] = userId;
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

  Future<void> deleteGPXFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/track.gpx';
      final file = File(filePath);
      if (file.existsSync()) {
        await file.delete();
        print('GPX file deleted successfully');
      } else {
        print('GPX file does not exist');
      }
    } catch (e) {
      print('Error deleting GPX file: $e');
    }
  }

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
