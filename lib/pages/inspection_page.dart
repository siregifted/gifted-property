import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/inspection.dart';
import '../models/property.dart';
import '../repositories/inspection_repository.dart';
import '../validation/lead_validators.dart';

class InspectionPage extends StatefulWidget {
  final Property property;
  final Future<void> Function(Inspection)? onSubmit;

  const InspectionPage({super.key, required this.property, this.onSubmit});

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

  bool get _canSubmit =>
      !widget.property.isSample &&
      widget.property.id != null &&
      widget.property.id! > 0;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    if (_isSubmitting || !_canSubmit) return;

    final today = lagosCalendarDate(DateTime.now().toUtc());
    final latestDate = addOneCalendarYearClamped(today);
    final currentSelection = _inspectionDate;
    final initialDate =
        currentSelection != null &&
            isAllowedInspectionDate(currentSelection, DateTime.now().toUtc())
        ? currentSelection
        : today;
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: today,
      lastDate: latestDate,
      initialDate: initialDate,
    );

    if (selectedDate != null && mounted) {
      setState(() => _inspectionDate = selectedDate);
    }
  }

  Future<void> _selectTime() async {
    if (_isSubmitting || !_canSubmit) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _preferredTime ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Choose a preferred time in Abuja (WAT)',
    );

    if (selectedTime != null && mounted) {
      setState(() => _preferredTime = selectedTime);
    }
  }

  Future<void> _submitInspection() async {
    if (!_canSubmit || _isSubmitting || !_formKey.currentState!.validate()) {
      return;
    }

    final nowUtc = DateTime.now().toUtc();
    final inspectionDate = _inspectionDate;
    if (inspectionDate == null ||
        !isAllowedInspectionDate(inspectionDate, nowUtc)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Select a date from today through one year ahead (Abuja time).',
          ),
        ),
      );
      return;
    }
    final preferredTime = _preferredTime;
    if (preferredTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a preferred time.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final inspection = Inspection(
      propertyId: widget.property.id,
      propertyTitle: widget.property.title,
      propertyLocation: widget.property.location,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      inspectionDate: inspectionDate,
      preferredTime: formatInspectionTime(
        preferredTime.hour,
        preferredTime.minute,
      ),
      message: _messageController.text.trim(),
    );

    try {
      final submit = widget.onSubmit ?? _inspectionRepository.addInspection;
      await submit(inspection);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your inspection request has been submitted.'),
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_submissionError(error))));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _submissionError(Object error) {
    if (error is PostgrestException &&
        (error.code == '42501' || error.code == '23514')) {
      return 'This listing may no longer be accepting requests. Refresh the catalogue and try again.';
    }
    return 'We could not send your request. Check your connection and try again.';
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
                  if (!_canSubmit) ...[
                    const SizedBox(height: 16),
                    _requestUnavailableNotice(widget.property.isSample),
                  ],
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    maxLength: 120,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: validateLeadName,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    maxLength: 32,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: validateLeadPhone,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    maxLength: 254,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                    ),
                    validator: validateLeadEmail,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(4),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Inspection Date (Abuja time)',
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
                        labelText: 'Preferred Time (Abuja / WAT)',
                        helperText: 'Recorded in West Africa Time (UTC+1).',
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
                    maxLength: 4000,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      hintText: 'Add any additional information.',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    validator: validateLeadMessage,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting || !_canSubmit
                          ? null
                          : _submitInspection,
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

Widget _requestUnavailableNotice(bool isSample) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF6E5),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      isSample
          ? 'Demo listings cannot schedule inspections.'
          : 'This listing is not ready to accept inspection requests yet.',
      style: const TextStyle(color: Color(0xFF704E00)),
    ),
  );
}
