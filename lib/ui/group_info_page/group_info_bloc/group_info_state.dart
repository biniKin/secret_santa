import 'package:equatable/equatable.dart';
import 'package:secrete_santa/models/user_model.dart';

abstract class GroupInfoState extends Equatable {
  const GroupInfoState();

  @override
  List<Object?> get props => [];
}

// Initial State
class GroupInfoInitial extends GroupInfoState {
  const GroupInfoInitial();
}

// Loading State
class GroupInfoLoading extends GroupInfoState {
  const GroupInfoLoading();
}

// Group Details Loaded State
class GroupInfoLoaded extends GroupInfoState {
  final Map<String, dynamic> groupData;
  final List<UserModel> members;

  const GroupInfoLoaded({
    required this.groupData,
    required this.members,
  });

  @override
  List<Object?> get props => [groupData, members];
}

// Names Drawn Success State
class NamesDrawnSuccess extends GroupInfoState {
  final String message;

  const NamesDrawnSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

// User Match Loaded State
class UserMatchLoaded extends GroupInfoState {
  final UserModel match;

  const UserMatchLoaded({required this.match});

  @override
  List<Object?> get props => [match];
}

// No Match Found State
class NoMatchFound extends GroupInfoState {
  const NoMatchFound();
}

// Group Left Success State
class GroupLeftSuccess extends GroupInfoState {
  const GroupLeftSuccess();
}

// Group Deleted Success State
class GroupDeletedSuccess extends GroupInfoState {
  const GroupDeletedSuccess();
}

// Error State
class GroupInfoError extends GroupInfoState {
  final String message;

  const GroupInfoError({required this.message});

  @override
  List<Object?> get props => [message];
}
