// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:text_to_qr/Service/Models/daily_report.dart';

Future<void> exportCsv(List<DeliveryLog> logs) async {
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

  final csv = const ListToCsvConverter().convert(rows);

  final bytes = utf8.encode(csv);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);

  html.AnchorElement(href: url)
    ..setAttribute(
      "download",
      "${DateFormat("yyyy-MM-dd").format(logs[0].date!)}_report.csv",
    )
    ..click();

  html.Url.revokeObjectUrl(url);
}
