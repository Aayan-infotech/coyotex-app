class Subscriptions {
  String? id;
  String? planName;
  num? planAmount;
  String? status;
  String? productID;
  List<String>? descriptionList;
  String? createdAt;
  String? updatedAt;
  num? v;

  Subscriptions(
      {this.id, this.planName, this.planAmount, this.status, this.productID, this.descriptionList, this.createdAt, this.updatedAt, this.v});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["_id"] = id;
    map["planName"] = planName;
    map["planAmount"] = planAmount;
    map["status"] = status;
    map["productID"] = productID;
    map["description"] = descriptionList;
    map["createdAt"] = createdAt;
    map["updatedAt"] = updatedAt;
    map["__v"] = v;
    return map;
  }

  Subscriptions.fromJson(dynamic json){
    id = json["_id"];
    planName = json["planName"];
    planAmount = json["planAmount"];
    status = json["status"];
    productID = json["productID"];
    descriptionList =
    json["description"] != null ? json["description"].cast<String>() : [];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
  }
}

class SubscriptionsPlans {
  List<Subscriptions>? subscriptionsList;

  SubscriptionsPlans({this.subscriptionsList});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (subscriptionsList != null) {
      map["subscriptions"] = subscriptionsList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  SubscriptionsPlans.fromJson(dynamic json){
    if (json["subscriptions"] != null) {
      subscriptionsList = [];
      json["subscriptions"].forEach((v) {
        subscriptionsList?.add(Subscriptions.fromJson(v));
      });
    }
  }
}