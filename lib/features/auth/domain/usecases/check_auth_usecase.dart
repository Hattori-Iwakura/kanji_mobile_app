import '../repositories/auth_repository.dart';

class CheckAuthUseCase {
  final AuthRepository repository;

  CheckAuthUseCase(this.repository);

  Future<bool> call() async {
    await repository.initAuth();
    return await repository.isLoggedIn();
  }
}
