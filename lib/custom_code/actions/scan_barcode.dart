import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

Future<void> scanBarcode(BuildContext context) async {
  FFAppState().globalBarcode = '';
  final code = await Navigator.of(context).push<String>(
    MaterialPageRoute(builder: (_) => const _BarcodeScannerPage()),
  );
  FFAppState().globalBarcode = code ?? '';
}

class _BarcodeScannerPage extends StatefulWidget {
  const _BarcodeScannerPage();

  @override
  State<_BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<_BarcodeScannerPage> {
  final _controller = MobileScannerController(
    torchEnabled: false,
    formats: const [
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.ean8,
      BarcodeFormat.ean13,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.itf,
    ],
  );
  bool _closing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Escanear código'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              if (_closing) return;
              _closing = true;
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () => _controller.toggleTorch(),
            ),
          ],
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                if (!mounted || _closing || capture.barcodes.isEmpty) return;
                final code = capture.barcodes.first.rawValue
                    ?.replaceAll('\n', '')
                    .trim();
                if (code == null || code.isEmpty) return;
                _closing = true;
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop(code);
              },
            ),
            IgnorePointer(
              child: Center(
                child: Container(
                  width: 280,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.greenAccent, width: 3),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
