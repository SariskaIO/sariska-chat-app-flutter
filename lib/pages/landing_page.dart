import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _checkUserExistence() async {
    String username = _usernameController.text;

    String apiUrl =
        'http://api.dev.sariska.io/api/v1/messaging/users/verify?search_term=$username';

    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjM1YzVjMzMwYzgzMDlmNWE1MDNkMGE1Yzc0YmZmOGRhNzI2OGEzYWRiNTM0Y2I5YTYyYjljYzZiYmZjZGUwYTMiLCJ0eXAiOiJKV1QifQ.eyJjb250ZXh0Ijp7InVzZXIiOnsiaWQiOiJudnRqNnpyZSIsIm5hbWUiOiJuZXdfcGxhdHlwdXMifSwiZ3JvdXAiOiI5In0sInN1YiI6ImF2b241amN0bnBuMmQ5OHA0ZGVtdGYiLCJyb29tIjoiKiIsImlhdCI6MTcxMDEzNTc2NCwibmJmIjoxNzEwMTM1NzY0LCJpc3MiOiJzYXJpc2thIiwiYXVkIjoibWVkaWFfbWVzc2FnaW5nX2NvLWJyb3dzaW5nIiwiZXhwIjoxNzEwMjIyMTY0fQ.V6KycRM0WOzMtE-3Polfp6qaOm8UlmzsI9YVF8Wn3MXkjn0cObl0q59LV85sNIxUwg-i3SE57ACLukDvK9HURJwrXK_qrvmZV8cBZdzkYnSjIydVk2uIRnA4ENjosZaXpLQhfd5VM_k9gha1vL2n0WVeoOEsfz6euq288Y-8f7bIV8xOQ5wfVxB6tZGwYQ6Fy82XzUyH_OwpJBI0P8fBA5CqIm3rfIP492gH6BGHep9AwVDtoM9xnOjcibvNaEwELUSY6sbpRR2KfTpJRs5NbaYtb_hW3GZHQffBUUbrBpAkvB90WkjmkC7VaPfWHlehqaa7aT_rJIB4hdgTKS0IgA',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['exists']) {
          _navigateToNextPage(data['user']);
        } else {
          _showSignUpForm();
        }
      } else if (response.statusCode == 404) {
        _showSignUpForm();
      } else {
        print(
            'Error checking user existence. Status code: ${response.statusCode}');
        _showSignUpForm();
      }
    } catch (error) {
      print('Error checking user existence: $error');
    }
  }

  void _showSignUpForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Up'),
          content: Column(
            children: [
              TextField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                ),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _signUp();
              },
              child: const Text('Sign Up'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signUp() async {
    String userId = _userIdController.text;
    String email = _emailController.text;
    String apiUrl =
        'http://api.dev.sariska.io/api/v1/messaging/users/register?user_id=$userId&email=$email';

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization':
              'Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjM1YzVjMzMwYzgzMDlmNWE1MDNkMGE1Yzc0YmZmOGRhNzI2OGEzYWRiNTM0Y2I5YTYyYjljYzZiYmZjZGUwYTMiLCJ0eXAiOiJKV1QifQ.eyJjb250ZXh0Ijp7InVzZXIiOnsiaWQiOiJudnRqNnpyZSIsIm5hbWUiOiJuZXdfcGxhdHlwdXMifSwiZ3JvdXAiOiI5In0sInN1YiI6ImF2b241amN0bnBuMmQ5OHA0ZGVtdGYiLCJyb29tIjoiKiIsImlhdCI6MTcxMDEzNTc2NCwibmJmIjoxNzEwMTM1NzY0LCJpc3MiOiJzYXJpc2thIiwiYXVkIjoibWVkaWFfbWVzc2FnaW5nX2NvLWJyb3dzaW5nIiwiZXhwIjoxNzEwMjIyMTY0fQ.V6KycRM0WOzMtE-3Polfp6qaOm8UlmzsI9YVF8Wn3MXkjn0cObl0q59LV85sNIxUwg-i3SE57ACLukDvK9HURJwrXK_qrvmZV8cBZdzkYnSjIydVk2uIRnA4ENjosZaXpLQhfd5VM_k9gha1vL2n0WVeoOEsfz6euq288Y-8f7bIV8xOQ5wfVxB6tZGwYQ6Fy82XzUyH_OwpJBI0P8fBA5CqIm3rfIP492gH6BGHep9AwVDtoM9xnOjcibvNaEwELUSY6sbpRR2KfTpJRs5NbaYtb_hW3GZHQffBUUbrBpAkvB90WkjmkC7VaPfWHlehqaa7aT_rJIB4hdgTKS0IgA',
        },
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        _navigateToNextPage();
      } else {
        print('Registration failed. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error registering user: $error');
    }
  }

  void _navigateToNextPage([Map<String, dynamic>? userData]) {
    print('Navigating to the next page');
    if (userData != null) {
      print('User ID: ${userData['user_id']}');
      print('Email: ${userData['email']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landing Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Enter Username',
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _checkUserExistence();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
