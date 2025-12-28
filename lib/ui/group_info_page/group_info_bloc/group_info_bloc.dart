import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secrete_santa/services/draw_service.dart';
import 'package:secrete_santa/services/group_service.dart';
import 'package:secrete_santa/ui/group_info_page/group_info_bloc/group_info_event.dart';
import 'package:secrete_santa/ui/group_info_page/group_info_bloc/group_info_state.dart';

class GroupInfoBloc extends Bloc<GroupInfoEvent, GroupInfoState> {
  final GroupService _groupService;
  final DrawService _drawService;

  GroupInfoBloc({GroupService? groupService, DrawService? drawService})
    : _groupService = groupService ?? GroupService(),
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
      print('Loading group details for groupId: ${event.groupId}'); // Debug

      final groupData = await _groupService.fetchGroupById(event.groupId);
      print('Group data fetched: ${groupData != null}'); // Debug

      if (groupData == null) {
        print('Group data is null'); // Debug
        emit(const GroupInfoError(message: 'Group not found'));
        return;
      }

      print('Fetching group members...'); // Debug
      final members = await _groupService.getGroupMembers(event.groupId);
      print('Members fetched: ${members.length}'); // Debug

      emit(GroupInfoLoaded(groupData: groupData, members: members));
    } catch (e) {
      print('Error in _onLoadGroupDetails: $e'); // Debug
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
        groupName: event.groupName,
      );

      emit(
        const NamesDrawnSuccess(
          message:
              'Names have been drawn successfully! All members have been notified.',
        ),
      );

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
    // Don't emit loading state - keep the current group details visible
    try {
      final match = await _drawService.getUserMatch(
        event.groupId,
        event.userId,
      );

      if (match != null) {
        print("match is not null: ${match}");
        emit(UserMatchLoaded(match: match));
      } else {
        print("match is null");
        emit(const NoMatchFound());
      }
    } catch (e) {
      print("error on match bloc: ${e.toString()}");
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
