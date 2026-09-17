/// Result of a MoMo collect call — the `{status, ussd_code}` shape every
/// Campay-backed endpoint returns the same way (marketplace `pay/`, coins
/// `buy/`, subscription `subscribe/`). Lives in core rather than any one
/// feature's domain since all three now share it via `PaymentScreen`.
class MomoCollectResult {
  final String status;
  final String? ussdCode;

  const MomoCollectResult({required this.status, this.ussdCode});
}
