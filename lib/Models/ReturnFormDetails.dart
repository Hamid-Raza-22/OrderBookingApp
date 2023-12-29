class ReturnFormDetailsModel {
  dynamic? id;
  dynamic? returnformId;
  String? productName;

  dynamic? reason;
  dynamic? quantity;
  ReturnFormDetailsModel({
    this.id,
    this.returnformId,
    this.productName,

    this.reason,
    this.quantity,

  });

  factory ReturnFormDetailsModel.fromMap(Map<dynamic, dynamic> json) {
    return ReturnFormDetailsModel(
      id: json['id'],
      returnformId: json['returnformId'],
      productName: json['productName'],

      reason: json['reason'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'returnformId':returnformId,
      'productName': productName,

      'reason': reason,
      'quantity': quantity,
    };
  }
}