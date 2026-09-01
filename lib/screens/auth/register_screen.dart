import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // DATE PICKER LOGIC

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1940),
      lastDate: now,
    );

    if (picked != null) {
      _dobController.text = AppFormatters.formatDate(picked);
    }
  }

  // REGISTER LOGIC

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.registerUserFields(
      fName: _firstNameController.text.trim(),
      lName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      dob: _dobController.text.trim().isEmpty
          ? null
          : _dobController.text.trim(),
      mobileNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void _goToLogin() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final double contentWidth = width >= 900
                ? 650
                : width >= 600
                ? 600
                : width;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),

                  SizedBox(
                    width: contentWidth,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: _buildRegisterCard(),
                    ),
                  ),

                  SizedBox(
                    width: contentWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildRegisterButton(),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // HEADER UI

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 40, bottom: 40),
      decoration: const BoxDecoration(
        gradient: AppColors.tealGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Register',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 6),

          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.white70,
              ),
              children: [
                const TextSpan(text: 'Already have an account? '),

                TextSpan(
                  text: 'Log In',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = _goToLogin,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // REGISTER CARD UI

  Widget _buildRegisterCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameFields(),

            const SizedBox(height: 18),

            _buildEmailField(),

            const SizedBox(height: 18),

            _buildDobField(),

            const SizedBox(height: 18),

            _buildPhoneField(),

            const SizedBox(height: 18),

            _buildPasswordField(),

            const SizedBox(height: 6),

            const Text(
              'Must be at least 8 characters with a mix of letters and numbers.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),

            _buildErrorMessage(),
          ],
        ),
      ),
    );
  }

  // NAME FIELDS UI

  Widget _buildNameFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 400) {
          return Column(
            children: [
              _LabeledField(
                label: 'First Name',
                controller: _firstNameController,
                hint: 'John',
                validator: (val) =>
                    AppValidators.validateRequired(val, 'First Name'),
              ),

              const SizedBox(height: 18),

              _LabeledField(
                label: 'Last Name',
                controller: _lastNameController,
                hint: 'Doe',
                validator: (val) =>
                    AppValidators.validateRequired(val, 'Last Name'),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _LabeledField(
                label: 'First Name',
                controller: _firstNameController,
                hint: 'John',
                validator: (val) =>
                    AppValidators.validateRequired(val, 'First Name'),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _LabeledField(
                label: 'Last Name',
                controller: _lastNameController,
                hint: 'Doe',
                validator: (val) =>
                    AppValidators.validateRequired(val, 'Last Name'),
              ),
            ),
          ],
        );
      },
    );
  }

  // EMAIL UI

  Widget _buildEmailField() {
    return _LabeledField(
      label: 'Email Address',
      controller: _emailController,
      hint: 'example@trackt.com',
      icon: Icons.mail_outline,
      keyboardType: TextInputType.emailAddress,
      validator: AppValidators.validateEmail,
    );
  }

  // DATE OF BIRTH UI

  Widget _buildDobField() {
    return _LabeledField(
      label: 'Date of Birth',
      controller: _dobController,
      hint: 'mm/dd/yyyy',
      icon: Icons.calendar_today_outlined,
      readOnly: true,
      onTap: _pickDate,
    );
  }

  // PHONE UI

  Widget _buildPhoneField() {
    return _LabeledField(
      label: 'Phone Number',
      controller: _phoneController,
      hint: '1234567890',
      keyboardType: TextInputType.phone,
      validator: AppValidators.validatePhone,
    );
  }

  // PASSWORD UI

  Widget _buildPasswordField() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return _LabeledField(
          label: 'Set Password',
          controller: _passwordController,
          hint: '••••••••',
          icon: Icons.lock_outline,
          obscureText: auth.obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              auth.obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: auth.toggleObscurePassword,
          ),
          validator: AppValidators.validatePassword,
        );
      },
    );
  }

  // ERROR MESSAGE UI

  Widget _buildErrorMessage() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.errorMessage == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline,
                size: 18,
                color: AppColors.danger,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  auth.errorMessage!,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.danger,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // REGISTER BUTTON UI

  Widget _buildRegisterButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: auth.isLoading ? null : _handleRegister,
            child: auth.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Text('Register'),
          ),
        );
      },
    );
  }
}

// REUSABLE LABELED FIELD UI

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    this.icon,
    this.suffixIcon,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.textSecondary, size: 20)
                : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
