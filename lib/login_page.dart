import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:musicapp_flutter/main.dart';
import 'package:musicapp_flutter/register.dart';
import 'package:http/http.dart' as http;
import 'package:musicapp_flutter/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {


  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {


  final _formKey = GlobalKey<FormState>(); // For form validation

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  bool _isLoading = false; // Login button loading state

   @override
  void initState() {
    super.initState();
  
  }
Future<void> _handleLogin() async {
  final String username = _usernameController.text;
  final String password = _passwordController.text;

  UserRole role = UserRole.customer;
  String currentUser = username;
  User user = User(currentUser, role);

  try {
    if (username == 'admin' && password == 'password123') {
      role = UserRole.admin;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin login successful')),
      );

      setState(() {
        currentUser = user.username;
        _isLoading = false;
      });

      // Check if the widget is still mounted before navigating
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage(title: 'Home Page by: $username', currentUser: currentUser)),
        );
      }
    } else {
      final Uri uri = Uri.parse('https://fluttermusicapp.000webhostapp.com/api/login.php?username=$username&password=$password');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['message'] != null) {
          // Login successful for a normal user
          print("Login successful");
          role = UserRole.customer;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful')),
          );

          setState(() {
            _isLoading = false;
          });

          // Check if the widget is still mounted before navigating
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage(title: 'Home Page by: $username', currentUser: currentUser)),
            );
          }
        } else {
          // Invalid username or password
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid username or password')),
            );

            setState(() {
              _isLoading = false;
            });
          }
        }
      } else {
        // Handle HTTP errors
        print('Failed to connect to the server');
      }
    }
  } catch (e) {
    print('Error during login process: $e');
  
    if (mounted) {
      if (e is FormatException) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Invalid data format received')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred during login')),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }
}


  void _togglePasswordVisibility() {
    setState(() {
      _passwordObscureText = !_passwordObscureText;
    });
  }

  bool _passwordObscureText = true; // Initial password visibility state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music App Login'),
        backgroundColor: Theme
            .of(context)
            .primaryColor, 
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               
                const FlutterLogo(size: 100.0),
                
                const SizedBox(height: 20.0),

                // Username text field with validation
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          10.0),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10.0),

                // Password text field with validation and visibility toggle
                TextFormField(
                  controller: _passwordController,
                  obscureText: _passwordObscureText,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordObscureText ? Icons.visibility_off : Icons
                            .visibility,
                        color: Colors.grey, 
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20.0),

                // Login button with loading indicator
               SizedBox(
  height: 56.0, 
  child: ElevatedButton(
    onPressed: _isLoading ? null : _handleLogin,
    style: ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),
    child: _isLoading
         ? const CircularProgressIndicator(color: Colors.white)
        : const Text('Login'),
  ),
),

                const SizedBox(height: 20.0),          // Inside your LoginPage build method
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationPage()),
    );
  },
  child: Text(
    'Click here to register',
    style: TextStyle(
      color: Colors.blue, // Set the text color as per your design
      decoration: TextDecoration.underline,
    ),
  ),
),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
