import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'AppExceptions.dart';
import 'BaseApiServices.dart';
import 'package:http/http.dart' as http;

class ApiServices extends BaseApiServices {


  @override
  Future<dynamic> getApi(dynamic url)async{

    if (kDebugMode) {
      print(url);
    }
    dynamic responseJson ;
    try {

      final response = await http.get(Uri.parse(url)).timeout( const Duration(seconds: 10));
      responseJson  = jsonDecode(response.body) ;
      responseJson = responseJson['items'];
    }on SocketException {
      throw InternetException('');
    }on RequestTimeOut {
      throw RequestTimeOut('');

    }
    return responseJson ;
  }


  @override
  Future<dynamic> postApi(var data , dynamic url)async{

    if (kDebugMode) {
      print(url);
      print(data);
    }

    dynamic responseJson ;
    try {

      final response = await http.post(Uri.parse(url),
          body: data
      ).timeout( const Duration(seconds: 10));
      responseJson  = returnResponse(response) ;
    }on SocketException {
      print(InternetException(''));
    }on RequestTimeOut {
      print(RequestTimeOut(''));

    }
    if (kDebugMode) {
      print(responseJson);
    }
    return responseJson ;
  }

  Future<bool> masterPost(Map<String, dynamic> data, dynamic url, ) async {
    if (kDebugMode) {
      print(url);
      print(data);
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        body: data,  // Use the provided body if not null, otherwise fallback to data
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else {
        print("ERROR ${response.statusCode.toString()}");
        return false;
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  dynamic returnResponse(http.Response response){
    switch(response.statusCode){
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson ;
      case 400:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson ;

      default :
        throw FetchDataException('Error accoured while communicating with server '+response.statusCode.toString()) ;
    }
  }


  Future<bool> masterPostWithImage(Map<dynamic, dynamic> data, dynamic url, Uint8List? body) async {


    if (kDebugMode) {
      print(url);
      print(data);
    }

    try {

      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add fields from the data map
      data.forEach((key, value) {
        request.fields[key.toString()] = value.toString();
      });

      // Add image if provided
      if (body != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'body',
            body,
            filename: 'shop_image.jpg', // Adjust the filename as needed
          ),
        );
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        // Successful response, you might want to handle the response further
        var responseData = await response.stream.toBytes();
        var result = String.fromCharCodes(responseData);
        print('Image uploaded successfully. Response: $result');

        if (kDebugMode) {
          print(responseData);
        }
        return true;
      } else {
        // Unsuccessful response
        print("ERROR ${response.statusCode.toString()}");
        return false;
      }
    } catch (e) {
      // Exception during the API request
      print(e.toString());
      return false;
    }
  }


}
