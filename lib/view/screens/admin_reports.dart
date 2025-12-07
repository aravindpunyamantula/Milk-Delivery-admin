import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:text_to_qr/Service/Models/daily_report.dart';
import 'package:text_to_qr/Service/Models/customer_model.dart';
import 'package:text_to_qr/view/utils/milk_provider.dart';
import 'package:text_to_qr/view/utils/csv_export.dart';


class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MilkProvider>(context, listen: false);
    void showUser(Customer c, DeliveryLog log, bool isDelivered) {
      showModalBottomSheet(
        context: context,
        builder: (_) => Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: CircleAvatar(radius: 30, child: Text(c.name[0])),
                      ),
                      SizedBox(height: 12),
                      Text(
                        c.name,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${c.address}, ${c.phone}",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Daily: ${c.dailyBottles} Bottles",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      SizedBox(height: 8),
                      Text(
                        isDelivered
                            ? "${log.bottles} Bottles delivered at ${DateFormat('hh:mm a').format(log.date!)}"
                            : "Pending Delivery",
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12),

                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Report for ${DateFormat('MMMM d, y').format(DateTime.now())}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            StreamBuilder<List<Customer>>(
              stream: provider.customersStream,
              builder: (context, customerSnapshot) {
                if (customerSnapshot.hasError) {
                  return Center(
                    child: Text(
                      "Unable Fetch reports ${customerSnapshot.error}",
                    ),
                  );
                }
                if (customerSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final customers = customerSnapshot.data!;
                if (customers.isEmpty) {
                  return Center(child: Text("No Deliveries Yet"));
                }

                return StreamBuilder<List<DeliveryLog>>(
                  stream: provider.getTodayDeliveries(),
                  builder: (context, logSnapshot) {
                    if (!logSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final todayLogs = logSnapshot.data!;

                    int totalExpected = customers.fold(
                      0,
                      (sum, c) => sum + c.dailyBottles,
                    );

                    int totalDelivered = todayLogs.fold(
                      0,
                      (sum, log) => sum + log.bottles,
                    );

                    int completedDeliveriesCount = todayLogs.length;

                    int pendingDeliveriesCount =
                        customers.length - completedDeliveriesCount <0 ? 0 : customers.length - completedDeliveriesCount;

                    return Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildStatCard(
                                "Total Expected",
                                "$totalExpected Bottles",
                                Colors.blue,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                "Total Delivered",
                                "$totalDelivered Bottles",
                                Colors.green,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                "Pending Stops",
                                "$pendingDeliveriesCount",
                                Colors.orange,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            "Delivery Status by Customer",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Expanded(
                            child: Card(
                              elevation: 2,
                              child: customers.isEmpty
                                  ? const Center(
                                      child: Text(
                                        "No customers registered yet.",
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.all(8),
                                      itemCount: customers.length,
                                      separatorBuilder: (_, __) =>
                                          const Divider(),
                                      itemBuilder: (context, index) {
                                        final c = customers[index];

                                        DeliveryLog? log = todayLogs.firstWhere(
                                          (l) => l.customerId == c.id,
                                          orElse: () => DeliveryLog(
                                            id: "",
                                            customerId: "",
                                            customerName: "",
                                            bottles: 0,
                                            date: DateTime(1990),
                                          ),
                                        );

                                        final isDelivered =
                                            log.customerId == c.id;

                                        return ListTile(
                                          onTap: () =>
                                              showUser(c, log, isDelivered),
                                          leading: CircleAvatar(
                                            backgroundColor: isDelivered
                                                ? Colors.green.shade100
                                                : Colors.orange.shade100,
                                            child: Icon(
                                              isDelivered
                                                  ? Icons.check
                                                  : Icons.hourglass_empty,
                                              color: isDelivered
                                                  ? Colors.green
                                                  : Colors.orange,
                                            ),
                                          ),
                                          title: Text(
                                            c.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text(
                                            isDelivered
                                                ? "Delivered at ${DateFormat('hh:mm a').format(log.date!)}"
                                                : "Pending Delivery",
                                          ),
                                          trailing: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                isDelivered
                                                    ? "${log.bottles}"
                                                    : "-",
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                "of ${c.dailyBottles} expected",
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.download),
                              onPressed: () async {
                                
                                final logs = await context
                                    .read<MilkProvider>()
                                    .getTodayDeliveries()
                                    .first;
                               await exportCsv(logs);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("CSV Exported Successfully!"),
                                  ),
                                );
                              },
                              label: Text("Download CSV"),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
