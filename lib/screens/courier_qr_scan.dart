import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/widgets/CustomAppBar.dart';

/// Generic camera QR scanner — pops with the raw scanned string on the
/// first successful detect. Used both for the courier scanning the
/// vendor's pickup QR and the buyer scanning the courier's dropoff QR;
/// the caller decides what to do with the returned token (confirm-pickup/
/// confirm-dropoff each validate it server-side, so no local check here).
class CourierQrScan extends StatefulWidget {
  const CourierQrScan({super.key, required this.title, required this.instructions});

  final String title;
  final String instructions;

  @override
  State<CourierQrScan> createState() => _CourierQrScanState();
}

class _CourierQrScanState extends State<CourierQrScan> {
  bool _handled = false;

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final value = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (value == null || value.isEmpty) return;
    _handled = true;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(titleTxt: widget.title, bgColor: Colors.black),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.instructions,
                  textAlign: TextAlign.center,
                  style: appStyle.H5(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
