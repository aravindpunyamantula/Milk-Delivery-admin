import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:text_to_qr/Service/Models/customer_model.dart';
import 'package:text_to_qr/Service/Models/daily_report.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addCustomer(Customer customer) async {
    try {
      DocumentReference docRef = _db.collection('customers').doc(customer.id);
      await docRef.set(customer.toMap());
    } catch (e) {
      debugPrint("Error Adding Customer $e");
    }
  }

  Future<void> updateCustomer(Customer customer, String name, String addr, String phone, int bottles) async {
    try {
      await _db
          .collection('customers')
          .doc(customer.id)
          .update({
            "name":name,
            "phone":phone,
            "address":addr,
            "dailyBottles":bottles
          });
    } catch (e) {
      debugPrint("Error Updating Customer: $e");
      rethrow;
    }
  }

  Stream<List<Customer>> getCustomers() {
    return _db
        .collection('customers')
        .orderBy('name')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => Customer.fromMap(doc.data())).toList(),
        );
  }

  Future<void> updatePaymentStatus(String customerId, String newStatus) async {
    await _db.collection('customers').doc(customerId).update({
      'paymentStatus': newStatus,
    });
  }

  Future<void> deleteCustomer(String customerId) async {
    await _db.collection('customers').doc(customerId).delete();
  }

  Future<Customer?> getCustomerById(String id) async {
    try {
      DocumentSnapshot doc = await _db.collection('customers').doc(id).get();
      if (doc.exists) {
        return Customer.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint("Error Finding customer: $e");
      return null;
    }
  }



  Future<void> logDelivery({
    required String customerId,
    required String customerName,
    required int bottleCount,
  }) async {
    await _db.collection('deliveries').add({
      'customerId': customerId,
      'customerName': customerName,
      'bottles': bottleCount,
      'date': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<DeliveryLog>> getDeliveryByDate(DateTime date) {
  DateTime start = DateTime(date.year, date.month, date.day);
  DateTime end = start.add(Duration(days: 1));

  return _db
      .collection('deliveries')
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
      .where('date', isLessThan: Timestamp.fromDate(end))
      .snapshots()
      .map((snap) {
        return snap.docs
            .map((doc) => DeliveryLog.fromMap(doc.data(), doc.id))
            .toList();
      });
}

Future<void> resetAllPaymentsToPending() async {
  try {
    final instance = FirebaseFirestore.instance;
    final QuerySnapshot snapshot = await instance.collection('customers').get();
    
    WriteBatch batch = instance.batch();

    
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {
        'paymentStatus': 'Pending',
        
      });
    }

    
    await batch.commit();
    debugPrint("All customers reset to Pending");
    
  } catch (e) {
    debugPrint("Error resetting payments: $e");
    rethrow;
  }
}

}
