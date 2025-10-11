import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/providers/app_state.dart';
import 'package:seminar_booking_app/services/firestore_service.dart';
import 'package:seminar_booking_app/widgets/admin/add_hall_dialog.dart';

class HallManagementScreen extends StatelessWidget {
  const HallManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    // Use context.read inside callbacks or when not listening for changes
    final firestoreService = context.read<FirestoreService>();

    // Security check
    if (appState.currentUser?.role != 'admin') {
      return const Scaffold(
        body: Center(child: Text('Access Denied.')),
      );
    }

    final halls = appState.halls;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Halls & Facilities'),
      ),
      body: halls.isEmpty
          ? const Center(child: Text('No halls found in the database.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: halls.length,
              itemBuilder: (context, index) {
                final hall = halls[index];
                return Card(
                  child: SwitchListTile(
                    title: Text(hall.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      hall.isAvailable ? 'Booking Active' : 'Booking Paused',
                      style: TextStyle(
                        color: hall.isAvailable ? Colors.green.shade600 : Colors.red.shade600,
                      ),
                    ),
                    value: hall.isAvailable,
                    onChanged: (bool value) {
                      // Call the Firestore service to update the hall's status
                      firestoreService.updateHallAvailability(hall.id, value);
                    },
                    secondary: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit Hall Details',
                      onPressed: () {
                        // TODO: Implement a dialog or screen for the admin to edit hall details
                        // such as name, capacity, and the facilities list.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit functionality is not yet implemented.')),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            // barrierDismissible is false to prevent closing while loading
            barrierDismissible: false, 
            builder: (BuildContext context) {
              return const AddHallDialog();
            },
          );
        },
        tooltip: 'Add New Hall',
        child: const Icon(Icons.add),
      ),
    );
  }
}