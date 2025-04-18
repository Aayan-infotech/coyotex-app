import 'package:intl/intl.dart';

class SubscriptionDetail {
  String? planName;
  String? message;
  num? amount;
  String? purchaseMonth;
  String? purchaseDate;
  String? endsDate;

  SubscriptionDetail({
    this.planName,
    this.message,
    this.amount,
    this.purchaseMonth,
    this.purchaseDate,
    this.endsDate,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["planName"] = planName;
    map["message"] = message;
    map["amount"] = amount;
    map["purchaseMonth"] = purchaseMonth;
    map["purchaseDate"] = purchaseDate;
    map["endsDate"] = endsDate;
    return map;
  }

  SubscriptionDetail.fromJson(dynamic json) {
    planName = json["planName"];
    message = json["message"];
    amount = json["amount"];
    purchaseMonth = json["purchaseMonth"];
    purchaseDate = json["purchaseDate"];
    endsDate = json["endsDate"];
  }

  String get formattedPurchaseDate {
    if (purchaseDate == null) return '';
    final dateTime = DateTime.parse(purchaseDate!);
    return DateFormat('dd MMMM, yyyy').format(dateTime);
  }

  String get formattedEndsDate {
    if (endsDate == null) return '';
    final dateTime = DateTime.parse(endsDate!);
    return DateFormat('dd MMMM, yyyy').format(dateTime);
  }
}
