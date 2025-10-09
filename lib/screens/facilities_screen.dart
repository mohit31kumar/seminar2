import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../data/static_data.dart';

class FacilitiesScreen extends StatefulWidget {
  const FacilitiesScreen({super.key});

  @override
  State<FacilitiesScreen> createState() => _FacilitiesScreenState();
}

class _FacilitiesScreenState extends State<FacilitiesScreen> {
  String _selectedHall = seminarHalls.first;

  IconData getIconData(String iconName) {
    switch (iconName) {
      case 'Users': return Icons.people_outline;
      case 'Wind': return MdiIcons.fan;
      case 'Video': return Icons.videocam_outlined;
      case 'ShieldAlert': return Icons.shield_outlined;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final facilities = hallFacilities[_selectedHall] ?? [];
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text('Select a Hall', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedHall,
          onChanged: (value) => setState(() => _selectedHall = value!),
          items: seminarHalls.map((hall) => DropdownMenuItem(value: hall, child: Text(hall))).toList(),
          decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 16)),
        ),
        const SizedBox(height: 32),
        Text('Facilities in $_selectedHall', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.5),
          itemCount: facilities.length,
          itemBuilder: (context, index) {
            final facility = facilities[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(getIconData(facility['iconName'] as String), size: 32, color: theme.primaryColor),
                    const SizedBox(height: 8),
                    Text(facility['name'] as String, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    if (facility['description'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(facility['description'] as String, style: theme.textTheme.bodySmall),
                      ),
                  ],
                ),
              ),
            );
          },
        )
      ],
    );
  }
}