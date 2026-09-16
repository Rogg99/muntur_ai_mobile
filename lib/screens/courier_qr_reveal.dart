import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/widgets/CustomAppBar.dart';

/// Generic "show this QR to the other party" screen — used for both the
/// vendor's pickup QR (shown to the courier) and the courier's dropoff QR
/// (shown to the buyer). [fetchToken] hits whichever endpoint applies;
/// re-fetchable (both are re-viewable server-side until scanned) via pull
/// to refresh isn't needed here since there's nothing to change, but a
/// manual retry button covers a failed fetch.
class CourierQrReveal extends StatefulWidget {
  const CourierQrReveal({
    super.key,
    required this.title,
    required this.instructions,
    required this.fetchToken,
  });

  final String title;
  final String instructions;
  final Future<String> Function() fetchToken;

  @override
  State<CourierQrReveal> createState() => _CourierQrRevealState();
}

class _CourierQrRevealState extends State<CourierQrReveal> {
  String? _token;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await widget.fetchToken();
      if (!mounted) return;
      setState(() {
        _token = token;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(titleTxt: widget.title),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _loading
              ? const CircularProgressIndicator()
              : _error != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center, style: appStyle.H5()),
                        const SizedBox(height: 16),
                        TextButton(
                            onPressed: _load,
                            child: Text(AppLocalizations.of(context)!.retry)),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: QrImageView(
                            data: _token!,
                            size: 220,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(widget.instructions, textAlign: TextAlign.center, style: appStyle.H5()),
                      ],
                    ),
        ),
      ),
    );
  }
}
