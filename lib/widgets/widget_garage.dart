import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/garages/domain/entities/garage_entity.dart';
import 'package:munturai/screens/garage.dart';

/// Compact garage list tile widget (used on HomeScreen garage section)
class WidgetGarage extends StatelessWidget {
  final GarageEntity garage;

  const WidgetGarage({super.key, required this.garage});

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GarageDetails(garage: garage),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        width: double.infinity,
        child: Row(
          children: [
            // ─── Thumbnail ───
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: garage.photo.isNotEmpty
                  ? Image.network(
                      garage.photo,
                      height: 50,
                      width: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallback(),
                    )
                  : _fallback(),
            ),

            // ─── Info ───
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      garage.nom,
                      style: appStyle.H4(weight: 'bold'),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      garage.description,
                      style: appStyle.H5(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Note : ${garage.rating}/5',
                      style: appStyle.H6(color: Colors.grey),
                    ),
                    const Divider(),
                  ],
                ),
              ),
            ),

            // ─── Distance ───
            Text(
              garage.distance > 1
                  ? '${garage.distance.toStringAsFixed(1)} km'
                  : '${(garage.distance * 1000).floor()} m',
              style: appStyle.H6(weight: 'bold'),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() => Container(
        height: 50,
        width: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade200,
        ),
        child: const Icon(Icons.garage_outlined),
      );
}
