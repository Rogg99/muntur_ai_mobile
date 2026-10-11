import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/services/app_lock_service.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:munturai/widgets/primary_button.dart';

const int _pinLength = 4;

/// Shared PIN screen for the local app lock: [isSetup]=true creates/changes
/// the PIN (enter, then confirm), [isSetup]=false verifies it against what
/// is already stored. Pops `true` on success, `false`/null otherwise — the
/// caller (settings toggle, or [requireAppUnlock]) decides what that means.
class AppLockPinScreen extends StatefulWidget {
  const AppLockPinScreen({super.key, required this.isSetup});

  final bool isSetup;

  @override
  State<AppLockPinScreen> createState() => _AppLockPinScreenState();
}

class _AppLockPinScreenState extends State<AppLockPinScreen> {
  final _service = AppLockService();
  final _controller = TextEditingController();
  String? _firstEntry;
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final value = _controller.text.trim();
    if (value.length != _pinLength) return;

    if (!widget.isSetup) {
      setState(() => _submitting = true);
      final ok = await _service.verifyPin(value);
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _submitting = false;
          _error = l10n.applock_wrong_pin;
          _controller.clear();
        });
      }
      return;
    }

    // Setup flow: first pass just captures the candidate PIN, second pass
    // must match it before it's actually saved.
    if (_firstEntry == null) {
      setState(() {
        _firstEntry = value;
        _controller.clear();
        _error = null;
      });
      return;
    }

    if (value != _firstEntry) {
      setState(() {
        _error = l10n.applock_pin_mismatch;
        _firstEntry = null;
        _controller.clear();
      });
      return;
    }

    setState(() => _submitting = true);
    await _service.setPin(value);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final title = !widget.isSetup
        ? l10n.applock_enter_pin_title
        : (_firstEntry == null
            ? l10n.applock_create_pin_title
            : l10n.applock_confirm_pin_title);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(titleTxt: title),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 48, color: colorScheme.primary),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              autofocus: true,
              obscureText: true,
              textAlign: TextAlign.center,
              style: appStyle.H3(weight: 'bold'),
              keyboardType: TextInputType.number,
              maxLength: _pinLength,
              decoration: const InputDecoration(counterText: ''),
              onChanged: (value) {
                if (value.length == _pinLength) _submit();
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: appStyle.H6(color: Colors.redAccent)),
            ],
            const SizedBox(height: 24),
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, value, _) => PrimaryButton(
                text: l10n.marketplace_validate,
                loading: _submitting,
                onPressed:
                    value.text.trim().length == _pinLength ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
