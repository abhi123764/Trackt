import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  void _goToRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
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

            // Responsive maximum width for the login form.
            final double contentWidth = width >= 900
                ? 500
                : width >= 600
                ? 480
                : width;

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),

                  Transform.translate(
                    offset: const Offset(0, -32),
                    child: SizedBox(
                      width: contentWidth,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildLoginCard(),
                      ),
                    ),
                  ),
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
      padding: const EdgeInsets.only(top: 48, bottom: 56),
      decoration: const BoxDecoration(
        gradient: AppColors.tealGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: const Column(
        children: [
          Text(
            'Trackt',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Text(
            'Sign in to your Account',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

   
  // LOGIN CARD UI
   

  Widget _buildLoginCard() {
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
            _buildEmailField(),

            const SizedBox(height: 20),

            _buildPasswordField(),

            _buildErrorMessage(),

            const SizedBox(height: 28),

            _buildLoginButton(),

            const SizedBox(height: 24),

            _buildRegisterLink(),
          ],
        ),
      ),
    );
  }

   
  // EMAIL FIELD UI
   

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('EMAIL', style: AppTextStyles.label),

        const SizedBox(height: 8),

        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            hintText: 'Enter your email',
            prefixIcon: Icon(
              Icons.mail_outline,
              color: AppColors.textSecondary,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email is required';
            }

            if (!value.contains('@')) {
              return 'Enter a valid email';
            }

            return null;
          },
        ),
      ],
    );
  }

   
  // PASSWORD FIELD UI
   

  Widget _buildPasswordField() {
    final auth = context.watch<AuthProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PASSWORD', style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) {
            if (!auth.isLoading) {
              _handleLogin();
            }
          },
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.textSecondary,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            return null;
          },
        ),
      ],
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

   
  // LOGIN BUTTON UI
   

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: auth.isLoading ? null : _handleLogin,
            child: auth.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Log In'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
          ),
        );
      },
    );
  }

   
  // REGISTER LINK UI
   

  Widget _buildRegisterLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
          children: [
            const TextSpan(text: "Don't have an account? "),

            TextSpan(
              text: 'Register Now',
              style: const TextStyle(
                color: AppColors.tealPrimary,
                fontWeight: FontWeight.w600,
              ),
              recognizer: TapGestureRecognizer()..onTap = _goToRegister,
            ),
          ],
        ),
      ),
    );
  }
}
