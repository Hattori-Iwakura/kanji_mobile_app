import '../repositories/category_repository.dart';

class DeleteCategoryUseCase {
  final CategoryRepository repository;

  DeleteCategoryUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deleteCategory(id);
  }
}
