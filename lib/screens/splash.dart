import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prac_crud/screens/homepage.dart';
import 'package:prac_crud/screens/login.dart';

// final FirebaseAuth auth = FirebaseAuth.instance;

// final User user = auth.currentUser!;
// final uid = user.uid;

class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() {
    return _Splash();
  }
}

class _Splash extends State<Splash> {
  @override
  void initState() {
    super.initState();
    navigatetoNext();
  }

  void navigatetoNext() {
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                // print("User is: ${snapshot.data?.uid}");
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  return HomePage(
                    uid: snapshot.data?.uid,
                  );
                }
                return const Login();
              },
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 229, 202, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.network(
            //   'https://images.ctfassets.net/4cd45et68cgf/7LrExJ6PAj6MSIPkDyCO86/542b1dfabbf3959908f69be546879952/Netflix-Brand-Logo.png',
            //   width: 230,
            // ),
            Image.asset(
              "assets/images/login.jpg",
              width: 230,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ],
        ),
      ),
    );
  }
}
