class Plan {
  final String id;
  final String planName;
  final double planAmount;
  final String status;
  final String productId;
  final List<String> description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Plan({
    required this.id,
    required this.planName,
    required this.planAmount,
    required this.status,
    required this.productId,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['_id'] ?? '',
      planName: json['planName'] ?? '',
      planAmount: json['planAmount'] ?? 0,
      status: json['status'] ?? '',
      productId: json['productId'] ?? '',
      description: List<String>.from(json['description'] ?? []), // Cast to List<String>
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'planName': planName,
      'planAmount': planAmount,
      'productId': productId,
      'status': status,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String()
    };
  }
}
