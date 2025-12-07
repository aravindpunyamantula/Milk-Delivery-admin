import 'package:flutter/material.dart';
import 'package:text_to_qr/Service/update_service.dart';
import 'package:text_to_qr/view/screens/admin_dashboard.dart';
import 'package:text_to_qr/view/screens/delivery.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    UpdateService.checkForUpdate(context);
  });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboard()),
              );
            },
            icon: const Icon(Icons.admin_panel_settings),
          ),
        ],
      ),
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(radius: 50, backgroundImage: AssetImage("assets/logo/logo.jpg"),),
                const SizedBox(height: 16),
                const Text(
                  "Welcome to Soulmate",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                const Text(
                  "Login",
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
               
                const SizedBox(height: 16),


                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delivery_dining),
                    label: const Text("Login as Delivery Boy"),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeliveryScannerScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
