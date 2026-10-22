import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/enquiry.dart';
import '../models/property.dart';
import '../repositories/enquiry_repository.dart';
import '../validation/lead_validators.dart';

class EnquiryPage extends StatefulWidget {
  final Property property;
  final Future<void> Function(Enquiry)? onSubmit;

  const EnquiryPage({super.key, required this.property, this.onSubmit});

  @override
  State<EnquiryPage> createState() => _EnquiryPageState();
}

class _EnquiryPageState extends State<EnquiryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final EnquiryRepository _enquiryRepository = EnquiryRepository.instance;
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

  Future<void> _submitEnquiry() async {
    if (!_canSubmit || _isSubmitting || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    final enquiry = Enquiry(
      propertyId: widget.property.id,
      propertyTitle: widget.property.title,
      propertyLocation: widget.property.location,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      message: _messageController.text.trim(),
    );

    try {
      final submit = widget.onSubmit ?? _enquiryRepository.addEnquiry;
      await submit(enquiry);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your enquiry has been submitted.')),
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
      return 'This listing may no longer be accepting enquiries. Refresh the catalogue and try again.';
    }
    return 'We could not send your enquiry. Check your connection and try again.';
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1F33),
        foregroundColor: Colors.white,
        title: const Text(
          'Contact Agent',
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
                    'Make an Enquiry',
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
                  TextFormField(
                    controller: _messageController,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 4,
                    maxLines: 6,
                    maxLength: 4000,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      hintText: 'Tell us how we can help you.',
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
                          : _submitEnquiry,
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
                              'Submit Enquiry',
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
          ? 'Demo listings cannot send enquiries.'
          : 'This listing is not ready to accept enquiries yet.',
      style: const TextStyle(color: Color(0xFF704E00)),
    ),
  );
}
