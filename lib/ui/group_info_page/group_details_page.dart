import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'package:secrete_santa/models/user_model.dart';
import 'package:secrete_santa/ui/group_info_page/group_info_bloc/group_info_bloc.dart';
import 'package:secrete_santa/ui/group_info_page/group_info_bloc/group_info_event.dart';
import 'package:secrete_santa/ui/group_info_page/group_info_bloc/group_info_state.dart';

class GroupDetailsPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupDetailsPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage>
    with SingleTickerProviderStateMixin {
  static const double headerHeight = 200;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;
  UserModel? _revealedMatch;

  @override
  void initState() {
    super.initState();
    // Load group details when page opens
    context.read<GroupInfoBloc>().add(
      LoadGroupDetailsEvent(groupId: widget.groupId),
    );

    // Initialize flip animation
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupInfoBloc, GroupInfoState>(
      listener: (context, state) {
        if (state is NamesDrawnSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          // Reload group details
          context.read<GroupInfoBloc>().add(
            LoadGroupDetailsEvent(groupId: widget.groupId),
          );
        } else if (state is UserMatchLoaded) {
          // Store match and flip card
          setState(() {
            _revealedMatch = state.match;
          });
          if (!_isFlipped) {
            _flipCard();
          }
        } else if (state is NoMatchFound) {
          // Store null match (no match found) and flip card
          setState(() {
            _revealedMatch = null;
          });
          if (!_isFlipped) {
            _flipCard();
          }
        } else if (state is GroupInfoError) {
          print('GroupInfoError: ${state.message}'); // Debug log
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is GroupLeftSuccess || state is GroupDeletedSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFE8E8),
        body: SafeArea(
          child: BlocBuilder<GroupInfoBloc, GroupInfoState>(
            buildWhen: (previous, current) {
              // Only rebuild for these states, ignore UserMatchLoaded and NoMatchFound
              return current is GroupInfoLoading ||
                  current is GroupInfoLoaded ||
                  current is GroupInfoError;
            },
            builder: (context, state) {
              if (state is GroupInfoLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is GroupInfoLoaded) {
                return _buildGroupDetails(state);
              }

              if (state is GroupInfoError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Error loading group',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          context.read<GroupInfoBloc>().add(
                            LoadGroupDetailsEvent(groupId: widget.groupId),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return const Center(child: Text('Failed to load group details'));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGroupDetails(GroupInfoLoaded state) {
    final groupData = state.groupData;
    final members = state.members;
    final groupCode = groupData['groupCode'] ?? 'N/A';
    final exchangeDate = groupData['exchangeDate']?.toDate() ?? DateTime.now();
    final budget = groupData['budget'] ?? 'Not set';
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isAdmin = groupData['adminId'] == currentUserId;
    final hasDrawn = groupData['hasDrawn'] ?? false;

    return Stack(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Back",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {
                        if (value == 'leave') {
                          _showLeaveGroupDialog(context, isAdmin);
                        } else if (value == 'delete') {
                          _showDeleteGroupDialog(context);
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        if (isAdmin) {
                          return [
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete Group',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ];
                        } else {
                          return [
                            const PopupMenuItem<String>(
                              value: 'leave',
                              child: Row(
                                children: [
                                  Icon(Icons.exit_to_app, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text(
                                    'Leave Group',
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ],
                              ),
                            ),
                          ];
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  widget.groupName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "${members.length} members",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Content
        Positioned.fill(
          top: headerHeight - 40,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Group Info Card
                Container(
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Group Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFAD2E2E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.calendar_today,
                        label: "Exchange Date",
                        value:
                            "${exchangeDate.day}/${exchangeDate.month}/${exchangeDate.year}",
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.attach_money,
                        label: "Budget",
                        value: budget.toString(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoRow(
                              icon: Icons.key,
                              label: "Group Code",
                              value: groupCode,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: groupCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Group code copied!'),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.copy,
                              color: Color(0xFFAD2E2E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                if (isAdmin && !hasDrawn) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Draw Names'),
                          content: const Text(
                            'Are you sure? This cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                context.read<GroupInfoBloc>().add(
                                  DrawNamesEvent(
                                    groupId: widget.groupId,
                                    memberIds: members
                                        .map((m) => m.userId)
                                        .toList(),
                                    groupName: widget.groupName,
                                  ),
                                );
                              },
                              child: const Text('Draw'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.shuffle),
                    label: const Text('Draw Names'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAD2E2E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Reveal Match Card (shown after drawing) - Flippable
                if (hasDrawn) ...[
                  AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {
                      final angle = _flipAnimation.value * math.pi;
                      final transform = Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle);

                      return Transform(
                        transform: transform,
                        alignment: Alignment.center,
                        child: angle >= math.pi / 2
                            ? Transform(
                                transform: Matrix4.identity()..rotateY(math.pi),
                                alignment: Alignment.center,
                                child: _buildRevealedCard(),
                              )
                            : _buildUnrevealedCard(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // Members List
                Container(
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Members",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFAD2E2E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...members.map(
                        (member) => _MemberTile(
                          name: member.name,
                          isAdmin: member.isAdmin,
                          hasMatch: member.hasMatch,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnrevealedCard() {
    return GestureDetector(
      onTap: () async {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        print("uiid: ${currentUserId}");
        if (!_isFlipped) {
          context.read<GroupInfoBloc>().add(
            GetUserMatchEvent(
              groupId: widget.groupId,
              userId: currentUserId ?? '',
            ),
          );
        }
      },
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFAD2E2E), Color(0xFFD84545)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFAD2E2E).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '🎁 Your Secret Match 🎁',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap to reveal who you\'re buying for!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'TAP TO REVEAL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFAD2E2E),
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevealedCard() {
    final hasMatch = _revealedMatch != null;

    return GestureDetector(
      onTap: _flipCard,
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: hasMatch
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.card_giftcard,
                    size: 48,
                    color: Color(0xFFAD2E2E),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'You\'re buying for:',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFAD2E2E), Color(0xFFD84545)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _revealedMatch!.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '🤫 Remember, it\'s a secret!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tap to flip back',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.hourglass_empty,
                    size: 48,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Match Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'The admin hasn\'t drawn names yet.\nYou\'ll be notified when it\'s done!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tap to flip back',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
      ),
    );
  }

  void _showLeaveGroupDialog(BuildContext context, bool isAdmin) {
    if (isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admins cannot leave the group. Delete it instead.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave Group'),
        content: const Text(
          'Are you sure you want to leave this group? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              final currentUserId =
                  FirebaseAuth.instance.currentUser?.uid ?? '';
              context.read<GroupInfoBloc>().add(
                LeaveGroupEvent(groupId: widget.groupId, userId: currentUserId),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _showDeleteGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text(
          'Are you sure you want to delete this group? All members will be removed and this action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<GroupInfoBloc>().add(
                DeleteGroupEvent(groupId: widget.groupId),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFAD2E2E), size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  final String name;
  final bool isAdmin;
  final bool hasMatch;

  const _MemberTile({
    required this.name,
    required this.isAdmin,
    required this.hasMatch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFAD2E2E).withOpacity(0.1),
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFAD2E2E),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isAdmin)
                  Text(
                    "Admin",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
          if (hasMatch)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Matched",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
