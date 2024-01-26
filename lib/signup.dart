
import 'package:finals/main.dart';
import 'package:flutter/material.dart';
import 'model/api_response.dart';
import 'package:finals/services/user_services.dart';
import 'style.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> registerUser() async {
    
    if (_formKey.currentState!.validate()) {
      ApiResponse response = await register(
          _nameController.text, _emailController.text, _passwordController.text);

      if (response.error == null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Register Completed'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => MyLogin(), // Replace with your main page
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Email is used or Validated your info')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         backgroundColor: Colors.grey.shade500.withOpacity(0.4),
        title: Text('Register User'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // Background Container with Gradient
          Container(
            padding: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueGrey, Colors.white38],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 50),
                  // Name TextFormField
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: textBoxStyle1("Enter your name", "Name"),
                      validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Name';
                      }
                      return null;
                    },
                    ),
                  ),
                  // Email TextFormField
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: textBoxStyle1("Enter your email", "Email"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                  ),
                  // Password TextFormField
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration:
                      textBoxStyle1("Enter your password", "Password"),
                       validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Submit Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          registerUser();
                        });
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
          // Image Container
          Positioned(
            top: 325.0, // Adjust the position as needed
            left: 0.0,
            right: 0.0, // Adjust the position as needed
            child: Opacity(
              opacity: 0.6, // Set the desired opacity (0.0 to 1.0)
              child: Container(
                width: 500.0, // Adjust the width as needed
                height: 500.0, // Adjust the height as needed
                child: Image.asset(
                  'assets/bg_back.png', // Provide the correct path to your image
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}