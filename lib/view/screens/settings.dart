import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:text_to_qr/view/utils/milk_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  Future<void> _launchDialer(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (!await launchUrl(launchUri)) {
      debugPrint("Could not launch dialer");
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Milk Delivery System Support&body=Hello Admin, I need help with...', // Auto-fill subject
    );
    if (!await launchUrl(launchUri)) {
      debugPrint("Could not launch email");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          _buildSectionHeader("Settings"),
          buildResetButton(context),

          _buildSectionHeader("Support"),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.blue),
            title: const Text("Help Center"),
            subtitle: const Text("Contact support & FAQ"),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () => _showHelpCenter(context),
          ),

          _buildSectionHeader("Legal"),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: Colors.blue),
            title: const Text("Privacy Policy"),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () => _showPrivacyPolicy(context),
          ),

          _buildSectionHeader("App Info"),
          AboutListTile(
            icon: const Icon(Icons.info_outline, color: Colors.blue),
            applicationName: "Milk Delivery Manager",
            applicationVersion: "Version 1.0.0",
            applicationLegalese: "© 2025 P. D. S. Aravind All Rights Reserved.",
            applicationIcon: const Icon(
              Icons.local_drink,
              size: 50,
              color: Colors.blue,
            ),
            aboutBoxChildren: const [
              SizedBox(height: 20),
              Text(
                "This application handles daily delivery logs, customer subscriptions, and monthly reporting for milk distribution.",
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Privacy Policy"),
        content: const SingleChildScrollView(
          child: Text(
            "1. Data Collection\n"
            "We collect customer names, phone numbers, and addresses solely for delivery purposes.\n\n"
            "2. Data Usage\n"
            "Your data is stored locally and on our secure cloud database. We do not share data with third parties.\n\n"
            "3. Security\n"
            "We implement standard security measures to protect your information.\n\n"
            "4. Contact\n"
            "For any privacy concerns, please contact.",
            style: TextStyle(height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget buildResetButton(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.calendar_month, color: Colors.red),
      title: const Text(
        "Start New Month",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
      subtitle: const Text("Reset all customers to 'Pending'"),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Start New Month?"),
            content: const Text(
              "⚠️ This will change ALL customers' status to 'Pending'.\n\n"
              "Do this only on the 1st of the month.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  Navigator.pop(context); // Close dialog

                  await context.read<MilkProvider>().startNewMonth();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("New month started! All statuses reset."),
                      ),
                    );
                  }
                },
                child: const Text(
                  "Confirm Reset",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHelpCenter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How can we help?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.call, color: Colors.white),
              ),
              title: const Text("Call Support"),
              subtitle: const Text("+91 630 411 4648"),
              onTap: () {
                Navigator.pop(context);
                _launchDialer("+916304114648");
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.redAccent,
                child: Icon(Icons.email, color: Colors.white),
              ),
              title: const Text("Email Support"),
              subtitle: const Text("aravindpunyamantula630@gmail.com"),
              onTap: () {
                Navigator.pop(context);
                _launchEmail("aravindpunyamantula630@gmail.com");
              },
            ),
          ],
        ),
      ),
    );
  }
}
