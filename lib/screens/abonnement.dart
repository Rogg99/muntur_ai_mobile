import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/subscriptions/domain/entities/subscription_entity.dart';
import 'package:munturai/features/subscriptions/presentation/providers/subscription_provider.dart';
import 'package:munturai/screens/payment_screen.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final currentSubAsync = ref.watch(currentSubscriptionProvider);
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final coinsAsync = ref.watch(coinsBalanceProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        centerTitle: true,
        elevation: 0,
        title: Text('Abonnements', style: appStyle.H3(weight: 'bold')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Solde Coins ───
            coinsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (coins) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.primary.withValues(alpha: 0.7)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on,
                        color: Colors.amber, size: 36),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Solde Coins',
                            style: appStyle.H6(color: Colors.white70)),
                        Text('$coins pièces',
                            style: appStyle.H3(
                                weight: 'bold', color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ─── Abonnement actif ───
            Text('Mon abonnement', style: appStyle.H4(weight: 'bold')),
            const SizedBox(height: 12),
            currentSubAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erreur : $e'),
              data: (sub) => sub == null
                  ? _freeBadge(appStyle, colorScheme)
                  : _CurrentSubCard(
                      sub: sub, appStyle: appStyle, colorScheme: colorScheme),
            ),

            const SizedBox(height: 24),

            // ─── Plans ───
            Text('Plans disponibles', style: appStyle.H4(weight: 'bold')),
            const SizedBox(height: 12),
            plansAsync.when(
              loading: () => Center(
                  child: CircularProgressIndicator(color: colorScheme.primary)),
              error: (e, _) => Text('Erreur : $e'),
              data: (plans) => plans.isEmpty
                  ? Text('Aucun plan disponible', style: appStyle.H5())
                  : Column(
                      children: plans.map((p) => _PlanCard(plan: p)).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _freeBadge(AppStyle appStyle, ColorScheme colorScheme) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(Icons.star_border, color: colorScheme.primary),
            const SizedBox(width: 12),
            Text('Plan Gratuit', style: appStyle.H5(weight: 'bold')),
          ],
        ),
      );
}

class _CurrentSubCard extends StatelessWidget {
  final SubscriptionEntity sub;
  final AppStyle appStyle;
  final ColorScheme colorScheme;
  const _CurrentSubCard(
      {required this.sub, required this.appStyle, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              Text('Plan ${sub.type}',
                  style: appStyle.H4(weight: 'bold', color: Colors.white)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  sub.isExpired ? 'Expiré' : 'Actif',
                  style: appStyle.H6(color: Colors.white),
                ),
              ),
            ],
          ),
          if (sub.expiresAt > 0) ...[
            const SizedBox(height: 12),
            Text(
              'Expire le : ${_formatDate(sub.expiresAt)}',
              style: appStyle.H6(color: Colors.white70),
            ),
          ],
          if (sub.coins > 0) ...[
            const SizedBox(height: 8),
            Text(
              '${sub.coins} coins inclus',
              style: appStyle.H6(color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(int ts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _PlanCard extends ConsumerWidget {
  final SubscriptionPlanEntity plan;
  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.type, style: appStyle.H5(weight: 'bold')),
                  if (plan.description.isNotEmpty)
                    Text(plan.description, style: appStyle.H6()),
                  Text('${plan.days} jours',
                      style: appStyle.H6(
                          color: colorScheme.onSurface.withValues(alpha: 0.6))),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${plan.price.toStringAsFixed(0)} ${plan.currency}',
                  style:
                      appStyle.H5(weight: 'bold', color: colorScheme.primary),
                ),
                const SizedBox(height: 6),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => _goToPayment(context, ref, plan),
                  child: const Text('Souscrire'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _goToPayment(
      BuildContext context, WidgetRef ref, SubscriptionPlanEntity plan) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PaymentScreen(
        title: 'Souscription',
        itemTitle: 'Plan ${plan.type}',
        itemSubtitle: plan.description.isNotEmpty
            ? plan.description
            : '${plan.days} jours',
        amount: plan.price,
        currency: plan.currency,
        pendingMessage:
            'En attente de confirmation du paiement Mobile Money...',
        successUrl: subscriptionPaymentSuccessUrl,
        failureUrl: subscriptionPaymentFailureUrl,
        onMomoPay: (phone) => ref
            .read(currentSubscriptionProvider.notifier)
            .subscribe(plan.code, phone),
        onCardPay: () => ref
            .read(currentSubscriptionProvider.notifier)
            .subscribeByLink(plan.code),
        checkDone: () async {
          ref.invalidate(currentSubscriptionProvider);
          final sub = await ref.read(currentSubscriptionProvider.future);
          return sub != null && sub.code == plan.code && sub.active;
        },
        onSuccess: () {
          ref.invalidate(currentSubscriptionProvider);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Souscription activée !')),
          );
        },
      ),
    ));
  }
}
