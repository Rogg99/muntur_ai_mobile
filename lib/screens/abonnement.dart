import 'package:flutter/material.dart';
import 'package:munturai/widgets/primary_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/subscriptions/domain/entities/subscription_entity.dart';
import 'package:munturai/features/subscriptions/presentation/providers/subscription_provider.dart';
import 'package:munturai/screens/payment_screen.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key, this.planType});

  /// Only show plans of this type (e.g. 'Pro' for garage owners).
  final String? planType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final currentSubAsync = ref.watch(currentSubscriptionProvider);
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final coinsAsync = ref.watch(coinsBalanceProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        centerTitle: true,
        elevation: 0,
        title: Text(l10n.subscriptions_screen_title,
            style: appStyle.H3(weight: 'bold')),
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
                        Text(l10n.coins_balance_label,
                            style: appStyle.H6(color: Colors.white70)),
                        Text('$coins ${l10n.coins_unit_label}',
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
            Text(l10n.my_subscription_label,
                style: appStyle.H4(weight: 'bold')),
            const SizedBox(height: 12),
            currentSubAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('${l10n.error_prefix} : $e'),
              data: (sub) => sub == null
                  ? _freeBadge(appStyle, colorScheme, l10n)
                  : _CurrentSubCard(
                      sub: sub, appStyle: appStyle, colorScheme: colorScheme),
            ),

            const SizedBox(height: 24),

            // ─── Plans ───
            Text(l10n.available_plans_label,
                style: appStyle.H4(weight: 'bold')),
            const SizedBox(height: 12),
            plansAsync.when(
              loading: () => Center(
                  child: CircularProgressIndicator(color: colorScheme.primary)),
              error: (e, _) => Text('${l10n.error_prefix} : $e'),
              data: (all) {
                final plans = planType == null
                    ? all
                    : all.where((p) => p.type == planType).toList();
                return plans.isEmpty
                    ? Text(l10n.no_plan_available_label, style: appStyle.H5())
                    : Column(
                        children: plans.map((p) => _PlanCard(plan: p)).toList(),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _freeBadge(
          AppStyle appStyle, ColorScheme colorScheme, AppLocalizations l10n) =>
      Container(
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
            Text(l10n.free_plan_label, style: appStyle.H5(weight: 'bold')),
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
    final l10n = AppLocalizations.of(context)!;
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
              Text('${l10n.subscription_plan_prefix} ${sub.type}',
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
                  sub.isExpired
                      ? l10n.subscription_status_expired
                      : l10n.subscription_status_active,
                  style: appStyle.H6(color: Colors.white),
                ),
              ),
            ],
          ),
          if (sub.expiresAt > 0) ...[
            const SizedBox(height: 12),
            Text(
              '${l10n.subscription_expires_label} ${_formatDate(sub.expiresAt)}',
              style: appStyle.H6(color: Colors.white70),
            ),
          ],
          if (sub.coins > 0) ...[
            const SizedBox(height: 8),
            Text(
              '${sub.coins} ${l10n.coins_included_suffix}',
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDetails(context, ref),
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
                    Text(AppLocalizations.of(context)!.days(plan.days),
                        style: appStyle.H6(
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.6))),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => _goToPayment(context, ref, plan),
                    child: Text(
                        AppLocalizations.of(context)!.subscribe_button_label),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => _PlanDetailsSheet(
        plan: plan,
        onSubscribe: () {
          Navigator.pop(sheetContext);
          _goToPayment(context, ref, plan);
        },
      ),
    );
  }

  void _goToPayment(
      BuildContext context, WidgetRef ref, SubscriptionPlanEntity plan) {
    final l10n = AppLocalizations.of(context)!;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PaymentScreen(
        title: l10n.subscriptions_screen_title,
        itemTitle: '${l10n.subscription_plan_prefix} ${plan.type}',
        itemSubtitle: plan.description.isNotEmpty
            ? plan.description
            : l10n.days(plan.days),
        amount: plan.price,
        currency: plan.currency,
        pendingMessage: l10n.marketplace_payment_pending_notice,
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
            SnackBar(content: Text(l10n.subscription_activated_message)),
          );
        },
      ),
    ));
  }
}

/// Plan details (price, duration, coins bonus, commission, perks) with the
/// subscribe action; opened by tapping a plan card.
class _PlanDetailsSheet extends StatelessWidget {
  final SubscriptionPlanEntity plan;
  final VoidCallback onSubscribe;
  const _PlanDetailsSheet({required this.plan, required this.onSubscribe});

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final commission = (plan.commissionRate * 100);

    Widget fact(IconData icon, String label, String value) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Icon(icon, color: colorScheme.primary, size: 20),
                const SizedBox(height: 6),
                Text(value,
                    style: appStyle.H5(weight: 'bold'),
                    textAlign: TextAlign.center),
                Text(label,
                    style: appStyle.H6(
                        color: colorScheme.onSurface.withValues(alpha: 0.6)),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        );

    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            20, 0, 20, 20 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Header: name + price ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    Color.lerp(colorScheme.primary, Colors.black, 0.45)!,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l10n.subscription_plan_prefix} ${plan.type}',
                      style: appStyle.H6(color: Colors.white70)),
                  const SizedBox(height: 4),
                  if (plan.description.isNotEmpty)
                    Text(plan.description,
                        style: appStyle
                            .H4(weight: 'bold')
                            .copyWith(color: Colors.white)),
                  const SizedBox(height: 12),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                      text: plan.price.toStringAsFixed(0),
                      style: appStyle
                          .H1(weight: 'bold')
                          .copyWith(color: Colors.white),
                    ),
                    TextSpan(
                      text: ' ${plan.currency}',
                      style: appStyle.H5(color: Colors.white70),
                    ),
                  ])),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ─── Key facts ───
            Row(
              children: [
                fact(Icons.calendar_month_outlined, l10n.plan_duration_label,
                    l10n.days(plan.days)),
                if (plan.coinsBonus > 0) ...[
                  const SizedBox(width: 10),
                  fact(Icons.toll_outlined, l10n.coins_included_suffix,
                      '${plan.coinsBonus}'),
                ],
                if (plan.commissionRate > 0) ...[
                  const SizedBox(width: 10),
                  fact(Icons.percent, l10n.plan_commission_label,
                      '${commission.toStringAsFixed(commission % 1 == 0 ? 0 : 1)} %'),
                ],
              ],
            ),
            // ─── Perks ───
            if (plan.features.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(l10n.plan_features_label,
                  style: appStyle.H5(weight: 'bold')),
              const SizedBox(height: 10),
              for (final feature in plan.features)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: colorScheme.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(feature, style: appStyle.H5())),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 16),
            if (plan.price > 0)
              PrimaryButton(
                text: l10n.subscribe_button_label,
                padding: 14,
                onPressed: onSubscribe,
              ),
          ],
        ),
      ),
    );
  }
}
