import 'package:flutter/material.dart';
import '../data/static_data.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text('1. Select a Seminar Hall', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        ...seminarHalls.map((hall) => Card(
              child: ListTile(
                title: Text(hall),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to Availability Checker for this hall
                },
              ),
            )),
      ],
    );
  }
}