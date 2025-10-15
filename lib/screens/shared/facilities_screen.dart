import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/providers/app_state.dart';


class FacilitiesScreen extends StatefulWidget {
  const FacilitiesScreen({super.key});

  @override
  State<FacilitiesScreen> createState() => _FacilitiesScreenState();
}

class _FacilitiesScreenState extends State<FacilitiesScreen> {
  String? _selectedHallId;

  IconData getIconForFacility(String facilityName) {
    final lower = facilityName.toLowerCase();
    if (lower.contains('capacity')) return Icons.people_outline;
    if (lower.contains('air conditioning')) return MdiIcons.fan;
    if (lower.contains('projector')) return Icons.videocam_outlined;
    if (lower.contains('podium') || lower.contains('microphone')) return Icons.mic_none_outlined;
    if (lower.contains('conferencing')) return Icons.video_call_outlined;
    return Icons.check_box_outline_blank;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final halls = appState.halls;
    final theme = Theme.of(context);

    if (halls.isEmpty && !appState.isLoading) {
      return const Center(child: Text("No facilities to display."));
    }
    if (halls.isEmpty && appState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_selectedHallId == null || !halls.any((h) => h.id == _selectedHallId)) {
      _selectedHallId = halls.first.id;
    }

    final selectedHall = halls.firstWhere((h) => h.id == _selectedHallId);

    return Scaffold(
      appBar: AppBar(title: const Text('Our Facilities')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DropdownButtonFormField<String>(
            value: _selectedHallId,
            onChanged: (value) => setState(() => _selectedHallId = value!),
            items: halls.map((hall) => DropdownMenuItem(value: hall.id, child: Text(hall.name))).toList(),
            decoration: const InputDecoration(
              labelText: 'Select a Hall',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Amenities in ${selectedHall.name}',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.6,
            ),
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
                      Icon(getIconForFacility(facility), size: 32, color: theme.colorScheme.primary),
                      const Spacer(),
                      Text(facility, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}