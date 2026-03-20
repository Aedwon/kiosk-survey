import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_export_stub.dart' if (dart.library.html) 'web_export_web.dart' as web_helper;
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/on_screen_keyboard.dart';
import '../widgets/animated_background.dart';
import '../main.dart'; // To access surveyRepo

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  static const platform = MethodChannel('com.example.survey/kiosk');
  final TextEditingController _pinController = TextEditingController();
  bool _isAuthenticated = false;
  bool _isExporting = false;
  int _totalEntries = 0;
  String _statusMessage = '';
  bool _isKeyboardVisible = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _verifyPin() {
    if (_pinController.text == 'HOKFestivalOfLanterns03212026') {
      setState(() {
        _isAuthenticated = true;
        _totalEntries = surveyRepo.getAllEntries().length;
      });
    } else {
      setState(() {
        _statusMessage = 'Incorrect Password';
        _pinController.clear();
      });
    }
    _hideKeyboard();
  }

  void _showKeyboard() {
    setState(() {
      _isKeyboardVisible = true;
    });
  }

  void _hideKeyboard() {
    setState(() {
      _isKeyboardVisible = false;
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _exitKioskMode() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Application?'),
        content: const Text('This will unpin the app and return to the TV Home Screen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Exit Kiosk', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      if (!kIsWeb && Platform.isAndroid) {
        try {
          // Tell native Android layer to unpin (stopLockTask) and kill the app
          await platform.invokeMethod('stopKioskMode');
        } on PlatformException catch (e) {
          setState(() {
            _statusMessage = "Failed to exit Kiosk Mode: '${e.message}'.";
          });
        }
      } else {
        // Fallback for non-Android platforms (like Web/Mac testing)
        SystemNavigator.pop();
      }
    }
  }

  Future<void> _exportToCsv() async {
    setState(() {
      _isExporting = true;
      _statusMessage = 'Requesting permissions...';
    });

    try {
      // (kIsWeb check was moved to after CSV generation)
      
      // Request storage permission (Only test Platform if NOT on Web to prevent crash)
      if (!kIsWeb && Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        
        // Android 11+ manage external storage
        if (!status.isGranted) {
           var manageStatus = await Permission.manageExternalStorage.status;
           if (!manageStatus.isGranted) {
             manageStatus = await Permission.manageExternalStorage.request();
           }
        }
      }

      final entries = surveyRepo.getAllEntries();
      if (entries.isEmpty) {
        setState(() {
          _statusMessage = 'No entries to export.';
          _isExporting = false;
        });
        return;
      }

      // Prepare CSV data
      List<List<dynamic>> rows = [];
      // Header
      rows.add([
        "Timestamp",
        "What improvements would you like to see in HOK Benefits?",
        "What new feature would you like to see added in the future for HOK Benefits?",
        "What redeemable prizes would you like to be added on HOK Benefits?"
      ]);
      
      for (var entry in entries) {
        rows.add([
          entry['Timestamp'] ?? '',
          entry['Q1_Answer'] ?? '',
          entry['Q2_Answer'] ?? '',
          entry['Q3_Answer'] ?? '',
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);

      if (kIsWeb) {
        // Trigger a native browser download for testing on web
        web_helper.downloadCsvWeb(csv, 'survey_exports_${DateTime.now().millisecondsSinceEpoch}.csv');

        setState(() {
          _statusMessage = 'Web Test: Downloaded via Browser.';
          _isExporting = false;
        });
        return;
      }

      // Open Native Save Dialog (Android/iOS/MacOS/Win)
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output file (e.g., USB Drive)',
        fileName: 'survey_exports_${DateTime.now().millisecondsSinceEpoch}.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
        bytes: Uint8List.fromList(utf8.encode(csv)),
      );

      if (outputFile == null) {
        // User canceled the picker
        setState(() {
          _statusMessage = 'Export canceled.';
          _isExporting = false;
        });
        return;
      }

      if (!Platform.isAndroid && !Platform.isIOS) {
        final File file = File(outputFile);
        await file.writeAsString(csv);
      }

      setState(() {
        _statusMessage = 'Export successful!\nSaved to: $outputFile';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Export failed: $e';
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _clearData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await surveyRepo.clearAll();
      setState(() {
        _totalEntries = 0;
        _statusMessage = 'All entries cleared.';
      });
    }
  }

  Widget _buildPinView() {
    return Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD4AF37), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Admin Access', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.text,
              style: const TextStyle(color: Colors.white, fontSize: 24),
              decoration: const InputDecoration(hintText: 'Enter Password'),
              readOnly: true, // Prevent system keyboard
              showCursor: true,
              onTap: _showKeyboard,
              onSubmitted: (_) => _verifyPin(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _verifyPin,
              child: const Text('UNLOCK'),
            ),
            if (_statusMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(_statusMessage, style: const TextStyle(color: Colors.red, fontSize: 18)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return Center(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD4AF37), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Admin Dashboard', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 32),
            Text('Total Entries: $_totalEntries', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : _exportToCsv,
                    icon: _isExporting 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                        : const Icon(Icons.download),
                    label: const FittedBox(child: Text('EXPORT TO CSV')),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
                    onPressed: _clearData,
                    icon: const Icon(Icons.delete_forever),
                    label: const FittedBox(child: Text('CLEAR DATA')),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 1, // Optional emphasis over other buttons
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _exitKioskMode,
                    icon: const Icon(Icons.power_settings_new),
                    label: const FittedBox(child: Text('EXIT APP')),
                  ),
                ),
              ],
            ),
            if (_statusMessage.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text(
                _statusMessage, 
                style: const TextStyle(color: Colors.greenAccent, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE', style: TextStyle(color: Colors.white70, fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Background
            AnimatedBackground(
              child: _isAuthenticated ? _buildDashboard() : _buildPinView(),
            ),
            
            // Custom Keyboard
            if (_isKeyboardVisible)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: OnScreenKeyboard(
                  controller: _pinController,
                  onDismiss: _hideKeyboard,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
