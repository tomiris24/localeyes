import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Which side of the marketplace the new account belongs to.
enum UserRole { traveller, guide }

/// Registration and profile setup.
///
/// Everything the form needs lives in this [StatefulWidget]:
///  * [_formKey] is the [GlobalKey] that validates all fields at once.
///  * One [TextEditingController] per field, so the values can be read on submit.
///  * [_acceptedTerms] and [_role] are the checkbox and the dropdown.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // The key that gives us access to the form state (validate / save / reset).
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _acceptedTerms = false;
  bool _showTermsError = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  UserRole _role = UserRole.traveller;

  // Errors appear while typing only after the first submit attempt, so the
  // form does not shout at the user before they had a chance to fill it in.
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    // Controllers hold resources, so every one of them has to be released.
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- validators

  String? _validateName(String? value) {
    final String name = (value ?? '').trim();
    if (name.isEmpty) {
      return 'Please enter your full name';
    }
    if (name.length < 2) {
      return 'Name is too short';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final String email = (value ?? '').trim();
    if (email.isEmpty) {
      return 'Please enter your email';
    }
    if (!email.contains('@')) {
      return 'Email must contain @';
    }
    if (!email.contains('.')) {
      return 'Email must contain a dot, for example name@narxoz.kz';
    }
    // The dot has to come after the @, otherwise "a.b@c" would pass.
    if (email.indexOf('.') < email.indexOf('@')) {
      return 'Enter a valid email, for example name@narxoz.kz';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final String password = value ?? '';
    if (password.isEmpty) {
      return 'Please enter a password';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    final String confirm = value ?? '';
    if (confirm.isEmpty) {
      return 'Please repeat the password';
    }
    if (confirm != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ---------------------------------------------------------------- actions

  void _toggleTerms(bool? checked) {
    setState(() {
      _acceptedTerms = checked ?? false;
      // Hide the warning as soon as the box is ticked.
      if (_acceptedTerms) {
        _showTermsError = false;
      }
    });
  }

  void _selectRole(UserRole? role) {
    if (role == null) {
      return;
    }
    setState(() => _role = role);
  }

  void _submit() {
    // Ask every field to validate itself. Returns false if any of them failed.
    final bool fieldsAreValid = _formKey.currentState!.validate();

    setState(() {
      _autovalidate = AutovalidateMode.onUserInteraction;
      _showTermsError = !_acceptedTerms;
    });

    if (!fieldsAreValid || !_acceptedTerms) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Please fix the errors above')),
        );
      return;
    }

    _printFormData();
    _showSuccessDialog();
  }

  /// Requirement of the lab: print the collected data in the terminal.
  void _printFormData() {
    debugPrint('--- New LocalEyes account ---');
    debugPrint('Full name: ${_nameController.text.trim()}');
    debugPrint('Email:     ${_emailController.text.trim()}');
    debugPrint('Password:  ${'*' * _passwordController.text.length}');
    debugPrint('Role:      ${_roleLabel(_role)}');
    debugPrint('Terms:     accepted');
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardAll),
          icon: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 44,
          ),
          title: const Text('Account created'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _SummaryRow(label: 'Name', value: _nameController.text.trim()),
              _SummaryRow(label: 'Email', value: _emailController.text.trim()),
              _SummaryRow(label: 'Role', value: _roleLabel(_role)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Done'),
            ),
          ],
        );
      },
    ).then((_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Welcome to LocalEyes, ${_nameController.text.trim()}!'),
          ),
        );
    });
  }

  String _roleLabel(UserRole role) {
    if (role == UserRole.guide) {
      return 'Guide';
    }
    return 'Traveller';
  }

  // ------------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create account'),
        titleSpacing: AppSpacing.lg,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidate,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: <Widget>[
                Text('Join LocalEyes', style: text.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'One account to book tours, or to take travellers out as a guide.',
                  style: text.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),

                // ----------------------------------------------- full name
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: _fieldDecoration(
                    label: 'Full name',
                    hint: 'Tomiris Suleimenova',
                    icon: Icons.person_outline_rounded,
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: AppSpacing.lg),

                // --------------------------------------------------- email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: _fieldDecoration(
                    label: 'Email',
                    hint: 'name@narxoz.kz',
                    icon: Icons.mail_outline_rounded,
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: AppSpacing.lg),

                // ------------------------------------------------ password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  decoration: _fieldDecoration(
                    label: 'Password',
                    hint: 'At least 6 characters',
                    icon: Icons.lock_outline_rounded,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.inkMuted,
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                  ),
                  validator: _validatePassword,
                  // Retype check has to react when the first password changes.
                  onChanged: (_) {
                    if (_autovalidate != AutovalidateMode.disabled) {
                      _formKey.currentState!.validate();
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // ----------------------------------------- confirm password
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  decoration: _fieldDecoration(
                    label: 'Confirm password',
                    hint: 'Repeat the password',
                    icon: Icons.lock_reset_rounded,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.inkMuted,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: _validateConfirm,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ---------------------------------------------------- role
                DropdownButtonFormField<UserRole>(
                  initialValue: _role,
                  // Without isExpanded the button is only as wide as its
                  // longest item, which overflows the row on a small phone.
                  isExpanded: true,
                  decoration: _fieldDecoration(
                    label: 'Role',
                    icon: Icons.badge_outlined,
                  ),
                  items: const <DropdownMenuItem<UserRole>>[
                    DropdownMenuItem<UserRole>(
                      value: UserRole.traveller,
                      child: Text(
                        'Traveller — book tours',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem<UserRole>(
                      value: UserRole.guide,
                      child: Text(
                        'Guide — lead tours',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  onChanged: _selectRole,
                ),
                const SizedBox(height: AppSpacing.lg),

                // ------------------------------------------------ checkbox
                _buildTermsCheckbox(context),
                const SizedBox(height: AppSpacing.xl),

                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Create account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.cardAll,
            border: Border.all(
              color: _showTermsError ? Colors.red.shade300 : AppColors.line,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Checkbox(
                value: _acceptedTerms,
                onChanged: _toggleTerms,
                activeColor: AppColors.brand,
              ),
              // Expanded keeps the long label inside the row on small phones.
              Expanded(
                child: GestureDetector(
                  onTap: () => _toggleTerms(!_acceptedTerms),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: Text(
                      'I accept the Terms and Conditions',
                      style: text.bodyLarge,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // The checkbox is not a form field, so its error is shown by hand,
        // styled like the errors Flutter draws under a TextFormField.
        if (_showTermsError)
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 6, 0, 0),
            child: Text(
              'You have to accept the terms to register',
              style: text.bodySmall?.copyWith(color: Colors.red.shade700),
            ),
          ),
      ],
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.inkMuted),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: const OutlineInputBorder(
        borderRadius: AppRadius.cardAll,
        borderSide: BorderSide(color: AppColors.line),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: AppRadius.cardAll,
        borderSide: BorderSide(color: AppColors.line),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: AppRadius.cardAll,
        borderSide: BorderSide(color: AppColors.brand, width: 1.6),
      ),
    );
  }
}

/// One "Label — value" line inside the success dialog.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 62,
            child: Text(label, style: text.bodySmall),
          ),
          Expanded(child: Text(value, style: text.titleSmall)),
        ],
      ),
    );
  }
}
