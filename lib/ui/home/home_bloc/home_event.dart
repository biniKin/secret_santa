import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

// Load User Groups Event
class LoadUserGroupsEvent extends HomeEvent {
  final String userId;

  const LoadUserGroupsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// Refresh Groups Event
class RefreshGroupsEvent extends HomeEvent {
  final String userId;

  const RefreshGroupsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}
