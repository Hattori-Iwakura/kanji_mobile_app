import 'package:equatable/equatable.dart';
import '../../domain/entities/update_user_dto.dart';

abstract class UserManagementEvent extends Equatable {
  const UserManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsers extends UserManagementEvent {
  final int? page;
  final int? limit;
  final String? search;
  final String? role;
  final String? status;

  const LoadUsers({this.page, this.limit, this.search, this.role, this.status});

  @override
  List<Object?> get props => [page, limit, search, role, status];
}

class LoadUserDetail extends UserManagementEvent {
  final int userId;

  const LoadUserDetail(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateUser extends UserManagementEvent {
  final int userId;
  final UpdateUserDto dto;

  const UpdateUser({required this.userId, required this.dto});

  @override
  List<Object?> get props => [userId, dto];
}

class DeleteUser extends UserManagementEvent {
  final int userId;

  const DeleteUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RefreshUsers extends UserManagementEvent {
  const RefreshUsers();
}
