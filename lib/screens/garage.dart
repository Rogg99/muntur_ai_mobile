import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/garages/domain/entities/garage_entity.dart';
import 'package:munturai/features/garages/presentation/providers/garage_provider.dart';
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
// GARAGE DETAIL SCREEN (migrated from legacy garage.dart)
// ──────────────────────────────────────────────────────────────────────────────

class GarageDetails extends StatelessWidget {
  final GarageEntity garage;
  const GarageDetails({super.key, required this.garage});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    List<dynamic> mediasList = [];
    try {
      mediasList = jsonDecode(garage.medias) as List;
    } catch (_) {}

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Infos Garage', style: appStyle.H3(weight: 'bold')),
        backgroundColor: colorScheme.surface,
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // ─── Cover photo ───
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              image: garage.photo.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(garage.photo),
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: AssetImage('assets/images/avatar.jpg'),
                      fit: BoxFit.cover),
            ),
          ),

          // ─── Nom + Description ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(garage.nom,
                    style: appStyle.H3(weight: 'bold'),
                    textAlign: TextAlign.center),
                if (garage.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(garage.description, style: appStyle.H5()),
                ],
              ],
            ),
          ),
          const Divider(indent: 16, endIndent: 16),

          // ─── Location ───
          _InfoRow(
            icon: Icons.location_on,
            label: 'Localisation',
            value: '${garage.ville}, ${garage.pays}',
          ),
          const Divider(indent: 16, endIndent: 16),

          // ─── Email ───
          _InfoRow(
            icon: Icons.email,
            label: 'Email',
            value: garage.email,
            action: TextButton(
              onPressed: () => _launch('mailto:${garage.email}'),
              child: const Text('Envoyer'),
            ),
          ),
          const Divider(indent: 16, endIndent: 16),

          // ─── Tel 1 ───
          if (garage.telephone1.isNotEmpty)
            _InfoRow(
              icon: Icons.phone,
              label: 'Téléphone 1',
              value: garage.telephone1,
              action: TextButton(
                onPressed: () => _launch('tel:${garage.telephone1}'),
                child: const Text('Appel'),
              ),
            ),
          const Divider(indent: 16, endIndent: 16),

          // ─── Tel 2 ───
          if (garage.telephone2.isNotEmpty && garage.telephone2 != 'none')
            _InfoRow(
              icon: Icons.phone,
              label: 'Téléphone 2',
              value: garage.telephone2,
              action: TextButton(
                onPressed: () => _launch('tel:${garage.telephone2}'),
                child: const Text('Appel'),
              ),
            ),
          const Divider(indent: 16, endIndent: 16),

          // ─── Horaires ───
          _InfoRow(
            icon: Icons.schedule,
            label: 'Horaires',
            value:
                'Lun–Sam  ${garage.heureOuverture} – ${garage.heureFermeture}',
          ),
          const Divider(indent: 16, endIndent: 16),

          // ─── Rating ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.stars),
                const SizedBox(width: 8),
                Text('Rating : ', style: appStyle.H6()),
                for (var _ in List.generate(garage.rating.floor(), (_) => 0))
                  Icon(Icons.star, color: colorScheme.primary, size: 16),
                Text(' ${garage.rating}/5', style: appStyle.H5(weight: 'bold')),
              ],
            ),
          ),
          const Divider(indent: 16, endIndent: 16),

          // ─── Photos ───
          if (mediasList.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Photos', style: appStyle.H5(weight: 'bold')),
            ),
            ...mediasList.map((img) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(img.toString(),
                        height: 180, fit: BoxFit.cover),
                  ),
                )),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? action;
  const _InfoRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.action});

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text('$label : ', style: appStyle.H6()),
          Flexible(child: Text(value, style: appStyle.H5(weight: 'bold'))),
          if (action != null) ...[const Spacer(), action!],
        ],
      ),
    );
  }
}
