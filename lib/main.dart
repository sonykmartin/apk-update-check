import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Version 1 App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Version1HomePage(),
    );
  }
}

class Version1HomePage extends StatelessWidget {
  const Version1HomePage({super.key});

  final String apkUrl =
      'https://drive.google.com/uc?export=download&id=1CTLrCCTO6pKYk3w-r0bVjyGbpGtVS6f7';

  Future<void> checkForUpdates(BuildContext context) async {
    const currentVersion = "1.0.0";
    const latestVersion = "2.0.0";

    if (currentVersion != latestVersion) {
      _showUpdateDialog(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You are on the latest version!")),
      );
    }
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Available"),
        content:
            const Text("A newer version is available. Do you want to update?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _downloadAndInstall();
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAndInstall() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      print("Storage permission is not granted.");
      return;
    }

    final dio = Dio();
    final savePath = "/storage/emulated/0/Download/new_version.apk";

    try {
      print('Downloading APK to $savePath');
      await dio.download(apkUrl, savePath);
      print('Download completed.');

      final fileUri = Uri.parse(
          "content://com.example.version1.fileprovider/download/new_version.apk");
      final intent = AndroidIntent(
        action: 'action_view',
        data: fileUri.toString(),
        type: 'application/vnd.android.package-archive',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } catch (e) {
      print('Download or installation failed: $e');

      if (e is DioException && e.response?.statusCode == 404) {
        print('Error: APK file not found at the specified URL.');
      } else {
        print('An unexpected error occurred: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Version 1 App")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => checkForUpdates(context),
          child: const Text("Check for Updates"),
        ),
      ),
    );
  }
}
