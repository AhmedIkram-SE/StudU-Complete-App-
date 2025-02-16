import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prac_crud/screens/forget.dart';
import 'package:prac_crud/screens/homepage.dart';
import 'package:flutter/services.dart';
import 'package:prac_crud/screens/signup.dart';

final fireBase = FirebaseAuth.instance;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() {
    return _Login();
  }
}

class _Login extends State<Login> {
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();
  var _email;
  var _password;

  void _submit() async {
    final isValid = formKey.currentState!.validate();

    if (!isValid) {
      return;
    } else {
      formKey.currentState!.save();
      setState(() {
        isLoading = true;
      });
      print("Loading is: $isLoading");
      try {
        final userCredentials = await fireBase.signInWithEmailAndPassword(
            email: _email, password: _password);
        setState(() {
          isLoading = false;
        });
        print("Loading is: $isLoading");
      } on FirebaseAuthException catch (error) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? "Authentication Failed"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.black,
        backgroundColor: Color.fromRGBO(255, 229, 202, 1),
        surfaceTintColor: Colors.white,
        // systemOverlayStyle: const SystemUiOverlayStyle(
        //   statusBarColor: Color.fromARGB(255, 0, 0, 0),
        // ),
        // elevation: 4,
        leadingWidth: 100,
      ),
      backgroundColor: Color.fromRGBO(255, 229, 202, 1),
      body: Container(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: SingleChildScrollView(
          child: Container(
            // padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                Container(
                  height: 300,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/login.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          cursorColor: const Color.fromARGB(255, 0, 0, 0),
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.rajdhani(
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 25, 5, 5),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            labelText: "Email Address",
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w300,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Color.fromARGB(255, 255, 255, 255),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains("@")) {
                              return "Please enter a valid email address";
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            _email = value;
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          cursorColor: const Color.fromARGB(255, 0, 0, 0),
                          style: GoogleFonts.rajdhani(
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(15, 25, 5, 5),
                            labelText: "Password",
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            labelStyle: TextStyle(
                              color: Colors.black,
                              letterSpacing: 0,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Color.fromARGB(255, 255, 255, 255),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                value.length < 6) {
                              return "Please enter a valid password";
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            _password = value;
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            elevation: 4,
                            shadowColor: Colors.black,
                            backgroundColor: Colors.white,
                            surfaceTintColor: Colors.white,
                            fixedSize: const Size(200, 30),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                          ),
                          child: isLoading
                              ? const LinearProgressIndicator(
                                  color: Colors.black,
                                )
                              : Text(
                                  "Sign In",
                                  style: GoogleFonts.rajdhani(
                                    textStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return const Forget();
                                },
                              ),
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: GoogleFonts.rajdhani(
                              textStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return const Signup();
                                },
                              ),
                            );

                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) {
                            //       return const Signup();
                            //     },
                            //   ),
                            // );
                          },
                          child: Text(
                            "New to the App? Sign Up now",
                            style: GoogleFonts.rajdhani(
                              textStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 19,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                      ],
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
