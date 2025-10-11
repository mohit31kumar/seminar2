import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/providers/app_state.dart';
// ignore: unused_import
import 'package:seminar_booking_app/models/seminar_hall.dart';

class FacilitiesScreen extends StatefulWidget {
  const FacilitiesScreen({super.key});

  @override
  State<FacilitiesScreen> createState() => _FacilitiesScreenState();
}

class _FacilitiesScreenState extends State<FacilitiesScreen> {
  String? _selectedHallId;

  IconData getIconForFacility(String facilityName) {
    if (facilityName.toLowerCase().contains('capacity')) return Icons.people_outline;
    if (facilityName.toLowerCase().contains('air conditioning')) return MdiIcons.fan;
    if (facilityName.toLowerCase().contains('projector')) return Icons.videocam_outlined;
    return Icons.check_box_outline_blank;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final halls = appState.halls;
    final theme = Theme.of(context);

    if (halls.isEmpty) {
      return const Center(child: Text("No facilities to display."));
    }

    // Ensure _selectedHallId is valid
    if (_selectedHallId == null || !halls.any((h) => h.id == _selectedHallId)) {
      _selectedHallId = halls.first.id;
    }

    final selectedHall = halls.firstWhere((h) => h.id == _selectedHallId);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text('Select a Hall', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedHallId,
          onChanged: (value) => setState(() => _selectedHallId = value!),
          items: halls.map((hall) => DropdownMenuItem(value: hall.id, child: Text(hall.name))).toList(),
          decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 16)),
        ),
        const SizedBox(height: 32),
        Text('Facilities in ${selectedHall.name}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.5),
          itemCount: selectedHall.facilities.length,
          itemBuilder: (context, index) {
            final facility = selectedHall.facilities[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(getIconForFacility(facility), size: 32, color: theme.primaryColor),
                    const SizedBox(height: 8),
                    Text(facility, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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