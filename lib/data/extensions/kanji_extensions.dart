import 'package:drift/drift.dart';
import '../../domain/entities/kanji_entity.dart';
import '../datasources/kanji_local_database.dart';

extension KanjiExtensions on Kanji {
  KanjiTableCompanion toCompanion() {
    return KanjiTableCompanion(
      id: Value(id),
      character: Value(character),
      meanings: Value(meanings),
      onyomi: Value(onyomi),
      kunyomi: Value(kunyomi),
      strokeCount: Value(strokeCount),
      jlpt: Value(jlpt),
      grade: Value(grade),
      frequency: Value(frequency),
      radicals: Value(radicals),
    );
  }

  KanjiTableCompanion toInsertCompanion() {
    return KanjiTableCompanion.insert(
      character: character,
      meanings: meanings,
      onyomi: Value(onyomi),
      kunyomi: Value(kunyomi),
      strokeCount: Value(strokeCount),
      jlpt: Value(jlpt),
      grade: Value(grade),
      frequency: Value(frequency),
      radicals: Value(radicals),
    );
  }

  KanjiTableData toTableData() {
    return KanjiTableData(
      id: id,
      character: character,
      meanings: meanings,
      onyomi: onyomi,
      kunyomi: kunyomi,
      strokeCount: strokeCount,
      jlpt: jlpt,
      grade: grade,
      frequency: frequency,
      radicals: radicals,
      isSynced: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

extension KanjiTableDataExtensions on KanjiTableData {
  Kanji toEntity() {
    return Kanji(
      id: id,
      character: character,
      meanings: meanings,
      onyomi: onyomi,
      kunyomi: kunyomi,
      strokeCount: strokeCount,
      jlpt: jlpt,
      grade: grade,
      frequency: frequency,
      radicals: radicals,
    );
  }
}

extension KanjiListExtensions on List<KanjiTableData> {
  List<Kanji> toEntityList() {
    return map((data) => data.toEntity()).toList();
  }
}
