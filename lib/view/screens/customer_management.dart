import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:text_to_qr/Service/Models/customer_model.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:text_to_qr/view/utils/milk_provider.dart';
import 'package:text_to_qr/view/utils/qr_save.dart';

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _bottleController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = "";
  final qrKey = GlobalKey();

  void _addNewCustomer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Customer"),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: _mobileController,
                  decoration: const InputDecoration(
                    labelText: "Mobile",
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: "Address",
                    prefixIcon: Icon(Icons.home),
                  ),
                  maxLines: 2,
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: _bottleController,
                  decoration: const InputDecoration(
                    labelText: "Daily Bottles",
                    prefixIcon: Icon(Icons.local_drink),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                context.read<MilkProvider>().addCustomer(
                  _nameController.text,
                  _mobileController.text,
                  _addressController.text,
                  int.parse(_bottleController.text),
                );
                Navigator.pop(context);
                _clearControllers();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Customer Added!")),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _editCustomerDetails(Customer customer) {
    _nameController.text = customer.name;
    _mobileController.text = customer.phone;
    _addressController.text = customer.address;
    _bottleController.text = customer.dailyBottles.toString();
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Customer"),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: _mobileController,
                  decoration: const InputDecoration(
                    labelText: "Mobile",
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: "Address",
                    prefixIcon: Icon(Icons.home),
                  ),
                  maxLines: 2,
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: _bottleController,
                  decoration: const InputDecoration(
                    labelText: "Daily Bottles",
                    prefixIcon: Icon(Icons.local_drink),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); _clearControllers();},
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                context.read<MilkProvider>().editCustomer(
                  customer,
                  _nameController.text,
                  _addressController.text,
                  _mobileController.text,
                  int.parse(_bottleController.text),
                );
                Navigator.pop(context);
                Navigator.pop(context);
                _clearControllers();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Customer Details updated!")),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _clearControllers() {
    _nameController.clear();
    _mobileController.clear();
    _addressController.clear();
    _bottleController.clear();
  }

  void _showUser(Customer c) {
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
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(onPressed: (){
                  showCupertinoDialog(context: context, builder: (_){
                      return CupertinoAlertDialog(
                        title: Text("Confirm Delete"),
                        content: Text("This Action will delete the user permanently"),
                        actions: [
                          CupertinoButton(onPressed: (){
                            Navigator.pop(context);
                          }, child: Text("Close")),
                           CupertinoButton(onPressed: (){
                            context.read<MilkProvider>().deleteCustomer(c.id);
                            Navigator.pop(context);
                            Navigator.pop(context);
                           }, child: Text("Delete")),
                        ],
                      );
                  });
                }, icon: Icon(Icons.delete)),
              ),
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12),
                        Text(
                          c.name,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: Text(
                            "${c.address}, ${c.phone}",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Daily: ${c.dailyBottles} Bottles",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          margin: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 216, 243, 255),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButton(
                            elevation: 0,
                            underline: Text(""),
                            value: c.paymentStatus,
                            items: [
                              DropdownMenuItem(
                                value: "Paid",
                                child: Text("Paid"),
                              ),
                              DropdownMenuItem(
                                value: "Pending",
                                child: Text("Pending"),
                              ),
                            ],
                            onChanged: (val) {
                              if (val!.isNotEmpty && val != c.paymentStatus) {
                                context.read<MilkProvider>().markPaymentStatus(
                                  c.id,
                                  val,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    RepaintBoundary(
                      key: qrKey,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            QrImageView(
                              data: c.id,
                              version: QrVersions.auto,
                              size: 100.0,
                            ),
                            SizedBox(height: 12),
                            IconButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(Colors.blue),
                                iconColor: WidgetStatePropertyAll(Colors.white),
                                
                              ),
                              icon: const Icon(Icons.download),
                              onPressed: () {
                                _downloadQrCode(
                                  qrKey,
                                  "${c.name.replaceAll(' ', '-')}-QR",
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => _editCustomerDetails(c),
                    child: Text("Edit"),
                  ),
                  const SizedBox(height: 20),
                   ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Close"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  
  void _showQR(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${customer.name}'s QR Code",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                width: 200,
                child: RepaintBoundary(
                  key: qrKey,
                  child: Container(
                    color: Colors.white,
                    child: QrImageView(
                      data: customer.id,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "ID: ${customer.id}",
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text("Download QR"),
                onPressed: () {
                  _downloadQrCode(
                    qrKey,
                    "${customer.name.replaceAll(' ', '-')}-QR",
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadQrCode(GlobalKey key, String filename) async {
    try {
      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      await saveQr(pngBytes, filename);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("QR saved to gallery.")));
    } catch (e) {
      debugPrint("QR Save Error → $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to save QR")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewCustomer,
        label: const Text("Add Customer"),
        icon: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Registered Customers",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
                hintText: "Search by name or phone..",
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = "";
                    });
                  },
                  icon: Icon(Icons.clear),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase().trim();
                });
              },
            ),
            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<List<Customer>>(
                stream: context.read<MilkProvider>().customersStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    debugPrint(snapshot.error.toString());
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var customers = snapshot.data ?? [];

                  var displayCustomers = customers.where((customer) {
                    final name = customer.name.toLowerCase();
                    final phone = customer.phone;
                    return name.contains(_searchQuery) ||
                        phone.contains(_searchQuery);
                  }).toList();

                  if (displayCustomers.isEmpty) {
                    return const Center(child: Text("No customers found."));
                  }

                  return ListView.separated(
                    itemCount: displayCustomers.length,
                    separatorBuilder: (_, i) => const Divider(),
                    itemBuilder: (context, index) {
                      final c = displayCustomers[index];

                      return ListTile(
                        onTap: () => _showUser(c),
                        contentPadding: EdgeInsets.all(0),
                        leading: CircleAvatar(child: Text(c.name[0])),
                        title: Text(c.name),
                        subtitle: Text("•Daily: ${c.dailyBottles} Bottles"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              side: BorderSide.none,
                              backgroundColor: c.paymentStatus == "Paid"
                                  ? Colors.green
                                  : Colors.red,
                              label: Text(
                                c.paymentStatus,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 2),
                            IconButton(
                              icon: const Icon(Icons.qr_code),
                              onPressed: () => _showQR(context, c),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
