import 'package:flutter/material.dart';
import 'providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _cnicController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSignUp = true;
  bool _isLoading = false; // Track loading state
  String _role = "customer";

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('CleanMatch Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (_isSignUp) _buildTextField(_nameController, 'Full Name'),
                if (_isSignUp)
                  _buildTextField(
                    _cnicController,
                    'CNIC Number',
                    validator: _validateCnic,
                  ),
                _buildTextField(
                  _emailController,
                  'Email',
                  validator: _validateEmail,
                ),
                _buildTextField(
                  _passwordController,
                  'Password',
                  obscureText: true,
                  validator: _validatePassword,
                ),
                if (_isSignUp) _buildRoleDropdown(),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () => _handleSubmit(authProvider),
                        child: Text(_isSignUp ? 'Sign Up' : 'Log In'),
                      ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSignUp = !_isSignUp;
                    });
                  },
                  child: Text(
                    _isSignUp
                        ? 'Already have an account? Log In'
                        : 'Don’t have an account? Sign Up',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {String? Function(String?)? validator, bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      obscureText: obscureText,
      validator: validator ?? _defaultValidator,
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _role,
      items: const [
        DropdownMenuItem(value: "customer", child: Text("Customer")),
        DropdownMenuItem(value: "worker", child: Text("Worker")),
      ],
      onChanged: (value) => setState(() => _role = value!),
      decoration: const InputDecoration(labelText: "Select Role"),
    );
  }

  Future<void> _handleSubmit(AuthProvider authProvider) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        if (_isSignUp) {
          await authProvider.signUpWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            name: _nameController.text.trim(),
            cnic: _cnicController.text.trim(),
            role: _role,
          );
        } else {
          await authProvider.signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication Successful')),
        );

        // Navigate based on role
        final role = authProvider.userData?['role'] ?? 'customer';
        if (role == 'customer') {
          Navigator.pushReplacementNamed(context, '/customer-dashboard');
        } else if (role == 'worker') {
          Navigator.pushReplacementNamed(context, '/worker-dashboard');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(value) ? null : 'Enter a valid email';
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password is required';
    return value.length >= 6 ? null : 'Password must be at least 6 characters';
  }

  String? _validateCnic(String? value) {
    if (value == null || value.trim().isEmpty) return 'CNIC is required';
    final cnicRegex = RegExp(r'^\d{5}-\d{7}-\d{1}$');
    return cnicRegex.hasMatch(value)
        ? null
        : 'Enter a valid CNIC (e.g., 12345-1234567-1)';
  }

  String? _defaultValidator(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;
}
