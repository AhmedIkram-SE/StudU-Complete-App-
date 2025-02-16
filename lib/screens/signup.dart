import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prac_crud/screens/homepage.dart';
import 'package:google_fonts/google_fonts.dart';

final fireBase = FirebaseAuth.instance;
final FirebaseFirestore db = FirebaseFirestore.instance;

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<StatefulWidget> createState() {
    return _Signup();
  }
}

class _Signup extends State<Signup> {
  final fKey = GlobalKey<FormState>();
  bool _vari = false;
  bool isLogin = false;

  var _email;
  var _password;

  void _submit() async {
    final isValid = fKey.currentState!.validate();

    if (!isValid) {
      return;
    } else {
      fKey.currentState!.save();
      setState(() {
        isLogin = true;
      });
      try {
        final userCredentials = await fireBase.createUserWithEmailAndPassword(
            email: _email, password: _password);
        db.collection('Users').add({
          'name': 'N/A',
          'email': userCredentials.user!.email,
          'userID': userCredentials.user!.uid,
          'phoneNumber': 'N/A',
          'university': 'N/A',
          'cgpa': 'N/A',
          'currentSemester': 'N/A',
          'file': "No image attached",
          'fileName': "N/A"
        });
        setState(() {
          isLogin = false;
        });
        Navigator.of(context).pop();
      } on FirebaseAuthException catch (error) {
        setState(() {
          isLogin = false;
        }); // ScaffoldMessenger.of(context).clearSnackBars();
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
      ),
      backgroundColor: Color.fromRGBO(255, 229, 202, 1),
      body: Container(
        padding: const EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Manage Assignments, Quizes, & add Notes.",
                style: GoogleFonts.rajdhani(
                  textStyle: TextStyle(
                      fontSize: 26,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      height: 0),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Text(
                "Create an account and start managing yourself, add assignments, quizes, notes for later usage.",
                style: GoogleFonts.rajdhani(
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(
                height: 17,
              ),
              Form(
                key: fKey,
                child: Column(
                  children: [
                    TextFormField(
                      cursorColor: Colors.black,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Email",
                        labelStyle: TextStyle(
                          color: Colors.black,
                          letterSpacing: 0,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        contentPadding: EdgeInsets.fromLTRB(15, 25, 5, 5),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                            borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.rajdhani(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value!.trim().isEmpty ||
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
                      cursorColor: Colors.black,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Password",
                        labelStyle: TextStyle(
                          color: Colors.black,
                          letterSpacing: 0,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        contentPadding: EdgeInsets.fromLTRB(15, 25, 5, 5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                      ),
                      obscureText: true,
                      style: GoogleFonts.rajdhani(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
                      height: 25,
                    ),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(3),
                            ),
                          ),
                          elevation: 4,
                          shadowColor: Colors.black,
                          fixedSize: const Size(
                            400,
                            45,
                          ),
                          backgroundColor:
                              const Color.fromARGB(255, 255, 255, 255),
                          surfaceTintColor: Colors.white),
                      child: isLogin
                          ? const LinearProgressIndicator(
                              color: Colors.black,
                            )
                          : Text(
                              "Create Account",
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(color: Colors.black),
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
