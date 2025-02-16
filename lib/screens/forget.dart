import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prac_crud/screens/signup.dart';
import 'package:google_fonts/google_fonts.dart';

final fireBase = FirebaseAuth.instance;

class Forget extends StatefulWidget {
  const Forget({super.key});

  @override
  State<StatefulWidget> createState() {
    return _Forget();
  }
}

class _Forget extends State<Forget> {
  final formKey = GlobalKey<FormState>();
  var _email;
  bool check = false;

  void _submit() async {
    final isValid = formKey.currentState!.validate();

    if (!isValid) {
      return;
    } else {
      formKey.currentState!.save();
      try {
        final userEmail = fireBase.sendPasswordResetEmail(email: _email);
        setState(() {
          check = true;
        });
      } on FirebaseAuthException catch (error) {
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
      ),
      backgroundColor: Color.fromRGBO(255, 229, 202, 1),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(top: 40),
            child: Form(
              key: formKey,
              child: !check
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            style: GoogleFonts.rajdhani(
                              textStyle: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            "We will send you an email with the instructions on how to reset you password."),
                        const SizedBox(
                          height: 25,
                        ),

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
                            contentPadding: EdgeInsets.fromLTRB(15, 25, 5, 5),
                            labelText: "Enter your registered email",
                            floatingLabelBehavior: FloatingLabelBehavior.never,
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

                        //
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 255, 255, 255),
                            surfaceTintColor: Colors.white,
                            elevation: 4,
                            shadowColor: Colors.black,
                            fixedSize: const Size(400, 55),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                          ),
                          child: Text(
                            "Send",
                            style: GoogleFonts.rajdhani(
                              textStyle: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const Text(
                            style: TextStyle(
                                color: Color.fromARGB(224, 0, 0, 0),
                                fontSize: 20),
                            "We have sent you the instructions on the email."),
                        const SizedBox(
                          height: 20,
                        ),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color.fromARGB(255, 83, 81, 81),
                                width: 2),
                            foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                            backgroundColor: Color.fromARGB(255, 255, 255, 255),
                            fixedSize: const Size(400, 55),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(7),
                              ),
                            ),
                          ),
                          child: const Text(
                            "Back to Login",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
