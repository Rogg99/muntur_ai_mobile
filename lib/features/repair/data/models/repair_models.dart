/// Mirrors api/apps/api's GarageStaffProfileReadSerializer /
/// RepairBookingReadSerializer as relayed by the backend session (c7,
/// 2026-10-11) after checking serializers.py/viewsets.py directly — not an
/// indicative summary. Backend merged on main (35c4cb0, 38881b4) but no
/// Django migration exists for these models yet, so this contract is not
/// live/testable against a real server until that's resolved and deployed.
library;

const List<String> repairBookingStatusOrder = [
  'pending',
  'accepted',
  'in_progress',
  'completed',
];

class GarageStaffProfile {
  final String id;
  final String relatedGarageId;
  final String garageName;
  final String payoutPhoneNumber;
  final bool active;
  final String dateCreation;

  const GarageStaffProfile({
    required this.id,
    this.relatedGarageId = '',
    this.garageName = '',
    this.payoutPhoneNumber = '',
    this.active = true,
    this.dateCreation = '',
  });

  factory GarageStaffProfile.fromJson(Map<String, dynamic> json) =>
      GarageStaffProfile(
        id: json['id'].toString(),
        // related_garage is just the garage id on this serializer (per c7);
        // garage_name is the already-denormalized display field.
        relatedGarageId: json['related_garage']?.toString() ?? '',
        garageName: json['garage_name']?.toString() ?? '',
        payoutPhoneNumber: json['payout_phone_number']?.toString() ?? '',
        active: json['active'] == true,
        dateCreation: json['date_creation']?.toString() ?? '',
      );
}

class RepairBooking {
  final String id;
  final String relatedGarageId;
  final String garageName;
  final String garageVille;
  final String status; // pending|accepted|in_progress|completed|cancelled|refused
  final String description;
  final String? acceptedAt;
  final String? completedAt;

  /// The completion PIN in clear text — only ever present for the client
  /// who booked it (never the garage side), per c7's contract note.
  final String? completionPinReveal;
  final String dateCreation;

  const RepairBooking({
    required this.id,
    this.relatedGarageId = '',
    this.garageName = '',
    this.garageVille = '',
    this.status = 'pending',
    this.description = '',
    this.acceptedAt,
    this.completedAt,
    this.completionPinReveal,
    this.dateCreation = '',
  });

  factory RepairBooking.fromJson(Map<String, dynamic> json) => RepairBooking(
        id: json['id'].toString(),
        relatedGarageId: json['related_garage']?.toString() ?? '',
        garageName: json['garage_name']?.toString() ?? '',
        garageVille: json['garage_ville']?.toString() ?? '',
        status: json['status']?.toString() ?? 'pending',
        description: json['description']?.toString() ?? '',
        acceptedAt: json['accepted_at']?.toString(),
        completedAt: json['completed_at']?.toString(),
        completionPinReveal: json['completion_pin_reveal']?.toString(),
        dateCreation: json['date_creation']?.toString() ?? '',
      );
}
