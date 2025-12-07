import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryLog {
  final String id;
  final String customerId;
  final String customerName;
  final DateTime? date;
  final int bottles;

  DeliveryLog({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.date,
    required this.bottles,
  });

  factory DeliveryLog.fromMap(Map<String, dynamic> map, String docId) {
    return DeliveryLog(
      id: docId,
      customerId: map["customerId"] ?? '',
      customerName: map["customerName"] ?? '',
      bottles: map["bottles"] ?? 0,
      date: map["date"] is Timestamp
          ? (map["date"] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'bottles': bottles,
      'date': date ?? FieldValue.serverTimestamp(),
    };
  }
}
