import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secrete_santa/models/group_model.dart';
import 'package:secrete_santa/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final _firestore = FirebaseFirestore.instance;
  static const String _userKey = 'current_user';

  // ==================== LOCAL STORAGE (SharedPreferences) ====================

  Future<void> saveUserLocally(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson(user));
      await prefs.setString(_userKey, userJson);
    } catch (e) {
      throw 'Error saving user locally: $e';
    }
  }

  Future<UserModel?> getUserLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      throw 'Error getting user locally: $e';
    }
  }

  Future<void> clearLocalUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      throw 'Error clearing local user: $e';
    }
  }

  // ==================== FIRESTORE - USER OPERATIONS ====================

  Future<void> saveUserToFirestore(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.userId).set({
        'userId': user.userId,
        'name': user.name,
        'email': user.email,
        'hasMatch': user.hasMatch,
        'isAdmin': user.isAdmin,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error saving user to Firestore: $e';
    }
  }

  Future<UserModel?> getUserFromFirestore(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw 'Error getting user from Firestore: $e';
    }
  }

  Future<void> updateUserInFirestore(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.userId).update({
        'name': user.name,
        'email': user.email,
        'hasMatch': user.hasMatch,
        'isAdmin': user.isAdmin,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error updating user in Firestore: $e';
    }
  }

  // ==================== FIRESTORE - GROUP OPERATIONS ====================

  Future<String> createGroupOnFirestore({
    required String groupName,
    required DateTime exchangeDate,
    required String adminId,
    String? budget,
  }) async {
    try {
      final groupRef = _firestore.collection('groups').doc();
      final groupCode = _generateGroupCode();

      await groupRef.set({
        'groupId': groupRef.id,
        'groupName': groupName,
        'groupCode': groupCode,
        'exchangeDate': Timestamp.fromDate(exchangeDate),
        'budget': budget,
        'adminId': adminId,
        'members': [adminId],
        'createdAt': FieldValue.serverTimestamp(),
        'hasDrawn': false,
      });

      // Update user to mark as admin of this group
      await _firestore.collection('users').doc(adminId).update({
        'groups': FieldValue.arrayUnion([groupRef.id]),
      });

      return groupRef.id;
    } catch (e) {
      throw 'Error creating group: $e';
    }
  }

  Future<Map<String, dynamic>?> getGroupFromFirestore(String groupId) async {
    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw 'Error getting group from Firestore: $e';
    }
  }

  Future<Map<String, dynamic>?> getGroupByCode(String groupCode) async {
    try {
      final querySnapshot = await _firestore
          .collection('groups')
          .where('groupCode', isEqualTo: groupCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
      return null;
    } catch (e) {
      throw 'Error getting group by code: $e';
    }
  }

  Future<List<Map<String, dynamic>>> getUserGroups(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('groups')
          .where('members', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw 'Error getting user groups: $e';
    }
  }

  Future<void> joinGroup(String groupId, String userId) async {
    try {
      await _firestore.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayUnion([userId]),
      });

      await _firestore.collection('users').doc(userId).update({
        'groups': FieldValue.arrayUnion([groupId]),
      });
    } catch (e) {
      throw 'Error joining group: $e';
    }
  }

  Future<List<UserModel>> getGroupMembers(List<String> memberIds) async {
    try {
      final List<UserModel> members = [];
      
      for (String memberId in memberIds) {
        final user = await getUserFromFirestore(memberId);
        if (user != null) {
          members.add(user);
        }
      }
      
      return members;
    } catch (e) {
      throw 'Error getting group members: $e';
    }
  }

  Future<void> updateGroup(String groupId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('groups').doc(groupId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error updating group: $e';
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      // Get group data first to remove from users
      final groupData = await getGroupFromFirestore(groupId);
      
      if (groupData != null) {
        final members = groupData['members'] as List<dynamic>;
        
        // Remove group from all members
        for (String memberId in members) {
          await _firestore.collection('users').doc(memberId).update({
            'groups': FieldValue.arrayRemove([groupId]),
          });
        }
      }

      // Delete the group
      await _firestore.collection('groups').doc(groupId).delete();
    } catch (e) {
      throw 'Error deleting group: $e';
    }
  }

  // ==================== HELPER METHODS ====================

  String _generateGroupCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    
    for (int i = 0; i < 6; i++) {
      code += chars[(random + i) % chars.length];
    }
    
    return code;
  }
}