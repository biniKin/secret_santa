import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secrete_santa/ui/join_group/join_group_bloc/join_group_bloc.dart';
import 'package:secrete_santa/ui/join_group/join_group_bloc/join_group_event.dart';
import 'package:secrete_santa/ui/join_group/join_group_bloc/join_group_state.dart';

class JoinGroupPage extends StatefulWidget {
  const JoinGroupPage({super.key});

  @override
  State<JoinGroupPage> createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  static const double headerHeight = 200;
  final _formKey = GlobalKey<FormState>();
  final _groupCodeController = TextEditingController();

  @override
  void dispose() {
    _groupCodeController.dispose();
    super.dispose();
  }

  void _handleJoinGroup() {
    if (_formKey.currentState!.validate()) {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
        return;
      }

      context.read<JoinGroupBloc>().add(
        JoinGroupSubmitEvent(
          groupCode: _groupCodeController.text.trim().toUpperCase(),
          userId: userId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JoinGroupBloc, JoinGroupState>(
      listener: (context, state) {
        if (state is JoinGroupSuccess) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Success!'),
              content: Text(
                'You have joined "${state.groupName}" successfully!',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to home
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          );
        } else if (state is JoinGroupError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Join Group",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Enter the code to join an exchange",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              // Form Container
              Positioned.fill(
                top: headerHeight - 40,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Group Code Field
                          const Text(
                            "Group Code",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFAD2E2E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _groupCodeController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: "e.g., SANTA1234",
                              prefixIcon: const Icon(
                                Icons.code,
                                color: Color(0xFFAD2E2E),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFFFE8E8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFFFE8E8),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFAD2E2E),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a group code';
                              }
                              if (value.length < 6) {
                                return 'Group code must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Ask the group organizer for this code",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Info Container
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.withOpacity(0.3),
                              border: Border.all(
                                color: Colors.green,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: const Text(
                              "You'll be added to the group and notified when names are drawn",
                              style: TextStyle(fontSize: 13),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Join Button
                          BlocBuilder<JoinGroupBloc, JoinGroupState>(
                            builder: (context, state) {
                              final isLoading = state is JoinGroupLoading;
                              return ElevatedButton(
                                onPressed: isLoading ? null : _handleJoinGroup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFAD2E2E),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Text(
                                        'Join Group',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
