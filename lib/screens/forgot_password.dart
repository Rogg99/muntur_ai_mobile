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
    if (_phoneController.text.trim().isEmpty) {
      setState(() => _error = 'Entrez votre numéro de téléphone');
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
        _error = "Impossible d'envoyer le code. Vérifiez le numéro et réessayez.";
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      setState(() => _error = 'Entrez le code reçu par SMS');
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
        _error = 'Code invalide ou expiré.';
      });
    }
  }

  Future<void> _resetPassword() async {
    if (_newPasswordController.text.length < 6) {
      setState(() => _error = 'Le mot de passe doit contenir au moins 6 caractères');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _error = 'Les mots de passe ne correspondent pas');
      return;
    }
    if (_uid == null || _resetToken == null) {
      setState(() => _error = 'Session expirée, recommencez depuis le début.');
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Mot de passe réinitialisé. Vous pouvez vous connecter.'),
      ));
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'La réinitialisation a échoué. Réessayez.';
      });
    }
  }

  String get _title {
    switch (_step) {
      case _Step.phone:
        return 'Mot de passe oublié';
      case _Step.otp:
        return 'Vérification';
      case _Step.newPassword:
        return 'Nouveau mot de passe';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(titleTxt: _title),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Étape ${_step.index + 1}/3',
            style: appStyle.H6(color: colorScheme.primary),
          ),
          const SizedBox(height: 20),
          ..._buildStepFields(appStyle, colorScheme),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: appStyle.H6(color: Colors.redAccent)),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            text: _step == _Step.newPassword ? 'Réinitialiser' : 'Continuer',
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

  List<Widget> _buildStepFields(AppStyle appStyle, ColorScheme colorScheme) {
    switch (_step) {
      case _Step.phone:
        return [
          Text(
            'Entrez le numéro de téléphone associé à votre compte. Un code vous sera envoyé par SMS.',
            style: appStyle.H5(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: appStyle.H5(),
            decoration: InputDecoration(
              hintText: 'Numéro de téléphone',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ];
      case _Step.otp:
        return [
          Text(
            'Entrez le code à 6 chiffres reçu par SMS au ${_phoneController.text}.',
            style: appStyle.H5(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            style: appStyle.H5(),
            decoration: InputDecoration(
              hintText: 'Code de vérification',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ];
      case _Step.newPassword:
        return [
          Text('Choisissez un nouveau mot de passe.', style: appStyle.H5()),
          const SizedBox(height: 16),
          TextField(
            controller: _newPasswordController,
            obscureText: true,
            style: appStyle.H5(),
            decoration: InputDecoration(
              hintText: 'Nouveau mot de passe',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            style: appStyle.H5(),
            decoration: InputDecoration(
              hintText: 'Confirmer le mot de passe',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ];
    }
  }
}
