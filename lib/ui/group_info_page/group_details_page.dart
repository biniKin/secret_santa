import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GroupDetailsPage extends StatefulWidget {
  const GroupDetailsPage({super.key});

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  static const double headerHeight = 200;
  
  // TODO: Replace with actual data from Firebase
  final String groupName = "Office Secret Santa 2024";
  final String groupCode = "ABC123";
  final String exchangeDate = "25/12/2024";
  
  final bool isAdmin = true;
  final List<Map<String, dynamic>> members = [
    {"name": "John Doe", "isAdmin": true, "hasMatch": true},
    {"name": "Jane Smith", "isAdmin": false, "hasMatch": true},
    {"name": "Mike Johnson", "isAdmin": false, "hasMatch": false},
    {"name": "Sarah Williams", "isAdmin": false, "hasMatch": true},
  ];

  void _copyGroupCode() {
    Clipboard.setData(ClipboardData(text: groupCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Group code copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  

  void _drawNames() {
    // TODO: Implement draw names logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Draw Names'),
        content: const Text('Are you sure you want to draw names? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement actual draw logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFAD2E2E),
            ),
            child: const Text('Draw Names'),
          ),
        ],
      ),
    );
  }

  void _viewMyMatch() {
    // TODO: Navigate to match details
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('View match functionality coming soon')),
    );
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
                    Text(
                      groupName,
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
                            value: exchangeDate,
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
                                onPressed: _copyGroupCode,
                                icon: const Icon(Icons.copy, color: Color(0xFFAD2E2E)),
                                tooltip: 'Copy code',
                              ),
                              
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    if (isAdmin) ...[
                      ElevatedButton.icon(
                        onPressed: _drawNames,
                        icon: const Icon(Icons.shuffle),
                        label: const Text('Draw Names'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFAD2E2E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    OutlinedButton.icon(
                      onPressed: _viewMyMatch,
                      icon: const Icon(Icons.card_giftcard),
                      label: const Text('View My Match'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFAD2E2E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFAD2E2E), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

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
                          ...members.map((member) => _MemberTile(
                            name: member["name"],
                            isAdmin: member["isAdmin"],
                            hasMatch: member["hasMatch"],
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
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
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
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