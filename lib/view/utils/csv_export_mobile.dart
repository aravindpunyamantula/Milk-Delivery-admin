import 'dart:io';
import 'package:flutter/material.dart'; 
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart'; 
import 'package:text_to_qr/Service/Models/daily_report.dart';

Future<void> exportCsv(List<DeliveryLog> logs) async {
 
  if (logs.isEmpty) {
    debugPrint("No logs to export.");
    return;
  }

  List<List<dynamic>> rows = [
    ["Customer id", "Customer Name", "Bottles", "Date"]
  ];

  for (var log in logs) {
    rows.add([
      log.customerId,
      log.customerName,
      log.bottles,
      log.date != null
        ? DateFormat("yyyy-MM-dd hh:mm a").format(log.date!)
        : "No Date",
    ]);
  }

  try {
    
    final csvData = const ListToCsvConverter().convert(rows);

   
    final dir = await getTemporaryDirectory();
    final fileName = "${DateFormat('yyyy-MM-dd').format(logs.first.date ?? DateTime.now())}_report.csv";
    final path = "${dir.path}/$fileName";

   
    final file = File(path);
    await file.writeAsString(csvData);
    
    debugPrint("CSV saved temporarily at $path");


    // ignore: deprecated_member_use
    await Share.shareXFiles(
      [XFile(path)], 
      text: 'Here is your Daily Delivery Report',
      subject: 'Delivery Report $fileName'
    );

  } catch (e) {
    debugPrint("Error exporting CSV: $e");
  }
}