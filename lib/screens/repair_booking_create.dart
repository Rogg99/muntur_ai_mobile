import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/services/app_lock_guard.dart';
import 'package:munturai/features/repair/presentation/providers/repair_provider.dart';
import 'package:munturai/screens/repair_booking_tracking.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:munturai/widgets/primary_button.dart';

/// Fixed deposit amount per c7's contract — the booking itself has no
/// price field, the 1000 XAF collect is hardcoded server-side on pay/.
const double repairBookingDepositAmount = 1000;
const String repairBookingCurrency = 'XAF';

/// Client-side "déposer ma voiture" flow: describe the issue, then pay the
/// 1000 XAF deposit by MoMo. Unlike the marketplace/coins/subscription
/// flows this doesn't go through the shared PaymentScreen — the backend
/// only exposes a plain pay/ (phone) -> USSD collect for bookings, no
/// pay-by-link/ card option, and RepairBookingReadSerializer has no status
/// distinct from 'pending' for "paid, awaiting garage" vs "awaiting
/// payment" — so there's nothing for a checkDone gate to poll for beyond
/// what the tracking screen already does.
class RepairBookingCreate extends ConsumerStatefulWidget {
  const RepairBookingCreate({
    super.key,
    required this.garageId,
    required this.garageName,
  });

  final String garageId;
  final String garageName;

  @override
  ConsumerState<RepairBookingCreate> createState() => _RepairBookingCreateState();
}

class _RepairBookingCreateState extends ConsumerState<RepairBookingCreate> {
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _descriptionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!await requireAppUnlock(context)) return;
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _error = l10n.marketplace_enter_momo_number);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    final repo = ref.read(repairRepositoryProvider);
    try {
      final booking = await repo.createBooking(
        garageId: widget.garageId,
        description: _descriptionController.text.trim(),
      );
      await repo.payBooking(booking.id, phone);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RepairBookingTracking(bookingId: booking.id),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(titleTxt: l10n.repair_book_action),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.garageName, style: appStyle.H4(weight: 'bold')),
          const SizedBox(height: 8),
          Text(l10n.repair_create_intro, style: appStyle.H6(color: Colors.grey)),
          const SizedBox(height: 20),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            style: appStyle.H6(),
            decoration: InputDecoration(
              labelText: l10n.repair_description_label,
              hintText: l10n.repair_description_hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.repair_deposit_label, style: appStyle.H5()),
              Text(
                '${repairBookingDepositAmount.toStringAsFixed(0)} $repairBookingCurrency',
                style: appStyle.H4(weight: 'bold', color: colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(l10n.repair_deposit_notice, style: appStyle.H6(color: Colors.grey)),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            style: appStyle.H6(),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l10n.marketplace_mobile_money_number_label,
              hintText: '2376XXXXXXXX',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: appStyle.H6(color: Colors.redAccent)),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            text: l10n.repair_pay_deposit_button,
            loading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
