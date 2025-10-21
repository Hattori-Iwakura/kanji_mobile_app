part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {}

class CreateCategory extends CategoryEvent {
  final String name;
  final String? description;

  const CreateCategory({required this.name, this.description});

  @override
  List<Object?> get props => [name, description];
}

class UpdateCategory extends CategoryEvent {
  final int id;
  final String? name;
  final String? description;

  const UpdateCategory({required this.id, this.name, this.description});

  @override
  List<Object?> get props => [id, name, description];
}

class DeleteCategory extends CategoryEvent {
  final int id;

  const DeleteCategory(this.id);

  @override
  List<Object> get props => [id];
}
