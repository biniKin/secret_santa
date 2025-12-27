import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secrete_santa/services/auth_service.dart';
import 'package:secrete_santa/ui/create_group/create_group_bloc/create_bloc.dart';
import 'package:secrete_santa/ui/create_group/create_group_bloc/create_event.dart';
import 'package:secrete_santa/ui/create_group/create_group_bloc/create_state.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  static const double headerHeight = 200;
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _budgetController = TextEditingController();
  final _authService = AuthService();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _groupNameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFAD2E2E),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleCreateGroup() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an exchange date')),
        );
        return Future.value();
      }

      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return Future.value();
      }

      context.read<CreateGroupBloc>().add(
        CreateGroupSubmitEvent(
          groupName: _groupNameController.text.trim(),
          exchangeDate: _selectedDate!,
          adminId: userId,
          budget: _budgetController.text.trim().isEmpty 
              ? null 
              : _budgetController.text.trim(),
        ),
      );
    }
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateGroupBloc, CreateGroupState>(
      listener: (context, state) {
        if (state is CreateGroupSuccess) {
          // Show success dialog with group code
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Group Created!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Your group has been created successfully!'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE8E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Group Code',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.groupCode,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFAD2E2E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Share this code with participants to join the group.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
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
        } else if (state is CreateGroupError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        children: const [
                          Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                          SizedBox(width: 4),
                          Text(
                            "Back",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Create Group",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Set up your Secret Santa exchange",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
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
                        // Group Name Field
                        const Text(
                          "Group Name",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFAD2E2E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _groupNameController,
                          decoration: InputDecoration(
                            hintText: "Friends Secret Santa",
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.group, color: Color(0xFFAD2E2E)),
                            filled: true,
                            fillColor: const Color(0xFFFFE8E8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFFFE8E8)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFAD2E2E), width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a group name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Exchange Date Field
                        const Text(
                          "Exchange Date",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFAD2E2E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE8E8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Color(0xFFAD2E2E)),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedDate == null
                                      ? "Select exchange date"
                                      : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedDate == null ? Colors.grey : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Budget Field
                        const Text(
                          "Budget (Optional)",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFAD2E2E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _budgetController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "e.g., 50",
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.attach_money, color: Color(0xFFAD2E2E)),
                            filled: true,
                            fillColor: const Color(0xFFFFE8E8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFFFE8E8)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFAD2E2E), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // container
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withOpacity(0.3),
                            border: Border.all(
                              color: Colors.green,
                              width: 0.1
                            ),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          padding: EdgeInsets.all(10),

                          child: Text("After creating the group, you'll receive a unique code to share with participants."),
                        ),

                        const SizedBox(height: 32),

                        // Create Button
                        BlocBuilder<CreateGroupBloc, CreateGroupState>(
                          builder: (context, state) {
                            final isLoading = state is CreateGroupLoading;
                            return ElevatedButton(
                              onPressed: isLoading ? null : _handleCreateGroup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFAD2E2E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
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
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Create Group',
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
              )
            )
          ]
        )
      )
    )
    );
          
  }
}