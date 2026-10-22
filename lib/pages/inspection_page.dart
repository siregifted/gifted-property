import 'package:flutter/material.dart';

import '../models/inspection.dart';
import '../models/property.dart';
import '../repositories/inspection_repository.dart';

class InspectionPage extends StatefulWidget {
  final Property property;

  const InspectionPage({super.key, required this.property});

  @override
  State<InspectionPage> createState() => _InspectionPageState();
}

class _InspectionPageState extends State<InspectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final InspectionRepository _inspectionRepository =
      InspectionRepository.instance;

  DateTime? _inspectionDate;
  TimeOfDay? _preferredTime;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    if (_isSubmitting) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: today,
      lastDate: DateTime(now.year + 1, now.month, now.day),
      initialDate: _inspectionDate ?? today,
    );

    if (selectedDate != null && mounted) {
      setState(() => _inspectionDate = selectedDate);
    }
  }

  Future<void> _selectTime() async {
    if (_isSubmitting) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _preferredTime ?? TimeOfDay.now(),
    );

    if (selectedTime != null && mounted) {
      setState(() => _preferredTime = selectedTime);
    }
  }

  Future<void> _submitInspection() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) {
      return;
    }

    if (_inspectionDate == null || _preferredTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an inspection date and preferred time.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _inspectionRepository.addInspection(
        Inspection(
          propertyId: widget.property.id,
          propertyTitle: widget.property.title,
          propertyLocation: widget.property.location,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          inspectionDate: _inspectionDate!,
          preferredTime: _preferredTime!.format(context),
          message: _messageController.text.trim(),
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your inspection request has been submitted.'),
        ),
      );
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'We could not send your request. Check your connection and try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $fieldName.';
    }
    if (fieldName == 'full name' && value.trim().length < 2) {
      return 'Please enter your full name.';
    }
    if (fieldName == 'full name' && value.trim().length > 120) {
      return 'Please keep your name under 120 characters.';
    }
    if (fieldName == 'message' && value.trim().length > 4000) {
      return 'Please keep your message under 4000 characters.';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (phone.length > 32 || digits.length < 7 || digits.length > 20) {
      return 'Please enter a valid phone number.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email.';
    }
    if (value.trim().length > 254 ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'Please enter a valid email.';
    }
    return null;
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1F33),
        foregroundColor: Colors.white,
        title: const Text(
          'Schedule Inspection',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 20 : 40,
          vertical: compact ? 24 : 40,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule an Inspection',
                    style: TextStyle(
                      fontSize: compact ? 28 : 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0B1F33),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.property.title,
                    style: const TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.property.location,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => _requiredField(value, 'full name'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(4),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Inspection Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        _inspectionDate == null
                            ? 'Select a date'
                            : _formatDate(_inspectionDate!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectTime,
                    borderRadius: BorderRadius.circular(4),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Preferred Time',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time_outlined),
                      ),
                      child: Text(
                        _preferredTime == null
                            ? 'Select a time'
                            : _preferredTime!.format(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _messageController,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 4,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      hintText: 'Add any additional information.',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => _requiredField(value, 'message'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitInspection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B1F33),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Request Inspection',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
