import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xasus__qore/screens/home_screen.dart';
import 'package:xasus__qore/screens/login_screen.dart';
import 'package:xasus__qore/utilis/utilis.dart';

class AuthMethods {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  // * Register User

  Future resgiterUser(
      {required String name,
      required String email,
      required String password,
      required BuildContext context}) async {
    try {
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // & Strore into cloud firestore

      await firestore.collection("users").doc(auth.currentUser!.uid).set({
        "name": name,
        "email": email,
        "password": password,
        "createdAt": DateTime.now()
      });

      // ignore: use_build_context_synchronously
      showSnackBar("Registered successfuly...", context);
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      showSnackBar("Registeration failed 👉${e.message}", context);
    }
  }

  // * Login User

  Future loginUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      showSnackBar(e.message.toString(), context);
    }
  }

  // * get user info

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserInfo() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection("users").doc(auth.currentUser!.uid).get();
    return snapshot;
  }

  // * Logout user

  Future<void> logout(BuildContext context) async {
    try {
      await auth.signOut();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    } catch (e) {
      // Handle any errors that occurred during logout
      print('Logout error: $e');
    }
  }
}
