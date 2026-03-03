import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/garages/domain/entities/garage_entity.dart';
import 'package:munturai/screens/garage.dart';

/// Map marker label widget shown above a garage pin on flutter_map
class WidgetMarker extends StatelessWidget {
  final GarageEntity garage;
  final bool selected;

  const WidgetMarker({
    super.key,
    required this.garage,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final color = selected ? Colors.blue : Colors.red;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GarageDetails(garage: garage)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              garage.nom,
              style: appStyle.H5(weight: 'Bold', color: color),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.location_on, size: 36, color: color),
          ),
        ],
      ),
    );
  }
}
