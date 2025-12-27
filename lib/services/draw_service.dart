import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secrete_santa/models/user_model.dart';

class DrawService {
  final _firestore = FirebaseFirestore.instance;

  // ==================== DRAW NAMES ====================

  Future<Map<String, String>> drawNames({
    required String groupId,
    required List<String> memberIds,
  }) async {
    try {
      if (memberIds.length < 2) {
        throw 'Need at least 2 members to draw names';
      }

      // Check if names have already been drawn
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      if (groupDoc.exists && groupDoc.data()?['hasDrawn'] == true) {
        throw 'Names have already been drawn for this group';
      }

      // Generate matches
      final matches = _generateSecretSantaMatches(memberIds);

      // Save matches to Firestore
      await _saveMatchesToFirestore(groupId, matches);

      // Update group status
      await _firestore.collection('groups').doc(groupId).update({
        'hasDrawn': true,
        'drawnAt': FieldValue.serverTimestamp(),
      });

      return matches;
    } catch (e) {
      throw 'Error drawing names: $e';
    }
  }

  // ==================== GENERATE MATCHES ====================

  Map<String, String> _generateSecretSantaMatches(List<String> memberIds) {
    final Map<String, String> matches = {};
    final List<String> givers = List.from(memberIds);
    final List<String> receivers = List.from(memberIds);

    // Shuffle receivers to randomize
    receivers.shuffle(Random());

    // Ensure no one gets themselves
    bool hasValidMatches = false;
    int attempts = 0;
    const maxAttempts = 100;

    while (!hasValidMatches && attempts < maxAttempts) {
      hasValidMatches = true;
      
      for (int i = 0; i < givers.length; i++) {
        if (givers[i] == receivers[i]) {
          hasValidMatches = false;
          
          // Try to swap with next person
          final swapIndex = (i + 1) % receivers.length;
          
          // Make sure the swap doesn't create another self-match
          if (givers[swapIndex] != receivers[i] && givers[i] != receivers[swapIndex]) {
            final temp = receivers[i];
            receivers[i] = receivers[swapIndex];
            receivers[swapIndex] = temp;
          } else {
            // If simple swap doesn't work, reshuffle and try again
            receivers.shuffle(Random());
            break;
          }
        }
      }
      
      attempts++;
    }

    if (!hasValidMatches) {
      throw 'Could not generate valid matches after $maxAttempts attempts';
    }

    // Create the matches map
    for (int i = 0; i < givers.length; i++) {
      matches[givers[i]] = receivers[i];
    }

    return matches;
  }

  // ==================== SAVE MATCHES ====================

  Future<void> _saveMatchesToFirestore(
    String groupId,
    Map<String, String> matches,
  ) async {
    try {
      final batch = _firestore.batch();

      matches.forEach((giverId, receiverId) {
        final matchRef = _firestore.collection('matches').doc();
        batch.set(matchRef, {
          'matchId': matchRef.id,
          'groupId': groupId,
          'giverId': giverId,
          'receiverId': receiverId,
          'createdAt': FieldValue.serverTimestamp(),
          'hasRevealed': false,
        });
      });

      await batch.commit();
    } catch (e) {
      throw 'Error saving matches: $e';
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

      // Get receiver's user data
      final userDoc = await _firestore.collection('users').doc(receiverId).get();
      
      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data()!);
      }

      return null;
    } catch (e) {
      throw 'Error getting user match: $e';
    }
  }

  // ==================== CHECK IF USER HAS MATCH ====================

  Future<bool> userHasMatch(String groupId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('matches')
          .where('groupId', isEqualTo: groupId)
          .where('giverId', isEqualTo: userId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw 'Error checking user match: $e';
    }
  }

  // ==================== GET ALL MATCHES FOR GROUP ====================

  Future<List<Map<String, dynamic>>> getGroupMatches(String groupId) async {
    try {
      final querySnapshot = await _firestore
          .collection('matches')
          .where('groupId', isEqualTo: groupId)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw 'Error getting group matches: $e';
    }
  }

  // ==================== REVEAL MATCH ====================

  Future<void> revealMatch(String groupId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('matches')
          .where('groupId', isEqualTo: groupId)
          .where('giverId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update({
          'hasRevealed': true,
          'revealedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw 'Error revealing match: $e';
    }
  }

  // ==================== DELETE MATCHES ====================

  Future<void> deleteGroupMatches(String groupId) async {
    try {
      final querySnapshot = await _firestore
          .collection('matches')
          .where('groupId', isEqualTo: groupId)
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Update group status
      await _firestore.collection('groups').doc(groupId).update({
        'hasDrawn': false,
        'drawnAt': null,
      });
    } catch (e) {
      throw 'Error deleting matches: $e';
    }
  }

  // ==================== REDRAW NAMES ====================

  Future<Map<String, String>> redrawNames({
    required String groupId,
    required List<String> memberIds,
  }) async {
    try {
      // Delete existing matches
      await deleteGroupMatches(groupId);

      // Draw new matches
      return await drawNames(groupId: groupId, memberIds: memberIds);
    } catch (e) {
      throw 'Error redrawing names: $e';
    }
  }

  // ==================== VALIDATE MATCHES ====================

  bool validateMatches(Map<String, String> matches) {
    // Check that no one is matched with themselves
    for (var entry in matches.entries) {
      if (entry.key == entry.value) {
        return false;
      }
    }

    // Check that all givers have exactly one receiver
    final givers = matches.keys.toSet();
    final receivers = matches.values.toSet();

    if (givers.length != receivers.length) {
      return false;
    }

    // Check that everyone who gives also receives
    if (!givers.containsAll(receivers) || !receivers.containsAll(givers)) {
      return false;
    }

    return true;
  }

  // ==================== GET MATCH STATISTICS ====================

  Future<Map<String, dynamic>> getMatchStatistics(String groupId) async {
    try {
      final matches = await getGroupMatches(groupId);
      
      final totalMatches = matches.length;
      final revealedMatches = matches.where((m) => m['hasRevealed'] == true).length;
      final unrevealedMatches = totalMatches - revealedMatches;

      return {
        'totalMatches': totalMatches,
        'revealedMatches': revealedMatches,
        'unrevealedMatches': unrevealedMatches,
        'revealPercentage': totalMatches > 0 
            ? (revealedMatches / totalMatches * 100).toStringAsFixed(1)
            : '0.0',
      };
    } catch (e) {
      throw 'Error getting match statistics: $e';
    }
  }

  // ==================== STREAM METHODS ====================

  Stream<UserModel?> streamUserMatch(String groupId, String userId) {
    return _firestore
        .collection('matches')
        .where('groupId', isEqualTo: groupId)
        .where('giverId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        return null;
      }

      final matchData = snapshot.docs.first.data();
      final receiverId = matchData['receiverId'];

      final userDoc = await _firestore.collection('users').doc(receiverId).get();
      
      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data()!);
      }

      return null;
    });
  }

  Stream<List<Map<String, dynamic>>> streamGroupMatches(String groupId) {
    return _firestore
        .collection('matches')
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
