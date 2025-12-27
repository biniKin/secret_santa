import 'package:equatable/equatable.dart';

abstract class CreateGroupState extends Equatable {
  const CreateGroupState();

  @override
  List<Object?> get props => [];
}

// Initial State
class CreateGroupInitial extends CreateGroupState {
  const CreateGroupInitial();
}

// Loading State
class CreateGroupLoading extends CreateGroupState {
  const CreateGroupLoading();
}

// Success State
class CreateGroupSuccess extends CreateGroupState {
  final String groupId;
  final String groupCode;

  const CreateGroupSuccess({
    required this.groupId,
    required this.groupCode,
  });

  @override
  List<Object?> get props => [groupId, groupCode];
}

// Error State
class CreateGroupError extends CreateGroupState {
  final String message;

  const CreateGroupError({required this.message});

  @override
  List<Object?> get props => [message];
}
