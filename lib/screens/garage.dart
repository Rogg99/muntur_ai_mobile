import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/garages/domain/entities/garage_entity.dart';
import 'package:munturai/features/garages/presentation/providers/garage_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// ──────────────────────────────────────────────────────────────────────────────
// GARAGES LIST SCREEN
// ──────────────────────────────────────────────────────────────────────────────

class GaragesScreen extends ConsumerStatefulWidget {
  const GaragesScreen({super.key});

  @override
  ConsumerState<GaragesScreen> createState() => _GaragesScreenState();
}

class _GaragesScreenState extends ConsumerState<GaragesScreen> {
  final _searchController = TextEditingController();
  bool _searching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final garagesAsync = _searching
        ? ref.watch(garageSearchProvider)
        : ref.watch(garagesAroundProvider());

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        centerTitle: true,
        title: const Text('Garages'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // ─── Search bar ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: appStyle.H6(),
              onChanged: (value) {
                setState(() => _searching = value.isNotEmpty);
                if (value.isNotEmpty) {
                  ref.read(garageSearchProvider.notifier).search(value);
                }
              },
              decoration: InputDecoration(
                hintText: 'Rechercher un garage…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searching
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searching = false);
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ),

          // ─── Results ───
          Expanded(
            child: garagesAsync.when(
              loading: () => Center(
                  child: CircularProgressIndicator(color: colorScheme.primary)),
              error: (e, _) => Center(child: Text('Erreur : $e')),
              data: (garages) {
                if (garages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.garage_outlined,
                            size: 64,
                            color: colorScheme.onSurface.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        Text('Aucun garage trouvé', style: appStyle.H5()),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Actualiser'),
                          onPressed: () => ref
                              .read(garagesAroundProvider().notifier)
                              .refresh(),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(garagesAroundProvider().notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: garages.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (ctx, i) => _GarageTile(garage: garages[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// GARAGE LIST TILE
// ──────────────────────────────────────────────────────────────────────────────

class _GarageTile extends StatelessWidget {
  final GarageEntity garage;
  const _GarageTile({required this.garage});

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: garage.photo.isNotEmpty
            ? Image.network(garage.photo,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _GaragePlaceholder())
            : const _GaragePlaceholder(),
      ),
      title: Text(garage.nom, style: appStyle.H5(weight: 'bold')),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${garage.ville}, ${garage.pays}', style: appStyle.H6()),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.star, size: 14, color: colorScheme.primary),
              const SizedBox(width: 3),
              Text(garage.rating.toStringAsFixed(1), style: appStyle.H6()),
              const SizedBox(width: 12),
              if (garage.distance > 0)
                Text('${garage.distance.toStringAsFixed(1)} km',
                    style: appStyle.H6()),
            ],
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GarageDetails(garage: garage)),
      ),
    );
  }
}

class _GaragePlaceholder extends StatelessWidget {
  const _GaragePlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.garage_outlined),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// GARAGE DETAIL SCREEN
// ──────────────────────────────────────────────────────────────────────────────

/// Only entries that are actually a displayable URL are kept — GarageSerializer
/// (used for reads too, no read/write split server-side) currently returns
/// `medias` as bare Media UUIDs, not resolvable photo URLs. Once the backend
/// nests them ({id, file, kind, ...}, same shape used for messages/news),
/// this starts rendering them with no client change needed — a bare id (or
/// any other non-URL value) is skipped rather than shown broken.
List<String> _displayableMediaUrls(String rawMedias) {
  List<dynamic> list = [];
  try {
    list = jsonDecode(rawMedias) as List;
  } catch (_) {}
  return list
      .map((item) => item is Map ? item['file']?.toString() ?? '' : item.toString())
      .where((url) => url.startsWith('http'))
      .toList();
}

class GarageDetails extends StatelessWidget {
  final GarageEntity garage;
  const GarageDetails({super.key, required this.garage});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  /// Parses "HH:mm" against the current time — best-effort, defaults to
  /// null (hidden badge) rather than guessing on a malformed value.
  bool? _isOpenNow() {
    try {
      final now = TimeOfDay.now();
      final nowMinutes = now.hour * 60 + now.minute;
      final open = garage.heureOuverture.split(':');
      final close = garage.heureFermeture.split(':');
      final openMinutes = int.parse(open[0]) * 60 + int.parse(open[1]);
      final closeMinutes = int.parse(close[0]) * 60 + int.parse(close[1]);
      return nowMinutes >= openMinutes && nowMinutes < closeMinutes;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final photoUrls = _displayableMediaUrls(garage.medias);
    final isOpen = _isOpenNow();
    final hasPhone2 = garage.telephone2.isNotEmpty && garage.telephone2 != 'none';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: colorScheme.surface,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined,
                        color: Colors.white, size: 18),
                    onPressed: () => Share.share(
                        '${garage.nom} — ${garage.ville}, ${garage.pays}'),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  garage.photo.isNotEmpty
                      ? Image.network(
                          garage.photo,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: colorScheme.surfaceContainerHighest),
                        )
                      : Container(color: colorScheme.surfaceContainerHighest),
                  // Scrim so the name stays readable over any photo.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                        stops: [0.5, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(garage.nom,
                            style: appStyle.H2(weight: 'bold', color: Colors.white)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text('${garage.ville}, ${garage.pays}',
                                style: appStyle.H6(color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Rating / distance / open-closed ───
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatChip(
                        icon: Icons.star_rounded,
                        iconColor: colorScheme.primary,
                        label: garage.rating > 0
                            ? '${garage.rating.toStringAsFixed(1)}/5'
                            : 'Pas encore noté',
                      ),
                      if (garage.distance > 0)
                        _StatChip(
                          icon: Icons.near_me_outlined,
                          label: '${garage.distance.toStringAsFixed(1)} km',
                        ),
                      if (isOpen != null)
                        _StatChip(
                          icon: Icons.circle,
                          iconColor: isOpen ? Colors.green : colorScheme.error,
                          iconSize: 10,
                          label: isOpen ? 'Ouvert' : 'Fermé',
                        ),
                    ],
                  ),
                ),

                // ─── Quick actions ───
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      if (garage.telephone1.isNotEmpty)
                        _ActionButton(
                          icon: Icons.call_outlined,
                          label: 'Appeler',
                          onTap: () => _launch('tel:${garage.telephone1}'),
                        ),
                      if (garage.email.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        _ActionButton(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          onTap: () => _launch('mailto:${garage.email}'),
                        ),
                      ],
                      if (garage.latitude != 0.0 || garage.longitude != 0.0) ...[
                        const SizedBox(width: 10),
                        _ActionButton(
                          icon: Icons.directions_outlined,
                          label: 'Itinéraire',
                          onTap: () => _launch(
                              'https://www.google.com/maps/search/?api=1&query=${garage.latitude},${garage.longitude}'),
                        ),
                      ],
                    ],
                  ),
                ),

                if (garage.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(garage.description, style: appStyle.H5()),
                  ),
                ],

                const SizedBox(height: 16),

                // ─── Info card ───
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.schedule_outlined,
                          label: 'Horaires',
                          value:
                              '${garage.heureOuverture} – ${garage.heureFermeture}',
                        ),
                        if (garage.telephone1.isNotEmpty)
                          _InfoRow(
                            icon: Icons.phone_outlined,
                            label: 'Téléphone',
                            value: garage.telephone1,
                            onTap: () => _launch('tel:${garage.telephone1}'),
                          ),
                        if (hasPhone2)
                          _InfoRow(
                            icon: Icons.phone_outlined,
                            label: 'Téléphone (2)',
                            value: garage.telephone2,
                            onTap: () => _launch('tel:${garage.telephone2}'),
                          ),
                        if (garage.email.isNotEmpty)
                          _InfoRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: garage.email,
                            onTap: () => _launch('mailto:${garage.email}'),
                            isLast: true,
                          ),
                      ],
                    ),
                  ),
                ),

                // ─── Photos ───
                if (photoUrls.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Photos', style: appStyle.H5(weight: 'bold')),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: photoUrls.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) => ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          photoUrls[index],
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 140,
                            height: 140,
                            color: colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final double? iconSize;
  const _StatChip(
      {required this.icon, required this.label, this.iconColor, this.iconSize});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize ?? 16, color: iconColor ?? colorScheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(label, style: AppStyle.of(context).H6()),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(height: 4),
              Text(label,
                  style: AppStyle.of(context).H6(color: colorScheme.primary, weight: 'bold')),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool isLast;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: isLast
          ? const BorderRadius.vertical(bottom: Radius.circular(16))
          : BorderRadius.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: appStyle.H6(color: colorScheme.onSurfaceVariant)),
                  Text(value, style: appStyle.H5(weight: 'bold')),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
