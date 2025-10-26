import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/user_management_repository.dart';
import 'user_management_event.dart';
import 'user_management_state.dart';

class UserManagementBloc
    extends Bloc<UserManagementEvent, UserManagementState> {
  final UserManagementRepository repository;

  UserManagementBloc({required this.repository})
    : super(const UserManagementInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<LoadUserDetail>(_onLoadUserDetail);
    on<UpdateUser>(_onUpdateUser);
    on<DeleteUser>(_onDeleteUser);
    on<RefreshUsers>(_onRefreshUsers);
  }

  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(const UserManagementLoading());

    final result = await repository.getAllUsers(
      page: event.page,
      limit: event.limit,
      search: event.search,
      role: event.role,
      status: event.status,
    );

    result.fold(
      (failure) => emit(UserManagementError(failure.message)),
      (users) => emit(
        UsersLoaded(
          users: users,
          currentPage: event.page,
          hasMore: users.length >= (event.limit ?? 20),
        ),
      ),
    );
  }

  Future<void> _onLoadUserDetail(
    LoadUserDetail event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(const UserManagementLoading());

    final result = await repository.getUserById(event.userId);

    result.fold(
      (failure) => emit(UserManagementError(failure.message)),
      (user) => emit(UserDetailLoaded(user)),
    );
  }

  Future<void> _onUpdateUser(
    UpdateUser event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(const UserManagementLoading());

    final result = await repository.updateUser(event.userId, event.dto);

    result.fold(
      (failure) => emit(UserManagementError(failure.message)),
      (user) => emit(UserUpdated(user: user)),
    );
  }

  Future<void> _onDeleteUser(
    DeleteUser event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(const UserManagementLoading());

    final result = await repository.deleteUser(event.userId);

    result.fold(
      (failure) => emit(UserManagementError(failure.message)),
      (_) => emit(UserDeleted(userId: event.userId)),
    );
  }

  Future<void> _onRefreshUsers(
    RefreshUsers event,
    Emitter<UserManagementState> emit,
  ) async {
    // Reload users with default parameters
    add(const LoadUsers(limit: 20));
  }
}
