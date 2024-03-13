import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sariska_chat_app_flutter/components/app_colors.dart';
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
    String username = _usernameController.text; // this is email

    var token = await chatController.fetchToken(
      username,
      _emailController.text,
    );

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

      print("Response from check user existence ");
      print(response.body);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['exists']) {
          _navigateToNextPage(data['user'], token);
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
          title: const Text(
            'Sign Up',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _userIdController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(IconlyLight.profile),
                  labelText: 'Enter User ID',
                  filled: true,
                  fillColor: AppColors.colorPrimary.withOpacity(0.1),
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
                  prefixIcon: const Icon(CupertinoIcons.mail),
                  labelText: 'Enter Email',
                  filled: true,
                  fillColor: AppColors.colorPrimary.withOpacity(0.1),
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
                if (_emailController.text.isNotEmpty) {
                  _signUp();
                } else {
                  Fluttertoast.showToast(
                    msg: "please enter username",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorPrimary,
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
    var token = await chatController.fetchToken(userId, email);

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print("Signup Response");
      print(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        Map<String, dynamic>? userData = {
          'name': userId,
          'id': email,
        };
        _navigateToNextPage(userData, token);
      } else {
        print('Registration failed. Status code: ${response.statusCode}');
        print('Registration failed with error message ' + response.body);
      }
    } catch (error) {
      print('Error registering user: $error');
    }
  }

  void _navigateToNextPage(Map<String, dynamic>? userData, var token) {
    print('Navigating to the next page');
    print("User data values: ");
    print(userData);

    if (userData != null) {
      print('User ID: ${userData['user_id']}');
      print('Email: ${userData['email']}');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            username: userData['name'],
            email: userData['id'],
            token: token,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sariska.io',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5),
        ),
        backgroundColor: AppColors.colorPrimary,
      ),
      body: Stack(
        children: [
          ClipPath(
            clipper: MyClipper(),
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [AppColors.colorPrimary, AppColors.colorPrimary],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 100.0,
                ),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(IconlyLight.profile),
                    labelText: 'Enter Email',
                    filled: true,
                    fillColor: AppColors.colorPrimary.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    if (_usernameController.text.isNotEmpty) {
                      _checkUserExistence();
                    } else {
                      Fluttertoast.showToast(
                        msg: "Please enter a username",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorPrimary,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ), // Text color as white for better contrast
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
