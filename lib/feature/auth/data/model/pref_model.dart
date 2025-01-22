class UserPreferences {
   String userPlan;
   String userUnit;
   String userWeatherPref;

  UserPreferences({
    required this.userPlan,
    required this.userUnit,
    required this.userWeatherPref,
  });

  // Factory constructor for creating an instance from a JSON map
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userPlan: json['userPlan'] ?? '',
      userUnit: json['userUnit'] ?? '',
      userWeatherPref: json['userWeatherPref'] ?? '',
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, String> toJson() {
    return {
      'userPlan': userPlan,
      'userUnit': userUnit,
      'userWeatherPref': userWeatherPref,
    };
  }
}
