
import 'package:order_booking_shop/Models/ProductsModel.dart';

class ReturnFormModel {

  dynamic? returnId;
  String? date;
  String? shopName;

  ReturnFormModel({

    this.returnId,
    this.date,
    this.shopName,

  });

  factory ReturnFormModel.fromMap(Map<dynamic, dynamic> json) {
    return ReturnFormModel(

      returnId: json['returnId'],
        date: json['date'],
        shopName: json['shopName'],

    );
  }

  Map<String, dynamic> toMap() {
    return {

      'returnId': returnId,
      'date': date,
      'shopName': shopName,

    };
  }
}
