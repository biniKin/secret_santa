import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secrete_santa/services/draw_service.dart';
import 'package:secrete_santa/services/group_service.dart';
import 'package:secrete_santa/ui/group_info_page/group_info_bloc/group_info_event.dart';
import 'package:secrete_santa/ui/group_info_page/group_info_bloc/group_info_state.dart';

class GroupInfoBloc extends Bloc<GroupInfoEvent, GroupInfoState> {
  final GroupService _groupService;
  final DrawService _drawService;

  GroupInfoBloc({
    GroupService? groupService,
    DrawService? drawService,
  })  : _groupService = groupService ?? GroupService(),
        _drawService = drawService ?? DrawService(),
        super(const GroupInfoInitial()) {
    on<LoadGroupDetailsEvent>(_onLoadGroupDetails);
    on<DrawNamesEvent>(_onDrawNames);
    on<GetUserMatchEvent>(_onGetUserMatch);
    on<LeaveGroupEvent>(_onLeaveGroup);
    on<DeleteGroupEvent>(_onDeleteGroup);
    on<RefreshGroupEvent>(_onRefreshGroup);
  }

  Future<void> _onLoadGroupDetails(
    LoadGroupDetailsEvent event,
    Emitter<GroupInfoState> emit,
  ) async {
    emit(const GroupInfoLoading());

    try {
      final groupData = await _groupService.fetchGroupById(event.groupId);

      if (groupData == null) {
        emit(const GroupInfoError(message: 'Group not found'));
        return;
      }

      final members = await _groupService.getGroupMembers(event.groupId);

      emit(GroupInfoLoaded(groupData: groupData, members: members));
    } catch (e) {
      emit(GroupInfoError(message: e.toString()));
    }
  }

  Future<void> _onDrawNames(
    DrawNamesEvent event,
    Emitter<GroupInfoState> emit,
  ) async {
    emit(const GroupInfoLoading());

    try {
      await _drawService.drawNames(
        groupId: event.groupId,
        memberIds: event.memberIds,
      );

      emit(const NamesDrawnSuccess(
        message: 'Names have been drawn successfully! Members can now view their matches.',
      ));

      // Reload group details
      add(LoadGroupDetailsEvent(groupId: event.groupId));
    } catch (e) {
      emit(GroupInfoError(message: e.toString()));
    }
  }

  Future<void> _onGetUserMatch(
    GetUserMatchEvent event,
    Emitter<GroupInfoState> emit,
  ) async {
    emit(const GroupInfoLoading());

    try {
      final match = await _drawService.getUserMatch(
        event.groupId,
        event.userId,
      );

      if (match != null) {
        emit(UserMatchLoaded(match: match));
      } else {
        emit(const NoMatchFound());
      }
    } catch (e) {
      emit(GroupInfoError(message: e.toString()));
    }
  }

  Future<void> _onLeaveGroup(
    LeaveGroupEvent event,
    Emitter<GroupInfoState> emit,
  ) async {
    emit(const GroupInfoLoading());

    try {
      await _groupService.leaveGroup(event.groupId, event.userId);
      emit(const GroupLeftSuccess());
    } catch (e) {
      emit(GroupInfoError(message: e.toString()));
    }
  }

  Future<void> _onDeleteGroup(
    DeleteGroupEvent event,
    Emitter<GroupInfoState> emit,
  ) async {
    emit(const GroupInfoLoading());

    try {
      await _groupService.deleteGroup(event.groupId);
      emit(const GroupDeletedSuccess());
    } catch (e) {
      emit(GroupInfoError(message: e.toString()));
    }
  }

  Future<void> _onRefreshGroup(
    RefreshGroupEvent event,
    Emitter<GroupInfoState> emit,
  ) async {
    // Don't show loading for refresh
    try {
      final groupData = await _groupService.fetchGroupById(event.groupId);

      if (groupData == null) {
        emit(const GroupInfoError(message: 'Group not found'));
        return;
      }

      final members = await _groupService.getGroupMembers(event.groupId);

      emit(GroupInfoLoaded(groupData: groupData, members: members));
    } catch (e) {
      emit(GroupInfoError(message: e.toString()));
    }
  }
}
