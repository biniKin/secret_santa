import 'package:equatable/equatable.dart';

abstract class JoinGroupEvent extends Equatable {
  const JoinGroupEvent();

  @override
  List<Object?> get props => [];
}

// Join Group Event
class JoinGroupSubmitEvent extends JoinGroupEvent {
  final String groupCode;
  final String userId;

  const JoinGroupSubmitEvent({
    required this.groupCode,
    required this.userId,
  });

  @override
  List<Object?> get props => [groupCode, userId];
}

// Reset Join Group State
class ResetJoinGroupEvent extends JoinGroupEvent {
  const ResetJoinGroupEvent();
}
