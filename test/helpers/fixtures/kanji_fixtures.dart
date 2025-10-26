/// Kanji test fixtures for testing
library;

import 'package:kanji_mobile_v1/features/kanji/domain/entities/kanji.dart';

// Test Kanji entities
final tKanji1 = Kanji(
  id: 1,
  character: '日',
  onyomi: 'ニチ、ジツ',
  kunyomi: 'ひ、か',
  meanings: 'sun, day',
  strokeCount: 4,
  jlpt: 5,
  grade: 1,
  frequency: 1,
  createdAt: DateTime.utc(2024, 1, 1),
  updatedAt: DateTime.utc(2024, 1, 1),
);

final tKanji2 = Kanji(
  id: 2,
  character: '月',
  onyomi: 'ゲツ、ガツ',
  kunyomi: 'つき',
  meanings: 'moon, month',
  strokeCount: 4,
  jlpt: 5,
  grade: 1,
  frequency: 2,
  createdAt: DateTime.utc(2024, 1, 1),
  updatedAt: DateTime.utc(2024, 1, 1),
);

final tKanji3 = Kanji(
  id: 3,
  character: '火',
  onyomi: 'カ',
  kunyomi: 'ひ、ほ',
  meanings: 'fire',
  strokeCount: 4,
  jlpt: 5,
  grade: 1,
  frequency: 3,
  createdAt: DateTime.utc(2024, 1, 1),
  updatedAt: DateTime.utc(2024, 1, 1),
);

final tKanji4 = Kanji(
  id: 4,
  character: '水',
  onyomi: 'スイ',
  kunyomi: 'みず',
  meanings: 'water',
  strokeCount: 4,
  jlpt: 5,
  grade: 1,
  frequency: 4,
  createdAt: DateTime.utc(2024, 1, 1),
  updatedAt: DateTime.utc(2024, 1, 1),
);

final tKanji5 = Kanji(
  id: 5,
  character: '木',
  onyomi: 'モク、ボク',
  kunyomi: 'き、こ',
  meanings: 'tree, wood',
  strokeCount: 4,
  jlpt: 5,
  grade: 1,
  frequency: 5,
  createdAt: DateTime.utc(2024, 1, 1),
  updatedAt: DateTime.utc(2024, 1, 1),
);

// JLPT N4 Kanji
final tKanjiN4 = Kanji(
  id: 100,
  character: '建',
  onyomi: 'ケン、コン',
  kunyomi: 'た.てる、た.つ',
  meanings: 'build, construct',
  strokeCount: 9,
  jlpt: 4,
  grade: 4,
  frequency: 100,
  createdAt: DateTime.utc(2024, 1, 1),
  updatedAt: DateTime.utc(2024, 1, 1),
);

// JLPT N3 Kanji
final tKanjiN3 = Kanji(
  id: 200,
  character: '優',
  onyomi: 'ユウ、ウ',
  kunyomi: 'やさ.しい、すぐ.れる',
  meanings: 'tenderness, excel, surpass',
  strokeCount: 17,
  jlpt: 3,
  grade: 6,
  frequency: 200,
  createdAt: DateTime.utc(2024, 1, 1),
  updatedAt: DateTime.utc(2024, 1, 1),
);

// Kanji without optional fields
final tKanjiMinimal = Kanji(
  id: 999,
  character: '漢',
  meanings: 'Sino-, China',
  createdAt: DateTime.utc(2024, 1, 1),
  updatedAt: DateTime.utc(2024, 1, 1),
);

// List of test kanji
final tKanjiList = [tKanji1, tKanji2, tKanji3, tKanji4, tKanji5];

final tKanjiN5List = [tKanji1, tKanji2, tKanji3, tKanji4, tKanji5];

final tKanjiMixedJlptList = [tKanji1, tKanjiN4, tKanjiN3];

// Kanji JSON responses
final tKanjiJson = {
  'id': 1,
  'character': '日',
  'onyomi': 'ニチ、ジツ',
  'kunyomi': 'ひ、か',
  'meanings': 'sun, day',
  'strokeCount': 4,
  'jlpt': 5,
  'grade': 1,
  'frequency': 1,
  'createdAt': '2024-01-01T00:00:00.000Z',
  'updatedAt': '2024-01-01T00:00:00.000Z',
};

// Individual JSON fixtures for E2E testing
final tKanjiJson1 = tKanjiJson;

final tKanjiJson2 = {
  'id': 2,
  'character': '月',
  'onyomi': 'ゲツ、ガツ',
  'kunyomi': 'つき',
  'meanings': 'moon, month',
  'strokeCount': 4,
  'jlpt': 5,
  'grade': 1,
  'frequency': 2,
  'createdAt': '2024-01-01T00:00:00.000Z',
  'updatedAt': '2024-01-01T00:00:00.000Z',
};

final tKanjiJson3 = {
  'id': 3,
  'character': '火',
  'onyomi': 'カ',
  'kunyomi': 'ひ',
  'meanings': 'fire',
  'strokeCount': 4,
  'jlpt': 5,
  'grade': 1,
  'frequency': 3,
  'createdAt': '2024-01-01T00:00:00.000Z',
  'updatedAt': '2024-01-01T00:00:00.000Z',
};

final tKanjiListJson = [
  {
    'id': 1,
    'character': '日',
    'onyomi': 'ニチ、ジツ',
    'kunyomi': 'ひ、か',
    'meanings': 'sun, day',
    'strokeCount': 4,
    'jlpt': 5,
    'grade': 1,
    'frequency': 1,
    'createdAt': '2024-01-01T00:00:00.000Z',
    'updatedAt': '2024-01-01T00:00:00.000Z',
  },
  {
    'id': 2,
    'character': '月',
    'onyomi': 'ゲツ、ガツ',
    'kunyomi': 'つき',
    'meanings': 'moon, month',
    'strokeCount': 4,
    'jlpt': 5,
    'grade': 1,
    'frequency': 2,
    'createdAt': '2024-01-01T00:00:00.000Z',
    'updatedAt': '2024-01-01T00:00:00.000Z',
  },
  {
    'id': 3,
    'character': '火',
    'onyomi': 'カ',
    'kunyomi': 'ひ、ほ',
    'meanings': 'fire',
    'strokeCount': 4,
    'jlpt': 5,
    'grade': 1,
    'frequency': 3,
    'createdAt': '2024-01-01T00:00:00.000Z',
    'updatedAt': '2024-01-01T00:00:00.000Z',
  },
];

// Search query fixtures
const tSearchQuery = '水';
const tSearchQueryMeanings = 'water';
const tSearchQueryJlpt = 5;
const tSearchQueryGrade = 1;
const tSearchQueryStrokeCount = 4;

// Pagination fixtures
const tLimit = 20;
const tOffset = 0;
const tPage = 1;

// Empty results
final tEmptyKanjiList = <Kanji>[];
final tEmptyKanjiListJson = <Map<String, dynamic>>[];

// Error messages
const tKanjiNotFoundError = 'Kanji not found';
const tNetworkError = 'Network error occurred';
const tServerError = 'Server error occurred';
const tInvalidCharacterError = 'Invalid kanji character';
