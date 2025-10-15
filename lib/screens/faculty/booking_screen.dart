import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/providers/app_state.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch for changes in the AppState to get the latest list of halls
    final appState = context.watch<AppState>();
    
    // Filter the halls to show only those that are currently available for booking
    final availableHalls = appState.halls.where((hall) => hall.isAvailable).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 1: Select a Hall'),
        centerTitle: false,
      ),
      body: availableHalls.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "There are currently no seminar halls available for booking. Please check back later.",
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: availableHalls.length,
              itemBuilder: (context, index) {
                final hall = availableHalls[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    title: Text(hall.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Capacity: ${hall.capacity}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to the next step (availability checker) and
                      // pass the full SeminarHall object as an 'extra' parameter.
                      context.go('/booking/availability', extra: hall);
                    },
                  ),
                );
              },
            ),
    );
  }
}