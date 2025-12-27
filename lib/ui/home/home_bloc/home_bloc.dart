import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secrete_santa/services/group_service.dart';
import 'package:secrete_santa/ui/home/home_bloc/home_event.dart';
import 'package:secrete_santa/ui/home/home_bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GroupService _groupService;

  HomeBloc({
    GroupService? groupService,
  })  : _groupService = groupService ?? GroupService(),
        super(const HomeInitial()) {
    on<LoadUserGroupsEvent>(_onLoadUserGroups);
    on<RefreshGroupsEvent>(_onRefreshGroups);
  }

  Future<void> _onLoadUserGroups(
    LoadUserGroupsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    try {
      final groups = await _groupService.fetchUserGroups(event.userId);

      if (groups.isEmpty) {
        emit(const HomeEmpty());
      } else {
        emit(HomeGroupsLoaded(groups: groups));
      }
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onRefreshGroups(
    RefreshGroupsEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Don't show loading for refresh
    try {
      final groups = await _groupService.fetchUserGroups(event.userId);

      if (groups.isEmpty) {
        emit(const HomeEmpty());
      } else {
        emit(HomeGroupsLoaded(groups: groups));
      }
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}
