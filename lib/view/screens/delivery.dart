import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:text_to_qr/login_page.dart';
import 'package:text_to_qr/Service/Models/customer_model.dart';
import 'package:text_to_qr/view/utils/milk_provider.dart';

class DeliveryScannerScreen extends StatefulWidget {
  const DeliveryScannerScreen({super.key});

  @override
  State<DeliveryScannerScreen> createState() => _DeliveryScannerScreenState();
}

class _DeliveryScannerScreenState extends State<DeliveryScannerScreen> {
  bool _isProcessing = false;
  MobileScannerController cameraController = MobileScannerController();

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => _isProcessing = true);
        _handleScannedCode(barcode.rawValue!);
        break;
      }
    }
  }


  Future<void> _handleScannedCode(String scannedId) async {
    final provider = Provider.of<MilkProvider>(context, listen: false);

  
    Customer? customer = await provider.getCustomerById(scannedId);

    if (customer == null) {
      if(!mounted)return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid QR Code / Customer Not Found")),
      );
      setState(() => _isProcessing = false);
      return;
    }

   
    _openDeliverySheet(customer);
  }


  void _openDeliverySheet(Customer customer) {
    TextEditingController deliveryController =
        TextEditingController(text: customer.dailyBottles.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Confirm Delivery",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),
              ListTile(
                title: Text(customer.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(customer.address),
              ),
              const SizedBox(height: 10),

              Text("Expected: ${customer.dailyBottles} Bottles",
                  style: TextStyle(color: Colors.grey[600])),

              const SizedBox(height: 20),

              TextField(
                controller: deliveryController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Bottles Delivered Today",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    int qty = int.tryParse(deliveryController.text) ??
                        customer.dailyBottles;
                    _saveDelivery(ctx, customer, qty);
                  },
                  child: const Text("SAVE DELIVERY"),
                ),
              )
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      setState(() => _isProcessing = false);
    });
  }


  void _saveDelivery(BuildContext ctx, Customer customer, int quantity) {
    final provider = Provider.of<MilkProvider>(context, listen: false);

    // FIXED → using correct provider function signature
    provider.logDelivery(
      customer.id,
      customer.name,
      quantity,
    );

    Navigator.pop(ctx);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Delivery Logged Successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanner"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Point camera at Customer QR",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
