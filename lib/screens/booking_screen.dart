import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
// ignore: unused_import
import 'package:seminar_booking_app/models/seminar_hall.dart';
import 'package:seminar_booking_app/providers/app_state.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final halls = context.watch<AppState>().halls;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text('1. Select a Seminar Hall', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        if (halls.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("No seminar halls available."),
          ))
        else
          ...halls.map((hall) => Card(
              child: ListTile(
                title: Text(hall.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () { 
                  // Navigate to the next step (availability checker) and pass the full SeminarHall object as an 'extra' parameter.
                  context.go('/booking/availability', extra: hall);
                },
              ),
            )),
      ],
    );
  }
}