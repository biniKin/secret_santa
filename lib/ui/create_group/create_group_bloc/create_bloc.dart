import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secrete_santa/services/group_service.dart';
import 'package:secrete_santa/services/storage_service.dart';
import 'package:secrete_santa/ui/create_group/create_group_bloc/create_event.dart';
import 'package:secrete_santa/ui/create_group/create_group_bloc/create_state.dart';

class CreateGroupBloc extends Bloc<CreateGroupEvent, CreateGroupState> {
  final GroupService _groupService;
  final StorageService _storageService;

  CreateGroupBloc({
    GroupService? groupService,
    StorageService? storageService,
  })  : _groupService = groupService ?? GroupService(),
        _storageService = storageService ?? StorageService(),
        super(const CreateGroupInitial()) {
    on<CreateGroupSubmitEvent>(_onCreateGroup);
    on<ResetCreateGroupEvent>(_onResetCreateGroup);
  }

  Future<void> _onCreateGroup(
    CreateGroupSubmitEvent event,
    Emitter<CreateGroupState> emit,
  ) async {
    emit(const CreateGroupLoading());

    try {
      final groupId = await _groupService.createGroup(
        groupName: event.groupName,
        exchangeDate: event.exchangeDate,
        adminId: event.adminId,
        budget: event.budget,
      );

      // Fetch the group to get the group code
      final groupData = await _storageService.getGroupFromFirestore(groupId);
      
      if (groupData != null) {
        final groupCode = groupData['groupCode'] as String;
        emit(CreateGroupSuccess(groupId: groupId, groupCode: groupCode));
      } else {
        emit(const CreateGroupError(message: 'Group created but failed to retrieve details'));
      }
    } catch (e) {
      emit(CreateGroupError(message: e.toString()));
    }
  }

  void _onResetCreateGroup(
    ResetCreateGroupEvent event,
    Emitter<CreateGroupState> emit,
  ) {
    emit(const CreateGroupInitial());
  }
}
