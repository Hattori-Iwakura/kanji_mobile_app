import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../kanji_list/domain/entities/category_entity.dart';
import '../../../kanji_list/domain/usecases/create_category_usecase.dart';
import '../../../kanji_list/domain/usecases/delete_category_usecase.dart';
import '../../../kanji_list/domain/usecases/get_all_categories_usecase.dart';
import '../../../kanji_list/domain/usecases/update_category_usecase.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetAllCategoriesUseCase getAllCategoriesUseCase;
  final CreateCategoryUseCase createCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;

  CategoryBloc({
    required this.getAllCategoriesUseCase,
    required this.createCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
  }) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<CreateCategory>(_onCreateCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await getAllCategoriesUseCase();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onCreateCategory(
    CreateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      await createCategoryUseCase(
        name: event.name,
        description: event.description,
      );
      emit(const CategoryOperationSuccess('Category created successfully'));
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      await updateCategoryUseCase(
        id: event.id,
        name: event.name,
        description: event.description,
      );
      emit(const CategoryOperationSuccess('Category updated successfully'));
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      await deleteCategoryUseCase(event.id);
      emit(const CategoryOperationSuccess('Category deleted successfully'));
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
