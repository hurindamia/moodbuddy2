import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  void _login() async {
    try {
      // 1. Sign in with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: email.text.trim(), password: password.text.trim());

      // 2. Check if user exists in Firestore (optional, for extra validation)
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // If user is missing in Firestore
        await FirebaseAuth.instance.signOut();
        throw Exception("User data not found in database!");
      }

      // 3. Navigate to home screen
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Login Failed"),
            content: Text(e.toString()),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("MoodBuddy", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF7B2CBF))),
              SizedBox(height: 40),
              TextField(controller: email, decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder())),
              SizedBox(height: 20),
              TextField(controller: password, obscureText: true, decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder())),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF7B2CBF), minimumSize: Size(double.infinity, 50)),
                onPressed: _login,
                child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen())),
                child: Text("Create an account"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
