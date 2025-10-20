import 'package:equatable/equatable.dart';

class KanjiListEntity extends Equatable {
  final int id;
  final String name;
  final String? description;
  final int userId;
  final bool isPublic;
  final int totalKanji;
  final DateTime createAt;
  final DateTime updateAt;

  const KanjiListEntity({
    required this.id,
    required this.name,
    this.description,
    required this.userId,
    required this.isPublic,
    required this.totalKanji,
    required this.createAt,
    required this.updateAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    userId,
    isPublic,
    totalKanji,
    createAt,
    updateAt,
  ];
}
