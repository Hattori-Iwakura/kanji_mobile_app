import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({required String email, required String password});
  Future<UserEntity> register({
    required String email,
    required String username,
    required String password,
  });
  Future<UserEntity> getProfile();
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<void> initAuth();
}
