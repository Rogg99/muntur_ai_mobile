/// Result of a MoMo collect call — the `{status, ussd_code}` shape every
/// Campay-backed endpoint returns the same way (marketplace `pay/`, coins
/// `buy/`, subscription `subscribe/`). Lives in core rather than any one
/// feature's domain since all three now share it via `PaymentScreen`.
class MomoCollectResult {
  final String status;
  final String? ussdCode;

  const MomoCollectResult({required this.status, this.ussdCode});
}

/// Campay unreachable (backend 503 `{detail, retryable}`, every collect /
/// payment-link endpoint). `retryable: false` means Campay may already have
/// received the request: the user must check their phone before retrying,
/// so screens don't offer a plain "Payer" again. toString() is the backend
/// message, so existing `e.toString()` error displays keep working.
class PaymentUnavailableException implements Exception {
  final String detail;
  final bool retryable;

  const PaymentUnavailableException(this.detail, {required this.retryable});

  @override
  String toString() => detail;
}

/// Turns a failed payment call into the exception screens display: a
/// [PaymentUnavailableException] for the 503 contract, otherwise a plain
/// Exception carrying the backend's `detail` (4xx / 502 business errors).
Exception paymentCallError(int? statusCode, dynamic body) {
  final detail = body is Map ? body['detail']?.toString() : null;
  if (statusCode == 503 && body is Map && body.containsKey('retryable')) {
    return PaymentUnavailableException(
      detail ?? 'Payment service unavailable.',
      retryable: body['retryable'] == true,
    );
  }
  return Exception(detail ?? 'La requête a échoué.');
}
