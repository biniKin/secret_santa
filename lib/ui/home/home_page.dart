import 'package:flutter/material.dart';
import 'package:secrete_santa/ui/create_group/create_group_page.dart';
import 'package:secrete_santa/ui/join_group/join_group_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const double headerHeight = 200;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE8E8),
      body: SafeArea(
        child: Stack(
          children: [
            // Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: headerHeight,
                decoration: const BoxDecoration(
                  color: Color(0xFFAD2E2E),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Secret Santa",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Spread the holiday cheer",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Color(0xFFAD2E2E)),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Positioned.fill(
              top: headerHeight - 60,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Action Buttons
                    Row(
                      children: [
                        _ActionCard(
                          icon: Icons.add_circle_outline,
                          label: "Create Group",
                          onTap: () {
                            // TODO: Navigate to create group
                            Navigator.of(context).push(MaterialPageRoute(builder: (_)=>CreateGroupPage()));
                          },
                        ),
                        const SizedBox(width: 16),
                        _ActionCard(
                          icon: Icons.group_add_outlined,
                          label: "Join Group",
                          onTap: () {
                            // TODO: Navigate to join 
                            Navigator.of(context).push(MaterialPageRoute(builder: (_)=>JoinGroupPage()));
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Your groups",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),

                    // Empty State
                    const SizedBox(height: 40),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.card_giftcard_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No Groups Yet",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Create or join a group to start\nyour Secret Santa exchange!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFAD2E2E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFFAD2E2E), size: 32),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFAD2E2E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
