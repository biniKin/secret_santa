import 'package:flutter/material.dart';
import 'package:secrete_santa/ui/auth_page/login_page.dart';
import 'package:secrete_santa/ui/auth_page/signup_page.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAD2E2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // Logo/Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  size: 100,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Secret Santa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              
              // Subtitle
              const Text(
                'Spread joy and surprise your loved ones with thoughtful gifts',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              
              // Features
              _FeatureItem(
                icon: Icons.group,
                text: 'Create or join gift exchange groups',
              ),
              const SizedBox(height: 16),
              _FeatureItem(
                icon: Icons.shuffle,
                text: 'Automatic and fair Secret Santa matching',
              ),
              const SizedBox(height: 16),
              _FeatureItem(
                icon: Icons.celebration,
                text: 'Make the holidays more magical',
              ),
              
              const Spacer(),
              
              // Get Started Button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignupPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFAD2E2E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Sign In Button
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.white, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}