import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/account.dart';
import '../state/auth_controller.dart';

/// Which form the screen is showing.
enum AuthMode { signIn, register }

/// The door into LocalEyes: sign in, or create the account.
///
/// It is the first screen of the app when nobody is signed in, and the screen
/// the traveller lands on again after signing out. The two forms share one
/// [Form] and one set of validators — only the extra sign-up fields (name,
/// confirm, role, terms) come and go, so there is one place where a field's
/// rule is written.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialMode});

  /// Defaults to "Sign in" on a device where somebody has registered before,
  /// and to the sign-up form on a fresh install.
  final AuthMode? initialMode;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  late AuthMode _mode =
      widget.initialMode ??
      (AuthController.instance.hasAccountOnDevice
          ? AuthMode.signIn
          : AuthMode.register);

  bool _acceptedTerms = false;
  bool _showTermsError = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  UserRole _role = UserRole.traveller;

  // Errors appear while typing only after the first submit attempt, so the
  // form does not shout at the user before they had a chance to fill it in.
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  bool get _isRegister => _mode == AuthMode.register;

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
    if (_isRegister && password.length < 6) {
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

  void _switchTo(AuthMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _autovalidate = AutovalidateMode.disabled;
      _showTermsError = false;
      _confirmController.clear();
    });
    context.read<AuthController>().clearError();
  }

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

  Future<void> _submit() async {
    // Ask every field to validate itself. Returns false if any of them failed.
    final bool fieldsAreValid = _formKey.currentState!.validate();

    setState(() {
      _autovalidate = AutovalidateMode.onUserInteraction;
      _showTermsError = _isRegister && !_acceptedTerms;
    });

    if (!fieldsAreValid || (_isRegister && !_acceptedTerms)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Please fix the errors above')),
        );
      return;
    }

    final AuthController auth = context.read<AuthController>();
    final String email = _emailController.text.trim();

    final bool ok = _isRegister
        ? await auth.register(
            name: _nameController.text.trim(),
            email: email,
            password: _passwordController.text,
            role: _role,
          )
        : await auth.signIn(email: email, password: _passwordController.text);

    if (!mounted || ok) return;

    // The one failure worth more than a red line: the account is already
    // there, so there is nothing to create — show them the sign-in form with
    // their email already in it.
    if (auth.errorCode == 'email_taken') {
      setState(() {
        _mode = AuthMode.signIn;
        _autovalidate = AutovalidateMode.disabled;
        _passwordController.clear();
        _confirmController.clear();
      });
    }
  }

  // ------------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final AuthController auth = context.watch<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidate,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                children: <Widget>[
                  Text('LocalEyes', style: text.headlineSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _isRegister
                        ? 'One account to book tours, or to take travellers '
                              'out as a guide.'
                        : 'Welcome back. Sign in to pick up where you left '
                              'off.',
                    style: text.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  _buildModeSwitch(),
                  const SizedBox(height: AppSpacing.lg),

                  if (auth.error != null) ...<Widget>[
                    _ServerMessage(message: auth.error!),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // ----------------------------------------------- full name
                  if (_isRegister) ...<Widget>[
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
                  ],

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
                    textInputAction: _isRegister
                        ? TextInputAction.next
                        : TextInputAction.done,
                    decoration: _fieldDecoration(
                      label: 'Password',
                      hint: _isRegister ? 'At least 6 characters' : null,
                      icon: Icons.lock_outline_rounded,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: context.palette.inkMuted,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: _validatePassword,
                    // Retype check has to react when the first password
                    // changes.
                    onChanged: (_) {
                      if (_autovalidate != AutovalidateMode.disabled) {
                        _formKey.currentState!.validate();
                      }
                    },
                    onFieldSubmitted: _isRegister ? null : (_) => _submit(),
                  ),

                  // ----------------------------------------- confirm password
                  if (_isRegister) ...<Widget>[
                    const SizedBox(height: AppSpacing.lg),
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
                            color: context.palette.inkMuted,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
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
                  ],
                  const SizedBox(height: AppSpacing.xl),

                  ElevatedButton(
                    onPressed: auth.isBusy ? null : _submit,
                    child: auth.isBusy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isRegister ? 'Create account' : 'Sign in'),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextButton(
                    onPressed: () => _switchTo(
                      _isRegister ? AuthMode.signIn : AuthMode.register,
                    ),
                    child: Text(
                      _isRegister
                          ? 'Already have an account? Sign in'
                          : 'New to LocalEyes? Create an account',
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

  /// The two words at the top of the form. A segmented control, because the
  /// choice is between two things and both have to stay visible.
  Widget _buildModeSwitch() {
    return SegmentedButton<AuthMode>(
      segments: const <ButtonSegment<AuthMode>>[
        ButtonSegment<AuthMode>(value: AuthMode.signIn, label: Text('Sign in')),
        ButtonSegment<AuthMode>(
          value: AuthMode.register,
          label: Text('Create account'),
        ),
      ],
      selected: <AuthMode>{_mode},
      showSelectedIcon: false,
      onSelectionChanged: (Set<AuthMode> selection) =>
          _switchTo(selection.first),
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
            color: context.palette.surfaceHigh,
            borderRadius: AppRadius.cardAll,
            border: Border.all(
              color: _showTermsError
                  ? Colors.red.shade300
                  : context.palette.line,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Checkbox(
                value: _acceptedTerms,
                onChanged: _toggleTerms,
                activeColor: context.palette.brand,
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
      prefixIcon: Icon(icon, color: context.palette.inkMuted),
      suffixIcon: suffix,
      filled: true,
      fillColor: context.palette.surfaceHigh,
      border: OutlineInputBorder(
        borderRadius: AppRadius.cardAll,
        borderSide: BorderSide(color: context.palette.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.cardAll,
        borderSide: BorderSide(color: context.palette.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.cardAll,
        borderSide: BorderSide(color: context.palette.brand, width: 1.6),
      ),
    );
  }
}

/// What the server said went wrong — a wrong password, an email already
/// taken — above the fields it is about.
class _ServerMessage extends StatelessWidget {
  const _ServerMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red.shade700,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
