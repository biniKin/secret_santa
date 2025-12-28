import 'package:equatable/equatable.dart';

abstract class GroupInfoEvent extends Equatable {
  const GroupInfoEvent();

  @override
  List<Object?> get props => [];
}

// Load Group Details Event
class LoadGroupDetailsEvent extends GroupInfoEvent {
  final String groupId;

  const LoadGroupDetailsEvent({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

// Draw Names Event
class DrawNamesEvent extends GroupInfoEvent {
  final String groupId;
  final List<String> memberIds;
  final String groupName;

  const DrawNamesEvent({
    required this.groupId,
    required this.memberIds,
    required this.groupName,
  });

  @override
  List<Object?> get props => [groupId, memberIds, groupName];
}

// Get User Match Event
class GetUserMatchEvent extends GroupInfoEvent {
  final String groupId;
  final String userId;

  const GetUserMatchEvent({required this.groupId, required this.userId});

  @override
  List<Object?> get props => [groupId, userId];
}

// Leave Group Event
class LeaveGroupEvent extends GroupInfoEvent {
  final String groupId;
  final String userId;

  const LeaveGroupEvent({required this.groupId, required this.userId});

  @override
  List<Object?> get props => [groupId, userId];
}

// Delete Group Event
class DeleteGroupEvent extends GroupInfoEvent {
  final String groupId;

  const DeleteGroupEvent({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

// Refresh Group Event
class RefreshGroupEvent extends GroupInfoEvent {
  final String groupId;

  const RefreshGroupEvent({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}
