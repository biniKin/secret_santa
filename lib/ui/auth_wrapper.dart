import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secrete_santa/ui/home/home_page.dart';
import 'package:secrete_santa/ui/intro_page/intro_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFAD2E2E),
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        // If user is logged in, show home page
        if (snapshot.hasData && snapshot.data != null) {
          return const HomePage();
        }

        // Otherwise show intro page
        return const IntroPage();
      },
    );
  }
}
