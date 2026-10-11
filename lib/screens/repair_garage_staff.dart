import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/garages/domain/entities/garage_entity.dart';
import 'package:munturai/features/garages/presentation/providers/garage_provider.dart';
import 'package:munturai/features/repair/presentation/providers/repair_provider.dart';
import 'package:munturai/screens/repair_garage_dashboard.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:munturai/widgets/primary_button.dart';

/// "Personnel garage" account screen — registration (pick the garage you
/// work for + a payout MoMo number) then a link to the booking dashboard.
/// Unlike courier/vendor there's no separate admin-approval gate in the
/// contract c7 relayed — `active` on GarageStaffProfile is the only flag.
class RepairGarageStaffScreen extends ConsumerStatefulWidget {
  const RepairGarageStaffScreen({super.key});

  @override
  ConsumerState<RepairGarageStaffScreen> createState() =>
      _RepairGarageStaffScreenState();
}

class _RepairGarageStaffScreenState extends ConsumerState<RepairGarageStaffScreen> {
  GarageEntity? _selectedGarage;
  final _phoneController = TextEditingController();
  bool _registering = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickGarage() async {
    final picked = await showDialog<GarageEntity>(
      context: context,
      builder: (_) => const _GaragePickerDialog(),
    );
    if (picked != null) setState(() => _selectedGarage = picked);
  }

  Future<void> _register() async {
    final l10n = AppLocalizations.of(context)!;
    final garage = _selectedGarage;
    final phone = _phoneController.text.trim();
    if (garage == null || phone.isEmpty) {
      setState(() => _error = l10n.repair_staff_missing_fields);
      return;
    }
    setState(() {
      _registering = true;
      _error = null;
    });
    try {
      await ref.read(repairRepositoryProvider).registerAsGarageStaff(
            relatedGarageId: garage.id,
            payoutPhoneNumber: phone,
          );
      ref.invalidate(myGarageStaffProfileProvider);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _registering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final staffAsync = ref.watch(myGarageStaffProfileProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(titleTxt: l10n.repair_staff_title),
      body: staffAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(l10n.repair_load_error, style: appStyle.H5())),
        data: (staff) {
          if (staff == null) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                children: [
                  Icon(Icons.build_circle_outlined, size: 56, color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(l10n.repair_staff_pitch, textAlign: TextAlign.center, style: appStyle.H5()),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: _pickGarage,
                    child: Text(_selectedGarage?.nom ?? l10n.repair_staff_pick_garage),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: appStyle.H6(),
                    decoration: InputDecoration(
                      labelText: l10n.repair_staff_payout_phone_label,
                      hintText: '2376XXXXXXXX',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: appStyle.H6(color: Colors.redAccent)),
                  ],
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: l10n.repair_staff_register_button,
                    loading: _registering,
                    onPressed: _register,
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 56, color: Colors.green),
                const SizedBox(height: 12),
                Text(staff.garageName, style: appStyle.H4(weight: 'bold')),
                const SizedBox(height: 20),
                PrimaryButton(
                  text: l10n.repair_staff_dashboard_button,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RepairGarageDashboard()),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GaragePickerDialog extends ConsumerStatefulWidget {
  const _GaragePickerDialog();

  @override
  ConsumerState<_GaragePickerDialog> createState() => _GaragePickerDialogState();
}

class _GaragePickerDialogState extends ConsumerState<_GaragePickerDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final resultsAsync = ref.watch(garageSearchProvider);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(hintText: l10n.repair_staff_search_garage_hint),
              onChanged: (value) =>
                  ref.read(garageSearchProvider.notifier).search(value),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              width: double.maxFinite,
              child: resultsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
                data: (results) => ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final garage = results[index];
                    return ListTile(
                      title: Text(garage.nom),
                      subtitle: Text(garage.ville),
                      onTap: () => Navigator.pop(context, garage),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
