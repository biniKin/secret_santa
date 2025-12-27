import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

// Initial State
class HomeInitial extends HomeState {
  const HomeInitial();
}

// Loading State
class HomeLoading extends HomeState {
  const HomeLoading();
}

// Groups Loaded State
class HomeGroupsLoaded extends HomeState {
  final List<Map<String, dynamic>> groups;

  const HomeGroupsLoaded({required this.groups});

  @override
  List<Object?> get props => [groups];
}

// Empty State (No Groups)
class HomeEmpty extends HomeState {
  const HomeEmpty();
}

// Error State
class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
