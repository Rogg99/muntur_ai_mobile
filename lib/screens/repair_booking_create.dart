import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/models/payment_models.dart';
import 'package:munturai/core/services/app_lock_guard.dart';
import 'package:munturai/features/repair/presentation/providers/repair_provider.dart';
import 'package:munturai/screens/map_point_picker.dart';
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

  // Created once and reused if the deposit payment fails and the user
  // retries — otherwise every retry would leave an orphan booking with the
  // garage. Reset when the booking's own inputs change.
  String? _createdBookingId;

  // 503 retryable:false — Campay may have the request; see PaymentScreen.
  bool _mustCheckPhone = false;

  // Doc/17 §2.1: at_garage (default) or on_site — on_site requires the
  // intervention point, chosen on the map (never the raw GPS fix).
  String _serviceMode = 'at_garage';
  LatLng? _clientPoint;

  Future<void> _pickClientPoint() async {
    final l10n = AppLocalizations.of(context)!;
    final point = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPointPicker(
          title: l10n.repair_on_site_point_title,
          initialPoint: _clientPoint,
        ),
      ),
    );
    if (point == null || !mounted) return;
    setState(() {
      _clientPoint = point;
      _error = null;
      _createdBookingId = null;
    });
  }

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
    if (_serviceMode == 'on_site' && _clientPoint == null) {
      setState(() => _error = l10n.repair_on_site_point_required);
      return;
    }
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
      final bookingId = _createdBookingId ??= (await repo.createBooking(
        garageId: widget.garageId,
        description: _descriptionController.text.trim(),
        serviceMode: _serviceMode,
        clientLatitude: _clientPoint?.latitude,
        clientLongitude: _clientPoint?.longitude,
      ))
          .id;
      await repo.payBooking(bookingId, phone);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RepairBookingTracking(bookingId: bookingId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      if (e is PaymentUnavailableException) _mustCheckPhone = !e.retryable;
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
          Text(l10n.repair_service_mode_label, style: appStyle.H5()),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text(l10n.repair_mode_at_garage),
                selected: _serviceMode == 'at_garage',
                onSelected: (_) => setState(() {
                  _serviceMode = 'at_garage';
                  _createdBookingId = null;
                }),
              ),
              ChoiceChip(
                label: Text(l10n.repair_mode_on_site),
                selected: _serviceMode == 'on_site',
                onSelected: (_) => setState(() {
                  _serviceMode = 'on_site';
                  _createdBookingId = null;
                }),
              ),
            ],
          ),
          if (_serviceMode == 'on_site')
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.location_on_outlined, color: colorScheme.primary),
              title: Text(l10n.repair_on_site_point_title, style: appStyle.H5()),
              subtitle: Text(
                _clientPoint == null
                    ? l10n.repair_on_site_point_none
                    : l10n.checkout_delivery_point_set,
                style: appStyle.H6(color: Colors.grey),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickClientPoint,
            ),
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
          if (_mustCheckPhone)
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
              onPressed: () => setState(() {
                _mustCheckPhone = false;
                _error = null;
              }),
              child: Text(l10n.payment_checked_phone_retry),
            )
          else
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
