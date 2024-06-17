import 'package:flutter/material.dart';
import 'package:productalert/components/form_button.dart';
import 'package:productalert/components/form_input_field.dart';
import 'package:productalert/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _userNameController = TextEditingController();
  String? emailError, passwordError, usernameError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    emailError = null;
    passwordError = null;
    usernameError = null;
  }

  void resetErrorText() {
    setState(() {
      emailError = null;
      passwordError = null;
      usernameError = null;
    });
  }

  bool validate() {
    resetErrorText();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final userName = _userNameController.text.trim();

    RegExp emailExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    bool isValid = true;
    if (email.isEmpty || !emailExp.hasMatch(email)) {
      setState(() {
        emailError = 'Email is invalid';
      });
      isValid = false;
    }

    if (userName.isEmpty || userName.length < 3) {
      setState(() {
        usernameError = 'Username cannot be fewer than 3 characters';
      });
      isValid = false;
    }

    if (password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        passwordError = 'Please enter a password';
      });
      isValid = false;
    }
    if (password != confirmPassword) {
      setState(() {
        passwordError = 'Passwords do not match';
      });
      isValid = false;
    }

    return isValid;
  }

  void submit() {
    if (validate()) {
      _signup();
    }
  }

  Future<void> _signup() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final userName = _userNameController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        if (mounted) {
          context.showSnackBar("Please fill all fields", isError: true);
        }
        return;
      }

      final res = await supabase.auth.signUp(
          email: email,
          password: password,
          emailRedirectTo: "io.supabase.flutterquickstart://login-callback/",
          data: {
            "username": userName,
            "avatar_url":
                "https://api.dicebear.com/8.x/fun-emoji/svg?seed=$userName"
          });

      if (mounted) {
        if (res.user?.identities?.isEmpty == true) {
          context.showSnackBar('User already registered', isError: true);
        } else {
          context.showSnackBar('Success! Please check your inbox.');
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        context.showSnackBar(e.message, isError: true);
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            SizedBox(height: screenHeight * .12),
            const Text(
              'Create Account,',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * .01),
            Text(
              'Sign up to get started!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black.withOpacity(.6),
              ),
            ),
            SizedBox(height: screenHeight * .06),
            InputField(
              controller: _emailController,
              labelText: 'Email',
              errorText: emailError,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autoFocus: true,
            ),
            SizedBox(height: screenHeight * .025),
            InputField(
              controller: _userNameController,
              labelText: 'Username',
              errorText: usernameError,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              autoFocus: true,
            ),
            SizedBox(height: screenHeight * .025),
            InputField(
              controller: _passwordController,
              labelText: 'Password',
              errorText: passwordError,
              obscureText: true,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: screenHeight * .025),
            InputField(
              controller: _confirmPasswordController,
              onSubmitted: (value) => submit(),
              labelText: 'Confirm Password',
              errorText: passwordError,
              obscureText: true,
              textInputAction: TextInputAction.done,
            ),
            SizedBox(
              height: screenHeight * .075,
            ),
            FormButton(
              text: 'Sign Up',
              onPressed: submit,
            ),
            SizedBox(
              height: screenHeight * .125,
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: RichText(
                text: const TextSpan(
                  text: "I'm already a member, ",
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Sign In',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
