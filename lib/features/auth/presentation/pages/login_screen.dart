import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isRegister = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isRegister ? 'Register' : 'Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Password')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final email = emailController.text;
                final password = passwordController.text;
                final bloc = context.read<AuthBloc>();

                if (isRegister) {
                  bloc.add(RegisterEvent(email, password));
                } else {
                  bloc.add(LoginEvent(email, password));
                }
              },
              child: Text(isRegister ? 'Register' : 'Login'),
            ),
            TextButton(
              onPressed: () => setState(() => isRegister = !isRegister),
              child: Text(isRegister ? 'Already have an account? Login' : 'Don’t have an account? Register'),
            ),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthError) {
                  return Text(state.message, style: const TextStyle(color: Colors.red));
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
