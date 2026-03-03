import 'package:flutter/material.dart';
import '../../../data/models/reminder_model.dart';
import '../../../data/repositories/reminder_repository.dart';

/// Add/Edit Reminder Modal - Bottom sheet for creating/editing reminders
/// Like a modal dialog in React with form state
class AddEditReminderModal extends StatefulWidget {
  final int userId;
  final ReminderModel? reminder; // null = add mode, not null = edit mode

  const AddEditReminderModal({super.key, required this.userId, this.reminder});

  @override
  State<AddEditReminderModal> createState() => _AddEditReminderModalState();
}

class _AddEditReminderModalState extends State<AddEditReminderModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _reminderRepository = ReminderRepository();

  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // If editing, populate fields
    if (widget.reminder != null) {
      _titleController.text = widget.reminder!.title;
      _descriptionController.text = widget.reminder!.description ?? '';
      _selectedTime = TimeOfDay.fromDateTime(widget.reminder!.time);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Pick time for reminder
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  /// Save reminder (create or update)
  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Combine date and time
      final now = DateTime.now();
      final reminderTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      if (widget.reminder == null) {
        // Create new reminder
        final newReminder = ReminderModel(
          userId: widget.userId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          time: reminderTime,
          createdAt: DateTime.now(),
        );

        await _reminderRepository.createReminder(newReminder);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder created successfully!')),
        );
      } else {
        // Update existing reminder
        final updatedReminder = widget.reminder!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          time: reminderTime,
        );

        await _reminderRepository.updateReminder(updatedReminder);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder updated successfully!')),
        );
      }

      // Close modal and signal success
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving reminder: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.reminder != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Reminder' : 'New Reminder',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),

              // Time picker
              InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Time',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime.format(context),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveReminder,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isEditing ? 'Update Reminder' : 'Create Reminder',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
