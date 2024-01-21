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
    ApiResponse response = await register(
        _nameController.text, _emailController.text, _passwordController.text);

    if (response.error == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.data}')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register User'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
          padding: EdgeInsets.all(5.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: textBoxStyle1("Enter your name", "Name"),
                ),
                Divider(),
                TextFormField(
                  controller: _emailController,
                  decoration: textBoxStyle1("Enter your email", "Email"),
                ),
                Divider(),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: textBoxStyle1("Enter your password", "Password"),
                ),
                const SizedBox(height: 10),
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
                    child: const Text('Submit'))
              ],
            ),
          )),
    );
  }
}
