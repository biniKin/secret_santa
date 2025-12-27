import 'package:equatable/equatable.dart';

abstract class JoinGroupState extends Equatable {
  const JoinGroupState();

  @override
  List<Object?> get props => [];
}

// Initial State
class JoinGroupInitial extends JoinGroupState {
  const JoinGroupInitial();
}

// Loading State
class JoinGroupLoading extends JoinGroupState {
  const JoinGroupLoading();
}

// Success State
class JoinGroupSuccess extends JoinGroupState {
  final String groupId;
  final String groupName;

  const JoinGroupSuccess({
    required this.groupId,
    required this.groupName,
  });

  @override
  List<Object?> get props => [groupId, groupName];
}

// Error State
class JoinGroupError extends JoinGroupState {
  final String message;

  const JoinGroupError({required this.message});

  @override
  List<Object?> get props => [message];
}
