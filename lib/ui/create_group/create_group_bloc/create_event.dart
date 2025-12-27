import 'package:equatable/equatable.dart';

abstract class CreateGroupEvent extends Equatable {
  const CreateGroupEvent();

  @override
  List<Object?> get props => [];
}

// Create Group Event
class CreateGroupSubmitEvent extends CreateGroupEvent {
  final String groupName;
  final DateTime exchangeDate;
  final String adminId;
  final String? budget;

  const CreateGroupSubmitEvent({
    required this.groupName,
    required this.exchangeDate,
    required this.adminId,
    this.budget,
  });

  @override
  List<Object?> get props => [groupName, exchangeDate, adminId, budget];
}

// Reset Create Group State
class ResetCreateGroupEvent extends CreateGroupEvent {
  const ResetCreateGroupEvent();
}
