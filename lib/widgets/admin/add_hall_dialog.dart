import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/services/firestore_service.dart';

// A map of all available facilities.
// This is the single source of truth.
// Key: The name stored in Firestore. Value: The icon to display.
const Map<String, IconData> kAvailableFacilities = {
  'Projector': Icons.videocam_rounded,
  'Wi-Fi': Icons.wifi_rounded,
  'Air Conditioning': Icons.ac_unit_rounded,
  'Sound System': Icons.volume_up_rounded,
  'Microphone': Icons.mic_rounded,
  'Whiteboard': Icons.edit_note_rounded,
  'Computer': Icons.computer_rounded,
  'Wheelchair Access': Icons.accessible_rounded,
};

class AddHallDialog extends StatefulWidget {
  const AddHallDialog({super.key});

  @override
  State<AddHallDialog> createState() => _AddHallDialogState();
}

class _AddHallDialogState extends State<AddHallDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();

  // Use a Set to store the names of the selected facilities
  final Set<String> _selectedFacilities = {};

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  /// Handles the form submission
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final firestoreService = context.read<FirestoreService>();
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      try {
        await firestoreService.addHall(
          name: _nameController.text.trim(),
          capacity: int.parse(_capacityController.text.trim()),
          // Pass the Set converted to a List
          facilities: _selectedFacilities.toList(),
        );

        messenger.showSnackBar(
          SnackBar(
            content: Text('${_nameController.text.trim()} added successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        navigator.pop();
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error adding hall: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Hall'),
      content: _isLoading
          ? const SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Hall Name',
                        hintText: 'e.g., Main Auditorium',
                        icon: Icon(Icons.meeting_room_outlined),
                      ),
                      validator: (value) =>
                          value!.trim().isEmpty ? 'Please enter a name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _capacityController,
                      decoration: const InputDecoration(
                        labelText: 'Capacity',
                        hintText: 'e.g., 150',
                        icon: Icon(Icons.people_outline),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Please enter capacity';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Select Facilities',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Divider(height: 16),
                    
                    // --- This is the new Chip selection UI ---
                    Wrap(
                      spacing: 8.0, // Horizontal space between chips
                      runSpacing: 4.0, // Vertical space between lines
                      children: kAvailableFacilities.entries.map((entry) {
                        final facilityName = entry.key;
                        final facilityIcon = entry.value;
                        final isSelected =
                            _selectedFacilities.contains(facilityName);

                        return FilterChip(
                          label: Text(facilityName),
                          avatar: Icon(
                            facilityIcon,
                            size: 18,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedFacilities.add(facilityName);
                              } else {
                                _selectedFacilities.remove(facilityName);
                              }
                            });
                          },
                          selectedColor: Theme.of(context).primaryColor,
                          checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : null,
                          ),
                        );
                      }).toList(),
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
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Hall'),
        ),
      ],
    );
  }
}