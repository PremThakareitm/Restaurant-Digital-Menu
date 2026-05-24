import 'package:flutter/material.dart';
import 'package:restaurant_digital_menu/services/auth_service.dart';
import 'package:restaurant_digital_menu/screens/home_screen.dart';
import 'package:restaurant_digital_menu/theme/app_theme.dart';
import '../utils/test_ids.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  String _name = '';
  String _email = '';
  String _password = '';
  String _errorMessage = '';
  bool _isLoading = false;

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      bool success = await _authService.register(_name, _email, _password);
      setState(() {
        _isLoading = false;
      });
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to sign up. The user may already exist.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.light.primaryColor, AppTheme.light.colorScheme.secondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create Account',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign up to get started',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 32),
                      Semantics(
                        identifier: TestIds.signupNameField,
                        child: TextFormField(
                          key: const Key(TestIds.signupNameField),
                          decoration: InputDecoration(
                            labelText: 'Name',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter your name' : null,
                          onSaved: (value) => _name = value!,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Semantics(
                        identifier: TestIds.signupEmailField,
                        child: TextFormField(
                          key: const Key(TestIds.signupEmailField),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter your email' : null,
                          onSaved: (value) => _email = value!,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Semantics(
                        identifier: TestIds.signupPasswordField,
                        child: TextFormField(
                          key: const Key(TestIds.signupPasswordField),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) => value!.length < 6
                              ? 'Password must be at least 6 characters'
                              : null,
                          onSaved: (value) => _password = value!,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: Semantics(
                                identifier: TestIds.signupButton,
                                child: ElevatedButton(
                                  key: const Key(TestIds.signupButton),
                                  onPressed: _signup,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Sign Up'),
                                ),
                              ),
                            ),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Semantics(
                        identifier: TestIds.signupLoginLink,
                        child: TextButton(
                          key: const Key(TestIds.signupLoginLink),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Already have an account? Login'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
