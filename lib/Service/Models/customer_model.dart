import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String name;
  final String phone;
  final String address;
  final int dailyBottles;
  final String paymentStatus;
  final DateTime? createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.dailyBottles,
    required this.paymentStatus,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "phone": phone,
      "address": address,
      "dailyBottles": dailyBottles,
      "paymentStatus": paymentStatus,
      "createdAt": createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map["id"] ?? '',
      name: map["name"] ?? '',
      phone: map["phone"] ?? '',
      address: map["address"] ?? '',
      dailyBottles: map["dailyBottles"] ?? 0,
      paymentStatus: map["paymentStatus"] ?? 'Pending',
      createdAt: map['createdAt'] is Timestamp ? (map['createdAt'] as Timestamp).toDate() : DateTime.now()
    );
  }
}
