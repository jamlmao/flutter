import 'package:flutter/material.dart';
import 'signup.dart';
import 'home.dart';
import 'package:finals/carlist.dart';
import 'model/user.dart';
import 'model/car.dart';
import 'package:finals/model/api_response.dart';
import 'package:finals/services/user_services.dart';
import 'package:finals/services/car_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'style.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  runApp(const MyLogin());
}

class MyLogin extends StatelessWidget {
  final String? token;
  const MyLogin({Key? key, this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: token == null ? MyApp() : Home(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();

  bool loading = false;

  Future<void> loginUser() async {
    ApiResponse response = await login(txtEmail.text, txtPassword.text);

    if (response.error == null) {
      _saveAndRedirectToHome(response.data as User);
    } else {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.error}')),
      );
    }
  }

  Future<void> _saveAndRedirectToHome(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', user.token ?? '');
    await prefs.setInt('userId', user.id ?? 0);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Home()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Add this line
      appBar: AppBar(
        backgroundColor: Colors.grey.shade500.withOpacity(0.4),
        title: const Text(""),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background Image
            Positioned(
              top: 425,
              left: 0,
              right: 0,
              child: Image.asset(
                "assets/bg_back.png",
                fit: BoxFit.cover,
              ),
            ),
            // Main Content Container
            Container(
              height: MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.top,
              color: Colors.grey.shade800.withOpacity(0.4),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 100),
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 17,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 11),
                  Form(
                    key: _formKey,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white38, Colors.blueGrey.shade300],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: txtEmail,
                            decoration: textBoxStyle(
                              "Enter your email",
                              "Email",
                              Icons.email,
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email!';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 9),
                          TextFormField(
                            controller: txtPassword,
                            obscureText: true,
                            decoration: textBoxStyle(
                              "Enter your password",
                              "Password",
                              Icons.lock,
                            ),
                            validator: (String? value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.length < 6) {
                                return 'Please enter your password!';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              loading = true;
                              loginUser();
                            });
                          }
                        },
                        style: ButtonStyle(
                          fixedSize:
                          MaterialStateProperty.all<Size>(Size(120, 45)),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.normal,
                              color: Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => Home(),
                                ),
                              );
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration textBoxStyle(
      String hintText, String label, IconData iconData) {
    return InputDecoration(
      hintText: hintText,
      labelText: label,
      prefixIcon: Icon(iconData),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.greenAccent, width: 5.0),
      ),
    );
  }
}
