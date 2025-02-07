class UserModel {
  final String userId;
  final String name;
  final String number;
  final String email;
  final bool isVerified;
  final String referralCode;
  final String userPlan;
  final String userUnit;
  final String userWeatherPref;
  final String insIp;
  final int userStatus;
  final DateTime insDate;


  UserModel({
    required this.userId,
    required this.name,
    required this.number,
    required this.email,
    required this.isVerified,
    required this.referralCode,
    required this.userPlan,
    required this.userUnit,
    required this.userWeatherPref,
    required this.insIp,
    required this.userStatus,
    required this.insDate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json["_id"]??'',
      name: json['name'] ?? '',
      number: json['number'] ?? '',
      email: json['email'] ?? "",
      isVerified: json['isVerified'] ?? true,
      referralCode: json['referralCode'] ?? "",
      userPlan: json['userPlan'] ?? '',
      userUnit: json['userUnit'] ?? "",
      userWeatherPref: json['userWeatherPref'] ?? "",
      insIp: json['ins_ip'] ?? '',
      userStatus: json['user_status'] ?? 1,
      insDate: DateTime.parse(json['ins_date'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'number': number,
      'email': email,
      'isVerified': isVerified,
      'referralCode': referralCode,
      'userPlan': userPlan,
      'userUnit': userUnit,
      'userWeatherPref': userWeatherPref,
      'ins_ip': insIp,
      'user_status': userStatus,
      'ins_date': insDate.toIso8601String(),
    };
  }
}
