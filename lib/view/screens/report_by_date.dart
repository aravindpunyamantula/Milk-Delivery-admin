import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:text_to_qr/view/utils/csv_export.dart';
import 'package:text_to_qr/view/utils/milk_provider.dart';

class ReportByDate extends StatefulWidget {
  const ReportByDate({super.key});

  @override
  State<ReportByDate> createState() => _ReportByDateState();
}

class _ReportByDateState extends State<ReportByDate> {
  DateTime _selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Text("Pick Date"),
              SizedBox(height: 4),
              Container(
                width: 300,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.blueGrey[200],
                  borderRadius: BorderRadius.circular(12)
                ),
                child: CalendarDatePicker(
                  firstDate: DateTime(2023),
                  initialDate: _selectedDate,
                  lastDate: DateTime.now(),
                  onDateChanged: (val) {
                    setState(() {
                      _selectedDate = val;
                    });
                  },
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Reports on ${DateFormat("MMM d y").format(_selectedDate)}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),)),
              ),
              SizedBox(
                height: 500,
                child: StreamBuilder(
                  stream: context.read<MilkProvider>().getDeliveryByDate(_selectedDate), 
                  builder: (_, snap){
                    if(snap.hasError){
                      return Center(child: Text("Unable to Fetch Reports ${snap.error}"),);
                    }
                     if (snap.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if(!snap.hasData){
                      return Center(child: Text("No Reports"),);
                    }
                    final todayLogs = snap.data!;
                    if(todayLogs.isEmpty){
                      return Center(child: Text("No Reports"),);
                    }
                
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: todayLogs.length,
                      itemBuilder: (_, i){
                        final log = todayLogs[i];
                        return ListTile(
                          leading: CircleAvatar(child: Text(log.customerName[0]),),
                          title: Text(log.customerName),
                          subtitle: Text("${log.bottles} Bottles Delivered at ${DateFormat("hh:mm a").format(log.date!)}"),
                        );
                      },
                      separatorBuilder: (context, index) => Divider(),);
                
                
                  }),
              ),
               Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.download),
                                  onPressed: () async {
                                    
                                    final logs = await context
                                        .read<MilkProvider>()
                                        .getDeliveryByDate(_selectedDate)
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
               ),
            ],
          ),
        ),
      ),
    );
  }
}
