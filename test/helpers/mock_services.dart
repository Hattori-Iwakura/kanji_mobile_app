/// Mock services for testing
library;

import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Kanji
import 'package:kanji_mobile_v1/features/kanji/domain/repositories/kanji_repository.dart';
import 'package:kanji_mobile_v1/features/kanji/data/datasources/kanji_remote_datasource.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/usecases/get_all_kanji.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/usecases/get_kanji_by_id.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/usecases/search_kanji.dart';

// Kanji List
import 'package:kanji_mobile_v1/features/kanji_list/domain/repositories/kanji_list_repository.dart';

// Quiz
import 'package:kanji_mobile_v1/features/quiz/domain/repositories/quiz_repository.dart';

// Auth
import 'package:kanji_mobile_v1/features/auth/domain/repositories/auth_repository.dart';

// Flashcard
import 'package:kanji_mobile_v1/features/flashcard/domain/repositories/flashcard_repository.dart';

// Generate mocks for repositories and services
@GenerateMocks([
  // External dependencies
  Dio,
  FlutterSecureStorage,
  SharedPreferences,

  // Kanji
  KanjiRepository,
  KanjiRemoteDataSource,
  GetAllKanji,
  GetKanjiById,
  SearchKanji,

  // Kanji List
  KanjiListRepository,

  // Quiz
  QuizRepository,

  // Auth
  AuthRepository,

  // Flashcard
  FlashcardRepository,
])
void main() {}
