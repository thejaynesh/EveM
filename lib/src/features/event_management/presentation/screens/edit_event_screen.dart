import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'dart:developer' as developer;

import '../../../../shared/models/event.dart';
import '../../data/event_service.dart';

class EditEventScreen extends StatefulWidget {
  final String eventId;

  const EditEventScreen({super.key, required this.eventId});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late final EventService _eventService;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  DateTime? _startDate;
  DateTime? _endDate;
  File? _imageFile;
  String? _networkImageUrl;

  bool _isLoading = true;
  bool _isSaving = false;
  Event? _event;

  @override
  void initState() {
    super.initState();
    _eventService = Provider.of<EventService>(context, listen: false);
    _initializeControllers();
    _fetchEventDetails();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
  }

  Future<void> _fetchEventDetails() async {
    try {
      final event = await _eventService.getEventById(widget.eventId);
      if (event != null && mounted) {
        setState(() {
          _event = event;
          _nameController.text = event.name;
          _descriptionController.text = event.description;
          _locationController.text = event.location;
          _startDate = event.startDate;
          _endDate = event.endDate;
          if (_startDate != null) {
            _startDateController.text = DateFormat.yMd().add_jm().format(_startDate!);
          }
          if (_endDate != null) {
            _endDateController.text = DateFormat.yMd().add_jm().format(_endDate!);
          }
          _networkImageUrl = event.imageUrl;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event not found.')),
        );
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      developer.log('Error fetching event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load event details: $e')),
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final fileName = path.basename(image.path);
      final destination = 'event_images/$fileName';
      final ref = firebase_storage.FirebaseStorage.instance.ref(destination);
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      developer.log('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? (_startDate ?? DateTime.now()) : (_endDate ?? _startDate ?? DateTime.now());
    final firstDate = DateTime(2000);
    final lastDate = DateTime(2101);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );
      if (pickedTime != null) {
        final fullDateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
        setState(() {
          if (isStartDate) {
            _startDate = fullDateTime;
            _startDateController.text = DateFormat.yMd().add_jm().format(_startDate!);
            if (_endDate != null && _endDate!.isBefore(_startDate!)) {
              _endDate = null;
              _endDateController.text = '';
            }
          } else {
            _endDate = fullDateTime;
            _endDateController.text = DateFormat.yMd().add_jm().format(_endDate!);
          }
        });
      }
    }
  }

  Future<void> _updateEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      String? imageUrl = _networkImageUrl;

      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!);
      }

      if (imageUrl == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image. Please try again.')),
        );
        setState(() => _isSaving = false);
        return;
      }

      final updatedEvent = Event(
        id: widget.eventId,
        name: _nameController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        startDate: _startDate!,
        endDate: _endDate!,
        imageUrl: imageUrl,
      );

      try {
        await _eventService.updateEvent(updatedEvent);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event updated successfully!')),
        );
        context.go('/manager/event-details/${widget.eventId}');
      } catch (e) {
        developer.log('Error updating event: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update event: $e')),
        );
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _event == null
              ? const Center(child: Text('Event could not be loaded.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Preview and Picker
                        Center(
                          child: Column(
                            children: [
                              Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: _imageFile != null
                                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                                    : _networkImageUrl != null
                                        ? Image.network(_networkImageUrl!, fit: BoxFit.cover)
                                        : const Center(child: Text('No Image Selected')),
                              ),
                              const SizedBox(height: 10),
                              TextButton.icon(
                                icon: const Icon(Icons.image),
                                label: const Text('Change Image'),
                                onPressed: _pickImage,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Form Fields
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Event Name'),
                          validator: (value) => value!.isEmpty ? 'Please enter event name' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(labelText: 'Description'),
                          maxLines: 3,
                          validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(labelText: 'Location'),
                          validator: (value) => value!.isEmpty ? 'Please enter a location' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _startDateController,
                          decoration: const InputDecoration(labelText: 'Start Date & Time'),
                          readOnly: true,
                          onTap: () => _selectDate(context, true),
                          validator: (value) => value!.isEmpty ? 'Please select a start date' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _endDateController,
                          decoration: const InputDecoration(labelText: 'End Date & Time'),
                          readOnly: true,
                          onTap: () => _selectDate(context, false),
                           validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an end date';
                            }
                            if (_startDate != null && _endDate != null && _endDate!.isBefore(_startDate!)) {
                              return 'End date must be after start date';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        // Save Button
                        if (_isSaving)
                          const Center(child: CircularProgressIndicator())
                        else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _updateEvent,
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                              child: const Text('Save Changes'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
