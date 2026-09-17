import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/auth/presentation/providers/auth_provider.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:munturai/widgets/primary_button.dart';

enum _Step { phone, otp, newPassword }

/// Phone → SMS OTP → new password wizard, against the endpoints a4 shipped
/// in commit 13392fc: POST /auth/password-reset/request|verify|confirm/.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  _Step _step = _Step.phone;
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _submitting = false;
  String? _error;

  // Carried from verify() into confirm() — the confirm endpoint doesn't
  // accept the OTP again, only the short-lived token it exchanges for.
  String? _uid;
  String? _resetToken;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    final translator = AppLocalizations.of(context)!;
    if (_phoneController.text.trim().isEmpty) {
      setState(() => _error = translator.fp_enter_phone_error);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .requestPasswordResetOtp(_phoneController.text.trim());
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _step = _Step.otp;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = translator.fp_send_otp_failed;
      });
    }
  }

  Future<void> _verifyOtp() async {
    final translator = AppLocalizations.of(context)!;
    if (_otpController.text.trim().isEmpty) {
      setState(() => _error = translator.fp_enter_otp_error);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await ref.read(authRepositoryProvider).verifyPasswordResetOtp(
          _phoneController.text.trim(), _otpController.text.trim());
      if (!mounted) return;
      setState(() {
        _uid = result['uid'];
        _resetToken = result['reset_token'];
        _submitting = false;
        _step = _Step.newPassword;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = translator.fp_otp_invalid;
      });
    }
  }

  Future<void> _resetPassword() async {
    final translator = AppLocalizations.of(context)!;
    if (_newPasswordController.text.length < 6) {
      setState(() => _error = translator.fp_password_too_short);
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _error = translator.fp_passwords_mismatch);
      return;
    }
    if (_uid == null || _resetToken == null) {
      setState(() => _error = translator.fp_session_expired);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).confirmPasswordReset(
            uid: _uid!,
            resetToken: _resetToken!,
            newPassword: _newPasswordController.text,
          );
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(translator.fp_reset_success),
      ));
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = translator.fp_reset_failed;
      });
    }
  }

  String _title(AppLocalizations translator) {
    switch (_step) {
      case _Step.phone:
        return translator.fp_title_phone;
      case _Step.otp:
        return translator.fp_title_otp;
      case _Step.newPassword:
        return translator.fp_title_new_password;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final translator = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.background,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(titleTxt: _title(translator)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            translator.fp_step_indicator(_step.index + 1),
            style: appStyle.H6(color: colorScheme.primary),
          ),
          const SizedBox(height: 20),
          ..._buildStepFields(appStyle, colorScheme, translator),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: appStyle.H6(color: Colors.redAccent)),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            text: _step == _Step.newPassword
                ? translator.fp_reset_button
                : translator.continue__,
            loading: _submitting,
            onPressed: () {
              switch (_step) {
                case _Step.phone:
                  _requestOtp();
                  break;
                case _Step.otp:
                  _verifyOtp();
                  break;
                case _Step.newPassword:
                  _resetPassword();
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStepFields(
      AppStyle appStyle, ColorScheme colorScheme, AppLocalizations translator) {
    switch (_step) {
      case _Step.phone:
        return [
          Text(
            translator.fp_phone_instructions,
            style: appStyle.H5(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: appStyle.H5(),
            decoration: InputDecoration(
              hintText: translator.hint_phone,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ];
      case _Step.otp:
        return [
          Text(
            translator.fp_otp_instructions(_phoneController.text),
            style: appStyle.H5(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            style: appStyle.H5(),
            decoration: InputDecoration(
              hintText: translator.fp_otp_hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ];
      case _Step.newPassword:
        return [
          Text(translator.fp_choose_new_password, style: appStyle.H5()),
          const SizedBox(height: 16),
          TextField(
            controller: _newPasswordController,
            obscureText: true,
            style: appStyle.H5(),
            decoration: InputDecoration(
              hintText: translator.fp_new_password_hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            style: appStyle.H5(),
            decoration: InputDecoration(
              hintText: translator.fp_confirm_password_hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ];
    }
  }
}
