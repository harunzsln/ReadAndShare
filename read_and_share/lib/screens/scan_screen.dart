import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _locked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_locked) return;
              final barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;
              final code = barcodes.first.rawValue;
              if (code == null || code.isEmpty) return;
              _locked = true;
              Navigator.pop(context, code);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Align ISBN barcode to camera',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
