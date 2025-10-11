import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/services/firestore_service.dart';

/// A dialog widget for administrators to add a new seminar hall.
class AddHallDialog extends StatefulWidget {
  const AddHallDialog({super.key});

  @override
  State<AddHallDialog> createState() => _AddHallDialogState();
}

class _AddHallDialogState extends State<AddHallDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _facilitiesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _facilitiesController.dispose();
    super.dispose();
  }

  /// Validates the form and calls the Firestore service to add the new hall.
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final firestoreService = context.read<FirestoreService>();
      
      // Convert comma-separated string of facilities into a clean list
      final facilitiesList = _facilitiesController.text
          .split(',')
          .map((facility) => facility.trim())
          .where((facility) => facility.isNotEmpty)
          .toList();

      try {
        await firestoreService.addHall(
          name: _nameController.text.trim(),
          capacity: int.parse(_capacityController.text.trim()),
          facilities: facilitiesList,
        );

        if (mounted) {
          Navigator.of(context).pop(); // Close the dialog on success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('New hall added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding hall: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Seminar Hall'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Hall Name'),
                validator: (value) => value!.trim().isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: 'Capacity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Please enter a capacity';
                  if (int.tryParse(value.trim()) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _facilitiesController,
                decoration: const InputDecoration(
                  labelText: 'Facilities',
                  hintText: 'e.g., Projector, AC, Mic',
                  helperText: 'Separate facilities with a comma (,)',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
            : const Text('Add Hall'),
        ),
      ],
    );
  }
}