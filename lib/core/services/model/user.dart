// class User {
//   final String id;
//   final String name;
//   final String email;
//   final String? profilePictureUrl;
//   final String phoneNumber;
//   final String? address;

//   User({
//     required this.id,
//     required this.name,
//     required this.email,
//     this.profilePictureUrl,
//     required this.phoneNumber,
//     this.address,
//   });

//   // Factory method to create a User from a Map (e.g., from JSON).
//   factory User.fromMap(Map<String, dynamic> map) {
//     return User(
//       id: map['id'] ?? '',
//       name: map['name'] ?? '',
//       email: map['email'] ?? '',
//       profilePictureUrl: map['profilePictureUrl'],
//       phoneNumber: map['phoneNumber'] ?? '',
//       address: map['address'],
//     );
//   }

//   // Convert the User object to a Map (e.g., for saving to a database).
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'email': email,
//       'profilePictureUrl': profilePictureUrl,
//       'phoneNumber': phoneNumber,
//       'address': address,
//     };
//   }
// }
