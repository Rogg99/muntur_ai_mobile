import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:munturai/features/auth/presentation/providers/auth_provider.dart';
import 'package:munturai/widgets/primary_button.dart';
import '../core/app_export.dart';
import 'package:munturai/utils/divisionsFilter.dart';
import 'package:munturai/model/user.dart';

import 'home.dart';

class Signup2 extends ConsumerStatefulWidget {
  const Signup2({Key? key}) : super(key: key);

  @override
  ConsumerState<Signup2> createState() => _signupState();
}

class _signupState extends ConsumerState<Signup2> {
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _pageController = PageController();

  int pageIndex = 0;
  bool show_loading = false;

  // ── Étape 1 — compte ──────────────────────────────────────────────────
  final namecontroller = TextEditingController();
  final prenomcontroller = TextEditingController();
  final emailcontroller = TextEditingController();
  final pwdcontroller = TextEditingController();
  final pwdCfcontroller = TextEditingController();
  bool _pwdVisible = false;
  bool _pwdCfVisible = false;

  // ── Étape 2 — profil ─────────────────────────────────────────────────
  final phonecontroller = TextEditingController();
  final villecontroller = TextEditingController();
  String selectedIndicator = '+237';
  String selectedPays = 'Cameroon';
  final List<String> allPays = countries_eng;
  bool sexe = false; // false = homme, true = femme (contrat backend inchangé)
  DateTime? _birthDate;
  String? _birthDateError;

  @override
  void dispose() {
    namecontroller.dispose();
    prenomcontroller.dispose();
    emailcontroller.dispose();
    pwdcontroller.dispose();
    pwdCfcontroller.dispose();
    phonecontroller.dispose();
    villecontroller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep2() {
    if (!(_step1FormKey.currentState?.validate() ?? false)) return;
    setState(() => pageIndex = 1);
    _pageController.animateToPage(1,
        duration: const Duration(milliseconds: 320), curve: Curves.easeOut);
  }

  void _goToStep1() {
    setState(() => pageIndex = 0);
    _pageController.animateToPage(0,
        duration: const Duration(milliseconds: 320), curve: Curves.easeOut);
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1930),
      lastDate: now,
      helpText: AppLocalizations.of(context)!.birthDateLabel,
    );
    if (picked != null && mounted) {
      setState(() {
        _birthDate = picked;
        _birthDateError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final translator = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return PopScope(
      canPop: pageIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && pageIndex == 1) _goToStep1();
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (pageIndex == 1) {
                _goToStep1();
              } else {
                Navigator.maybePop(context);
              }
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(translator.register, style: appStyle.H3(weight: 'bold')),
                  Padding(padding: getPadding(top: 16)),
                  Row(
                    children: [
                      for (int i = 0; i < 2; i++) ...[
                        if (i > 0) Padding(padding: getPadding(left: 6)),
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: i <= pageIndex
                                  ? cs.secondary
                                  : cs.secondary.withOpacity(0.2),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Padding(padding: getPadding(top: 10)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      pageIndex == 0
                          ? translator.register_step1_title
                          : translator.register_step2_title,
                      style: appStyle.H6(color: cs.secondary, weight: 'bold'),
                    ),
                  ),
                ],
              ),
            ),
            Padding(padding: getPadding(top: 10)),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(appStyle, translator, cs),
                  _buildStep2(appStyle, translator, cs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Étape 1 ──────────────────────────────────────────────────────────

  Widget _buildStep1(
      AppStyle appStyle, AppLocalizations translator, ColorScheme cs) {
    return Form(
      key: _step1FormKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        children: [
          _field(
            controller: namecontroller,
            label: translator.firstNameHint,
            icon: Icons.badge_outlined,
            cs: cs,
            appStyle: appStyle,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? translator.register_error_required : null,
          ),
          Padding(padding: getPadding(top: 16)),
          _field(
            controller: prenomcontroller,
            label: translator.secondNameHint,
            icon: Icons.badge_outlined,
            cs: cs,
            appStyle: appStyle,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? translator.register_error_required : null,
          ),
          Padding(padding: getPadding(top: 16)),
          _field(
            controller: emailcontroller,
            label: translator.emailHint,
            icon: Icons.alternate_email,
            keyboardType: TextInputType.emailAddress,
            cs: cs,
            appStyle: appStyle,
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return translator.register_error_required;
              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                return translator.register_error_email_invalid;
              }
              return null;
            },
          ),
          Padding(padding: getPadding(top: 16)),
          _field(
            controller: pwdcontroller,
            label: translator.password_hint,
            icon: Icons.lock_outline,
            cs: cs,
            appStyle: appStyle,
            obscure: !_pwdVisible,
            suffixIcon: IconButton(
              icon: Icon(_pwdVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              onPressed: () => setState(() => _pwdVisible = !_pwdVisible),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return translator.register_error_required;
              if (v.length < 6) return translator.register_error_password_short;
              return null;
            },
          ),
          Padding(padding: getPadding(top: 16)),
          _field(
            controller: pwdCfcontroller,
            label: translator.hint_password_confirm,
            icon: Icons.lock_outline,
            cs: cs,
            appStyle: appStyle,
            obscure: !_pwdCfVisible,
            suffixIcon: IconButton(
              icon: Icon(_pwdCfVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              onPressed: () => setState(() => _pwdCfVisible = !_pwdCfVisible),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return translator.register_error_required;
              if (v != pwdcontroller.text) {
                return translator.register_error_password_mismatch;
              }
              return null;
            },
          ),
          Padding(padding: getPadding(top: 28)),
          PrimaryButton(
            text: translator.next,
            onPressed: _goToStep2,
          ),
        ],
      ),
    );
  }

  // ── Étape 2 ──────────────────────────────────────────────────────────

  Widget _buildStep2(
      AppStyle appStyle, AppLocalizations translator, ColorScheme cs) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
      children: [
        Form(
          key: _step2FormKey,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 132,
                    child: _pickerField(
                      label: translator.register_phone_code_label,
                      value: selectedIndicator,
                      icon: Icons.flag_outlined,
                      cs: cs,
                      appStyle: appStyle,
                      onTap: () => _showPicker(
                        title: translator.register_phone_code_label,
                        items: const ['+237', '+242', '+227'],
                        selected: selectedIndicator,
                        onSelected: (v) => setState(() => selectedIndicator = v),
                      ),
                    ),
                  ),
                  Padding(padding: getPadding(left: 10)),
                  Expanded(
                    child: _field(
                      controller: phonecontroller,
                      label: translator.phoneHint,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      cs: cs,
                      appStyle: appStyle,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? translator.register_error_required
                          : null,
                    ),
                  ),
                ],
              ),
              Padding(padding: getPadding(top: 16)),
              _field(
                controller: villecontroller,
                label: translator.enter_city_hint,
                icon: Icons.location_city_outlined,
                cs: cs,
                appStyle: appStyle,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? translator.register_error_required
                    : null,
              ),
              Padding(padding: getPadding(top: 16)),
              _pickerField(
                label: translator.countryHint,
                value: selectedPays,
                icon: Icons.public,
                cs: cs,
                appStyle: appStyle,
                onTap: () => _showPicker(
                  title: translator.countryHint,
                  items: allPays,
                  selected: selectedPays,
                  onSelected: (v) => setState(() => selectedPays = v),
                ),
              ),
              Padding(padding: getPadding(top: 16)),
              _labeledContainer(
                cs: cs,
                icon: Icons.wc,
                label: translator.genderLabel,
                appStyle: appStyle,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _genderChip(
                      label: translator.genderMale,
                      selected: !sexe,
                      cs: cs,
                      appStyle: appStyle,
                      onTap: () => setState(() => sexe = false),
                    ),
                    Padding(padding: getPadding(left: 8)),
                    _genderChip(
                      label: translator.genderFemale,
                      selected: sexe,
                      cs: cs,
                      appStyle: appStyle,
                      onTap: () => setState(() => sexe = true),
                    ),
                  ],
                ),
              ),
              Padding(padding: getPadding(top: 16)),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _pickBirthDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _birthDateError != null
                          ? Colors.redAccent
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cake_outlined, color: cs.primary),
                      Padding(padding: getPadding(left: 10)),
                      Text(
                        _birthDate == null
                            ? translator.register_select_birthdate
                            : DateFormat('dd/MM/yyyy').format(_birthDate!),
                        style: appStyle.H6(
                          color: _birthDate == null ? cs.outline : null,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.calendar_today_outlined,
                          size: 18, color: cs.outline),
                    ],
                  ),
                ),
              ),
              if (_birthDateError != null) ...[
                Padding(padding: getPadding(top: 6)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _birthDateError!,
                    style: appStyle.H6().copyWith(color: Colors.redAccent, fontSize: 12),
                  ),
                ),
              ],
              Padding(padding: getPadding(top: 28)),
              PrimaryButton(
                text: translator.register,
                onPressed: register,
                loading: show_loading,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Champs réutilisables ─────────────────────────────────────────────

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme cs,
    required AppStyle appStyle,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: appStyle.H6(),
      keyboardType: keyboardType,
      obscureText: obscure,
      cursorColor: cs.primary,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        prefixIcon: Icon(icon, color: cs.primary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  Widget _labeledContainer({
    required ColorScheme cs,
    required IconData icon,
    required String label,
    required AppStyle appStyle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary),
          Padding(padding: getPadding(left: 10)),
          Text(label, style: appStyle.H6()),
          const Spacer(),
          child,
        ],
      ),
    );
  }

  /// A field that looks like [_field] (same filled/rounded chrome, small
  /// floating-style label) but opens [_showPicker] instead of a keyboard —
  /// used for the phone country code and the country selector, in place of
  /// a native DropdownButton menu.
  Widget _pickerField({
    required String label,
    required String value,
    required IconData icon,
    required ColorScheme cs,
    required AppStyle appStyle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: cs.primary, size: 20),
            Padding(padding: getPadding(left: 10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      style: appStyle.H6().copyWith(fontSize: 11, color: cs.outline)),
                  Text(value,
                      style: appStyle.H6(),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.expand_more, color: cs.outline),
          ],
        ),
      ),
    );
  }

  /// A modal bottom sheet list picker — replaces the native OS dropdown
  /// menu previously used for the phone code and country fields.
  Future<void> _showPicker({
    required String title,
    required List<String> items,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    final cs = Theme.of(context).colorScheme;
    final appStyle = AppStyle.of(context);
    return showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: items.length > 8 ? 0.7 : 0.35,
          minChildSize: 0.25,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.outline.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(title, style: appStyle.H5(weight: 'bold')),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      final isSelected = item == selected;
                      return ListTile(
                        title: Text(item, style: appStyle.H6()),
                        trailing: isSelected
                            ? Icon(Icons.check, color: cs.primary)
                            : null,
                        onTap: () {
                          onSelected(item);
                          Navigator.pop(sheetContext);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _genderChip({
    required String label,
    required bool selected,
    required ColorScheme cs,
    required AppStyle appStyle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? cs.primary : cs.outline),
        ),
        child: Text(
          label,
          style: appStyle.H6(color: selected ? cs.onPrimary : null),
        ),
      ),
    );
  }

  // ── Soumission ───────────────────────────────────────────────────────

  Future<void> register() async {
    if (show_loading || !mounted) return;
    final translator = AppLocalizations.of(context)!;

    final step2Valid = _step2FormKey.currentState?.validate() ?? false;
    setState(() {
      _birthDateError =
          _birthDate == null ? translator.register_error_birthdate_required : null;
    });
    if (!step2Valid || _birthDateError != null) return;

    final age = _ageFor(_birthDate!);
    if (age < 14) {
      setState(() => _birthDateError = translator.register_error_age_min);
      return;
    }

    log('muntur DEBUG: -- Signup-- starting register');
    setState(() => show_loading = true);

    final inscription = User(
      nom: namecontroller.text.trim(),
      prenom: prenomcontroller.text.trim(),
      email: emailcontroller.text.trim(),
      password: pwdcontroller.text,
      telephone: '$selectedIndicator${phonecontroller.text.trim()}',
      ville: villecontroller.text.trim(),
      photo: 'none',
      sexe: sexe ? 'FEMALE' : 'MALE',
      date_naissance: DateFormat('yyyy-MM-dd').format(_birthDate!),
      pays: selectedPays,
    );

    try {
      // toMap2() includes password/username/last_name, required by the
      // backend's registration endpoint — toMap() omits all three.
      await ref.read(authStateProvider.notifier).register(inscription.toMap2());
      if (!mounted) return;
      toast(translator.register_success);
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (e) {
      if (!mounted) return;
      log('Muntur DEBUG exception: $e');
      toast(translator.register_failed, color: Colors.grey);
    } finally {
      if (mounted) setState(() => show_loading = false);
    }
  }

  int _ageFor(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
