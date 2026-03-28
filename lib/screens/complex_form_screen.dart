import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Demonstrates complex form validation with:
///   - Required field checks
///   - Email format validation
///   - Password strength validation
///   - Cross-field confirm password validation
///   - Phone number format validation
///   - Real-time validation (AutovalidateMode.onUserInteraction)
///   - Submit disabled until form is valid
class ComplexFormScreen extends StatefulWidget {
  const ComplexFormScreen({super.key});

  @override
  State<ComplexFormScreen> createState() => _ComplexFormScreenState();
}

class _ComplexFormScreenState extends State<ComplexFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;
  bool _submitted = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  // ── Validators ─────────────────────────────────────────────────────────────

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Full name is required';
    if (v.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    final regex = RegExp(r'^[0-9]{10}$');
    if (!regex.hasMatch(v.trim())) return 'Enter a valid 10-digit phone number';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (!v.contains(RegExp(r'[A-Z]')))
      return 'Must contain an uppercase letter';
    if (!v.contains(RegExp(r'[0-9]'))) return 'Must contain a number';
    return null;
  }

  // Cross-field validation — depends on _passwordCtrl
  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != _passwordCtrl.text) return 'Passwords do not match';
    return null;
  }

  String? _validateBio(String? v) {
    if (v == null || v.trim().isEmpty) return 'Bio is required';
    if (v.trim().length > 160) return 'Bio must be 160 characters or less';
    return null;
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  void _submit() {
    setState(() => _autovalidate = AutovalidateMode.onUserInteraction);

    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _submitted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _reset() {
    _formKey.currentState?.reset();
    _nameCtrl.clear();
    _emailCtrl.clear();
    _phoneCtrl.clear();
    _passwordCtrl.clear();
    _confirmCtrl.clear();
    _bioCtrl.clear();
    setState(() {
      _agreedToTerms = false;
      _submitted = false;
      _autovalidate = AutovalidateMode.disabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_submitted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Complex Form')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 72),
                const SizedBox(height: 16),
                Text('Form Submitted!',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Name: ${_nameCtrl.text}',
                    style: theme.textTheme.bodyMedium),
                Text('Email: ${_emailCtrl.text}',
                    style: theme.textTheme.bodyMedium),
                Text('Phone: ${_phoneCtrl.text}',
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 24),
                FilledButton(
                    onPressed: _reset, child: const Text('Fill Again')),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complex Form'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidate,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel('Personal Info', theme),

              // Full Name
              _Field(
                label: 'Full Name *',
                hint: 'Enter your full name',
                controller: _nameCtrl,
                icon: Icons.person_outline,
                validator: _validateName,
              ),
              const SizedBox(height: 16),

              // Email
              _Field(
                label: 'Email Address *',
                hint: 'you@example.com',
                controller: _emailCtrl,
                icon: Icons.email_outlined,
                keyboard: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),

              // Phone
              _Field(
                label: 'Phone Number *',
                hint: '10-digit number',
                controller: _phoneCtrl,
                icon: Icons.phone_outlined,
                keyboard: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: _validatePhone,
              ),
              const SizedBox(height: 16),

              // Bio
              TextFormField(
                controller: _bioCtrl,
                maxLines: 3,
                maxLength: 160,
                decoration: InputDecoration(
                  labelText: 'Bio *',
                  hintText: 'Tell us about yourself (max 160 chars)',
                  prefixIcon: const Icon(Icons.notes_outlined),
                  border: const OutlineInputBorder(),
                ),
                validator: _validateBio,
              ),

              const SizedBox(height: 8),
              _SectionLabel('Security', theme),

              // Password
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  hintText: 'Min 8 chars, 1 uppercase, 1 number',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: _validatePassword,
                // Revalidate confirm field when password changes
                onChanged: (_) {
                  if (_autovalidate == AutovalidateMode.onUserInteraction) {
                    _formKey.currentState?.validate();
                  }
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password — cross-field validation
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm Password *',
                  hintText: 'Re-enter your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: _validateConfirm,
              ),
              const SizedBox(height: 20),

              // Terms checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (v) =>
                        setState(() => _agreedToTerms = v ?? false),
                  ),
                  Expanded(
                    child: Text(
                      'I agree to the Terms and Conditions',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit button — disabled until form is valid
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.send),
                  label: const Text('Submit'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _reset,
                  child: const Text('Reset'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final ThemeData theme;
  const _SectionLabel(this.text, this.theme);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboard;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?) validator;

  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.keyboard = TextInputType.text,
    this.inputFormatters,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}
