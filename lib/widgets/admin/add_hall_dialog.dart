import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/services/firestore_service.dart';

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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final firestoreService = context.read<FirestoreService>();

      final facilitiesList = _facilitiesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
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
            SnackBar(
              content: Text('Error adding hall: $e'),
              backgroundColor: Colors.red,
            ),
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
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Hall Name'),
                validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: 'Capacity'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Capacity is required';
                  if (int.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _facilitiesController,
                decoration: const InputDecoration(
                  labelText: 'Facilities',
                  hintText: 'e.g., Projector, AC, Wi-Fi',
                  helperText: 'Separate facilities with a comma',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Add Hall'),
        ),
      ],
    );
  }
}
