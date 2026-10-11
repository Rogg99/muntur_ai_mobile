import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/services/app_lock_service.dart';
import 'package:munturai/screens/app_lock_pin_screen.dart';

/// Call before any sensitive action (payment, password change, ...). Returns
/// true immediately if the lock is disabled. Otherwise tries biometrics
/// first; on anything but a genuine success it falls back to the app PIN
/// screen. Returns false if the user cancels/fails both.
Future<bool> requireAppUnlock(BuildContext context) async {
  final service = AppLockService();
  if (!await service.isEnabled()) return true;
  if (!context.mounted) return false;

  final l10n = AppLocalizations.of(context)!;
  if (await service.canUseBiometrics()) {
    final ok = await service.authenticateWithBiometrics(
      l10n.applock_biometric_reason,
    );
    if (ok) return true;
    if (!context.mounted) return false;
  }

  if (!await service.hasPin()) {
    // Lock was enabled but no PIN ever got set (shouldn't normally happen —
    // Settings requires one) — treat as unlocked rather than stranding the
    // user with no way to confirm.
    return true;
  }

  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => const AppLockPinScreen(isSetup: false)),
  );
  return result ?? false;
}
