class Plan {
  final String id;
  final String planName;
  final int planAmount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  Plan({
    required this.id,
    required this.planName,
    required this.planAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['_id'] ?? '',
      planName: json['planName'] ?? '',
      planAmount: json['planAmount'] ?? 0,
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      version: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'planName': planName,
      'planAmount': planAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }
}
