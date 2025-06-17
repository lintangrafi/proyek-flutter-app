import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _apiUrl = '';
  String _email = '';
  String _password = '';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: EdgeInsets.all(24),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Login',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'API Server URL'),
                    onChanged: (val) => _apiUrl = val.trim(),
                    validator:
                        (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    onChanged: (val) => _email = val.trim(),
                    validator:
                        (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    onChanged: (val) => _password = val,
                    validator:
                        (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  _loading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                        child: Text('Login'),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _loading = true);
                            final auth = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            bool ok = await auth.login(
                              _apiUrl,
                              _email,
                              _password,
                            );
                            setState(() => _loading = false);
                            if (ok) {
                              // Sudah otomatis switch ke Home di main.dart
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Login gagal/server salah!'),
                                ),
                              );
                            }
                          }
                        },
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
