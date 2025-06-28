import 'package:flutter/material.dart';
import '../utils/constants.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false; // State to track loading status

  // Function to handle login action
  // void _login() {
  //   if (_formKey.currentState?.validate() ?? false) {
  //     // Form is valid, proceed with login logic
  //     nextScreen(context, "/dashboard");
  //   } else {
  //     // Form is invalid, show error
  //     // ScaffoldMessenger.of(context).showSnackBar(
  //     //   const SnackBar(content: Text("Please fix the errors in the form")),
  //     // );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlueColor,
      appBar: AppBar(
        backgroundColor: BlueColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Container(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: 0.0,
                top: -15.0,
                child: Opacity(
                  opacity: 1,
                  child: Image.asset(
                    "assets/images/bk.png",
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 10.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Log in to your account",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 60.0,
                      ),
                      Flexible(
                        child: Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height,
                          constraints: BoxConstraints(
                            minHeight:
                            MediaQuery.of(context).size.height - 180.0,
                          ),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30.0),
                              topRight: Radius.circular(30.0),
                            ),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,  // Wrap form fields with Form widget
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text("Email", style: TextStyle(fontSize: 15.0)),
                                const SizedBox(height: 10.0),
                                TextFormField(
                                  controller: _emailController,
                                  // obscureText: true,
                                  cursorColor: RedColor,
                                  decoration: InputDecoration(
                                    suffixIcon: const Icon(Icons.email, color: Color.fromRGBO(74, 77, 84, 1)), // Move email icon to the right side
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: BlueColor,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors.red, // Red border when error occurs
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors.red, // Red border on focus with error
                                      ),
                                    ),
                                    hintText: "Enter your email address",
                                    hintStyle: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your Email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 22.0,
                                ),
                                const Text("Password", style: TextStyle(fontSize: 15.0)),
                                const SizedBox(height: 10.0),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  cursorColor: RedColor,
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                        color: const Color.fromRGBO(74, 77, 84, 1),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible = !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: BlueColor,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors.red, // Red border when error occurs
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors.red, // Red border on focus with error
                                      ),
                                    ),
                                    hintText: "Enter your password",
                                    hintStyle: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0), // Adjust this for reduced height
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your Password';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 15.0,
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    "Forgot Password?",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: BlueColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: RedColor,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    // onPressed: _login,  // Call _login function to validate form
                                    onPressed: () {  },
                                    child: const Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
