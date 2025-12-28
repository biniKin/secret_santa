import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secrete_santa/models/user_model.dart';
import 'package:secrete_santa/services/storage_service.dart';

class GroupService {
  final _storageService = StorageService();
  final _firestore = FirebaseFirestore.instance;

  // ==================== CREATE GROUP ====================

  Future<String> createGroup({
    required String groupName,
    required DateTime exchangeDate,
    required String adminId,
    String? budget,
  }) async {
    try {
      final groupId = await _storageService.createGroupOnFirestore(
        groupName: groupName,
        exchangeDate: exchangeDate,
        adminId: adminId,
        budget: budget,
      );
      return groupId;
    } catch (e) {
      throw 'Error creating group: $e';
    }
  }

  // ==================== FETCH GROUPS ====================

  Future<List<Map<String, dynamic>>> fetchUserGroups(String userId) async {
    try {
      return await _storageService.getUserGroups(userId);
    } catch (e) {
      throw 'Error fetching user groups: $e';
    }
  }

  Future<Map<String, dynamic>?> fetchGroupById(String groupId) async {
    try {
      return await _storageService.getGroupFromFirestore(groupId);
    } catch (e) {
      throw 'Error fetching group: $e';
    }
  }

  Future<Map<String, dynamic>?> fetchGroupByCode(String groupCode) async {
    try {
      return await _storageService.getGroupByCode(groupCode);
    } catch (e) {
      throw 'Error fetching group by code: $e';
    }
  }

  // ==================== JOIN GROUP ====================

  Future<void> joinGroupWithCode({
    required String groupCode,
    required String userId,
  }) async {
    try {
      final groupData = await _storageService.getGroupByCode(groupCode);

      if (groupData == null) {
        throw 'Group not found with code: $groupCode';
      }

      final groupId = groupData['groupId'];
      final members = List<String>.from(groupData['members'] ?? []);

      if (members.contains(userId)) {
        throw 'You are already a member of this group';
      }

      await _storageService.joinGroup(groupId, userId);
    } catch (e) {
      throw 'Error joining group: $e';
    }
  }

  // ==================== GROUP MEMBERS ====================

  Future<List<UserModel>> getGroupMembers(String groupId) async {
    try {
      final groupData = await _storageService.getGroupFromFirestore(groupId);

      if (groupData == null) {
        throw 'Group not found';
      }

      final memberIds = List<String>.from(groupData['members'] ?? []);
      return await _storageService.getGroupMembers(memberIds);
    } catch (e) {
      throw 'Error getting group members: $e';
    }
  }

  // ==================== DRAW NAMES (SECRET SANTA MATCHING) ====================

  Future<void> drawNames(String groupId) async {
    try {
      final groupData = await _storageService.getGroupFromFirestore(groupId);

      if (groupData == null) {
        throw 'Group not found';
      }

      if (groupData['hasDrawn'] == true) {
        throw 'Names have already been drawn for this group';
      }

      final memberIds = List<String>.from(groupData['members'] ?? []);

      if (memberIds.length < 2) {
        throw 'Need at least 2 members to draw names';
      }

      // Create matches using Secret Santa algorithm
      final matches = _generateSecretSantaMatches(memberIds);

      // Save matches to Firestore
      final batch = _firestore.batch();

      matches.forEach((giver, receiver) {
        final matchRef = _firestore.collection('matches').doc();
        batch.set(matchRef, {
          'groupId': groupId,
          'giverId': giver,
          'receiverId': receiver,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      // Update group to mark as drawn
      final groupRef = _firestore.collection('groups').doc(groupId);
      batch.update(groupRef, {
        'hasDrawn': true,
        'drawnAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw 'Error drawing names: $e';
    }
  }

  // ==================== GET USER'S MATCH ====================

  Future<UserModel?> getUserMatch(String groupId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('matches')
          .where('groupId', isEqualTo: groupId)
          .where('giverId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final matchData = querySnapshot.docs.first.data();
      final receiverId = matchData['receiverId'];

      return await _storageService.getUserFromFirestore(receiverId);
    } catch (e) {
      throw 'Error getting user match: $e';
    }
  }

  // ==================== UPDATE GROUP ====================

  Future<void> updateGroup(String groupId, Map<String, dynamic> data) async {
    try {
      await _storageService.updateGroup(groupId, data);
    } catch (e) {
      throw 'Error updating group: $e';
    }
  }

  // ==================== DELETE GROUP ====================

  Future<void> deleteGroup(String groupId) async {
    try {
      // Delete all matches for this group
      final matchesSnapshot = await _firestore
          .collection('matches')
          .where('groupId', isEqualTo: groupId)
          .get();

      final batch = _firestore.batch();
      for (var doc in matchesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Delete the group
      await _storageService.deleteGroup(groupId);
    } catch (e) {
      throw 'Error deleting group: $e';
    }
  }

  // ==================== LEAVE GROUP ====================

  Future<void> leaveGroup(String groupId, String userId) async {
    try {
      final groupData = await _storageService.getGroupFromFirestore(groupId);

      if (groupData == null) {
        throw 'Group not found';
      }

      if (groupData['adminId'] == userId) {
        throw 'Admin cannot leave the group. Please delete the group or transfer admin rights first.';
      }

      if (groupData['hasDrawn'] == true) {
        throw 'Cannot leave group after names have been drawn';
      }

      await _firestore.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayRemove([userId]),
      });

      await _firestore.collection('users').doc(userId).update({
        'groups': FieldValue.arrayRemove([groupId]),
      });
    } catch (e) {
      throw 'Error leaving group: $e';
    }
  }

  // ==================== HELPER METHODS ====================

  Map<String, String> _generateSecretSantaMatches(List<String> memberIds) {
    final Map<String, String> matches = {};
    final List<String> givers = List.from(memberIds);
    final List<String> receivers = List.from(memberIds);

    // Shuffle receivers
    receivers.shuffle(Random());

    // Ensure no one gets themselves
    for (int i = 0; i < givers.length; i++) {
      if (givers[i] == receivers[i]) {
        // Swap with next person (or previous if last)
        final swapIndex = (i + 1) % receivers.length;
        final temp = receivers[i];
        receivers[i] = receivers[swapIndex];
        receivers[swapIndex] = temp;
      }
    }

    // Create matches
    for (int i = 0; i < givers.length; i++) {
      matches[givers[i]] = receivers[i];
    }

    return matches;
  }

  // ==================== STREAM METHODS ====================

  Stream<List<Map<String, dynamic>>> streamUserGroups(String userId) {
    return _firestore
        .collection('groups')
        .where('members', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<Map<String, dynamic>?> streamGroup(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }
}