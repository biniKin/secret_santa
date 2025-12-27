import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secrete_santa/services/auth_service.dart';
import 'package:secrete_santa/ui/create_group/create_group_page.dart';
import 'package:secrete_santa/ui/group_info_page/group_details_page.dart';
import 'package:secrete_santa/ui/home/home_bloc/home_bloc.dart';
import 'package:secrete_santa/ui/home/home_bloc/home_event.dart';

import 'package:secrete_santa/ui/home/home_bloc/home_state.dart';
import 'package:secrete_santa/ui/join_group/join_group_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double headerHeight = 200;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() {
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      context.read<HomeBloc>().add(LoadUserGroupsEvent(userId: userId));
    }
  }

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
              child: RefreshIndicator(
                onRefresh: () async {
                  _loadGroups();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const CreateGroupPage()),
                              ).then((_) => _loadGroups());
                            },
                          ),
                          const SizedBox(width: 16),
                          _ActionCard(
                            icon: Icons.group_add_outlined,
                            label: "Join Group",
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const JoinGroupPage()),
                              ).then((_) => _loadGroups());
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

                      const SizedBox(height: 20),

                      // Groups List or Empty State
                      BlocBuilder<HomeBloc, HomeState>(
                        builder: (context, state) {
                          if (state is HomeLoading) {
                            return const Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          } else if (state is HomeGroupsLoaded) {
                            return Column(
                              children: state.groups.map((group) {
                                return _GroupCard(
                                  groupId: group['groupId'] ?? '',
                                  groupName: group['groupName'] ?? 'Unnamed Group',
                                  memberCount: (group['members'] as List?)?.length ?? 0,
                                  exchangeDate: group['exchangeDate']?.toDate() ?? DateTime.now(),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => GroupDetailsPage(
                                          groupId: group['groupId'] ?? '',
                                          groupName: group['groupName'] ?? 'Unnamed Group',
                                        ),
                                      ),
                                    ).then((_) => _loadGroups());
                                  },
                                );
                              }).toList(),
                            );
                          } else if (state is HomeEmpty) {
                            return _buildEmptyState();
                          } else if (state is HomeError) {
                            return Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                children: [
                                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                                  const SizedBox(height: 16),
                                  Text(
                                    state.message,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            );
                          }
                          return _buildEmptyState();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
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

class _GroupCard extends StatelessWidget {
  final String groupId;
  final String groupName;
  final int memberCount;
  final DateTime exchangeDate;
  final VoidCallback onTap;

  const _GroupCard({
    required this.groupId,
    required this.groupName,
    required this.memberCount,
    required this.exchangeDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFAD2E2E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.card_giftcard,
                color: Color(0xFFAD2E2E),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$memberCount members • ${exchangeDate.day}/${exchangeDate.month}/${exchangeDate.year}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

