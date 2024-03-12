import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sariska_chat_app_flutter/controller/chat_controller.dart';
import 'package:sariska_chat_app_flutter/pages/chat_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  ChatController chatController = ChatController();

  Future<void> _checkUserExistence() async {
    String username = _usernameController.text;
    var token = await chatController.fetchToken(username);

    String apiUrl =
        'http://api.dev.sariska.io/api/v1/messaging/users/verify?search_term=$username';

    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
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
          title: Text(
            'Sign Up',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _userIdController,
                decoration: InputDecoration(
                  labelText: 'Enter User ID',
                  filled: true,
                  fillColor: Colors.greenAccent.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Enter Email',
                  filled: true,
                  fillColor: Colors.greenAccent.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _signUp();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
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
    var token = await chatController.fetchToken(userId);
    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        Map<String, dynamic>? userData = {
          'user_id': userId,
          'email': email,
        };
        _navigateToNextPage(userData);
      } else {
        print('Registration failed. Status code: ${response.statusCode}');
        print('Registration failed with error message ' + response.body);
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            username: userData['user_id'],
            email: userData['email'],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        shadowColor: Colors.black,
        title: const Text(
          'Sariska.io',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5),
        ),
        backgroundColor:
            Colors.greenAccent, // Apply greenAccent color to app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Enter Username',
                filled: true,
                fillColor: Colors.greenAccent.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _checkUserExistence();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
                  color: Colors.white,
                ), // Text color as white for better contrast
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);
    // path.lineTo(0, size.height); //starting point

    var controllPoint = Offset(size.width / 5, size.height / 2);
    // var controllPoint =
    //     Offset(size.width / 2, size.height); // point from where the curve start
    var endPoint =
        Offset(size.width, size.height); // point where the curve ends
    path.quadraticBezierTo(
        controllPoint.dx, controllPoint.dy, controllPoint.dx, controllPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
