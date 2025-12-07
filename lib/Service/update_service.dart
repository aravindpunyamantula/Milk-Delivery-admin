import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  
  static const String _versionUrl = 
      "https://raw.githubusercontent.com/aravindpunyamantula/Milk-Delivery-admin/main/version.json";

  
  static const String _downloadUrl = 
      "https://github.com/aravindpunyamantula/Milk-Delivery-admin/releases/latest";

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      Version currentVersion = Version.parse(packageInfo.version);

      final response = await http.get(Uri.parse(_versionUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        Version latestVersion = Version.parse(data['version']);
        bool isMandatory = data['mandatory'] ?? false;

       
        if (latestVersion > currentVersion) {
      
          if (context.mounted) {
            _showUpdateDialog(context, isMandatory, latestVersion.toString());
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking update: $e");
    }
  }

  static void _showUpdateDialog(BuildContext context, bool mandatory, String newVersion) {
    showDialog(
      context: context,
      barrierDismissible: !mandatory, 
      builder: (context) {
        return PopScope(
          canPop: !mandatory, 
          child: AlertDialog(
            title: const Text("Update Available"),
            content: Text(
              "A new version ($newVersion) is available.\n"
              "${mandatory ? 'You must update to continue using the app.' : 'Please update for the best experience.'}"
            ),
            actions: [
              if (!mandatory)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Later"),
                ),
              ElevatedButton(
                onPressed: () {
                  launchUrl(Uri.parse(_downloadUrl), mode: LaunchMode.externalApplication);
                },
                child: const Text("Update Now"),
              ),
            ],
          ),
        );
      },
    );
  }
}