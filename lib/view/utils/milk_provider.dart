import 'package:flutter/material.dart';
import 'package:text_to_qr/Service/Models/customer_model.dart';
import 'package:text_to_qr/Service/Models/daily_report.dart';
import 'package:text_to_qr/Service/Repositories/database_service.dart';
import 'package:uuid/uuid.dart';

class MilkProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  Stream<List<Customer>> get customersStream => _db.getCustomers();
  Stream<List<DeliveryLog>> getTodayDeliveries() {
    return _db.getDeliveryByDate(DateTime.now());
  }

  Stream<List<DeliveryLog>> getDeliveryByDate(DateTime date){
    return _db.getDeliveryByDate(date);
  }



  Future<void> addCustomer(
    String name,
    String phone,
    String address,
    int bottles,
  ) async {
    String id = const Uuid().v4();
    Customer newCustomer = Customer(
      id: id,
      name: name,
      phone: phone,
      address: address,
      dailyBottles: bottles,
      paymentStatus: 'Pending',
      createdAt: DateTime.now(),
    );

    await _db.addCustomer(newCustomer);
  }

  Future<void> editCustomer(Customer customer, String name, String addr, String phone, int bottles) async {
    await _db.updateCustomer(customer, name, addr, phone, bottles);
  }


  Future<void> markPaymentStatus(String id, String status) async {
    await _db.updatePaymentStatus(id, status);
  }

  Future<void> logDelivery(
    String customerId,
    String customerName,
    int bottles,
  ) async {
    await _db.logDelivery(
      customerId: customerId,
      customerName: customerName,
      bottleCount: bottles,
    );
  }

  Future<Customer?> getCustomerById(String id) async {
    return await _db.getCustomerById(id);
  }

  Future<void> startNewMonth() async {
  await _db.resetAllPaymentsToPending();
}

Future<void> deleteCustomer(String customerId) async{
  await _db.deleteCustomer(customerId);
}
}
