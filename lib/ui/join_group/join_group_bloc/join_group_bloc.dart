import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secrete_santa/services/group_service.dart';
import 'package:secrete_santa/services/notification_service.dart';
import 'package:secrete_santa/ui/join_group/join_group_bloc/join_group_event.dart';
import 'package:secrete_santa/ui/join_group/join_group_bloc/join_group_state.dart';

class JoinGroupBloc extends Bloc<JoinGroupEvent, JoinGroupState> {
  final GroupService _groupService;
  final NotificationService _notificationService;

  JoinGroupBloc({
    GroupService? groupService,
    NotificationService? notificationService,
  }) : _groupService = groupService ?? GroupService(),
       _notificationService = notificationService ?? NotificationService(),
       super(const JoinGroupInitial()) {
    on<JoinGroupSubmitEvent>(_onJoinGroup);
    on<ResetJoinGroupEvent>(_onResetJoinGroup);
  }

  Future<void> _onJoinGroup(
    JoinGroupSubmitEvent event,
    Emitter<JoinGroupState> emit,
  ) async {
    emit(const JoinGroupLoading());

    try {
      await _groupService.joinGroupWithCode(
        groupCode: event.groupCode,
        userId: event.userId,
      );

      // Fetch the group details
      final groupData = await _groupService.fetchGroupByCode(event.groupCode);

      if (groupData != null) {
        // Schedule exchange date reminder notification
        final exchangeDate = (groupData['exchangeDate'] as Timestamp?)
            ?.toDate();
        if (exchangeDate != null) {
          await _notificationService.scheduleExchangeDateReminder(
            groupId: groupData['groupId'],
            groupName: groupData['groupName'],
            exchangeDate: exchangeDate,
          );
        }

        emit(
          JoinGroupSuccess(
            groupId: groupData['groupId'],
            groupName: groupData['groupName'],
          ),
        );
      } else {
        emit(const JoinGroupError(message: 'Failed to retrieve group details'));
      }
    } catch (e) {
      emit(JoinGroupError(message: e.toString()));
    }
  }

  void _onResetJoinGroup(
    ResetJoinGroupEvent event,
    Emitter<JoinGroupState> emit,
  ) {
    emit(const JoinGroupInitial());
  }
}
