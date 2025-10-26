import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class UserManagementState extends Equatable {
  const UserManagementState();

  @override
  List<Object?> get props => [];
}

class UserManagementInitial extends UserManagementState {
  const UserManagementInitial();
}

class UserManagementLoading extends UserManagementState {
  const UserManagementLoading();
}

class UsersLoaded extends UserManagementState {
  final List<User> users;
  final int? currentPage;
  final bool hasMore;

  const UsersLoaded({
    required this.users,
    this.currentPage,
    this.hasMore = true,
  });

  @override
  List<Object?> get props => [users, currentPage, hasMore];
}

class UserDetailLoaded extends UserManagementState {
  final User user;

  const UserDetailLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserUpdated extends UserManagementState {
  final User user;
  final String message;

  const UserUpdated({
    required this.user,
    this.message = 'User updated successfully',
  });

  @override
  List<Object?> get props => [user, message];
}

class UserDeleted extends UserManagementState {
  final int userId;
  final String message;

  const UserDeleted({
    required this.userId,
    this.message = 'User deleted successfully',
  });

  @override
  List<Object?> get props => [userId, message];
}

class UserManagementError extends UserManagementState {
  final String message;

  const UserManagementError(this.message);

  @override
  List<Object?> get props => [message];
}
