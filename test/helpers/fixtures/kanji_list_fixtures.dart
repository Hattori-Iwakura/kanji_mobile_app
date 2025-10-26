/// KanjiList test fixtures for testing
library;

import 'package:kanji_mobile_v1/features/kanji_list/domain/entities/kanji_list.dart';
import 'kanji_fixtures.dart';

// Test KanjiListItem entities
final tKanjiListItem1 = KanjiListItem(
  id: 1,
  listId: 1,
  kanjiId: 1,
  order: 0,
  kanji: tKanji1,
);

final tKanjiListItem2 = KanjiListItem(
  id: 2,
  listId: 1,
  kanjiId: 2,
  order: 1,
  kanji: tKanji2,
);

final tKanjiListItem3 = KanjiListItem(
  id: 3,
  listId: 1,
  kanjiId: 3,
  order: 2,
  kanji: tKanji3,
);

final tKanjiListItem4 = KanjiListItem(
  id: 4,
  listId: 2,
  kanjiId: 4,
  order: 0,
  kanji: tKanji4,
);

final tKanjiListItem5 = KanjiListItem(
  id: 5,
  listId: 2,
  kanjiId: 5,
  order: 1,
  kanji: tKanji5,
);

// Test KanjiList entities
final tKanjiList1 = KanjiList(
  id: 1,
  name: 'JLPT N5 Basics',
  description: 'Essential kanji for JLPT N5',
  userId: 1,
  isPublic: true,
  createdAt: DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 1),
  items: [tKanjiListItem1, tKanjiListItem2, tKanjiListItem3],
  userName: 'Test User',
  userEmail: 'test@example.com',
);

final tKanjiList2 = KanjiList(
  id: 2,
  name: 'My Custom List',
  description: 'Personal study list',
  userId: 1,
  isPublic: false,
  createdAt: DateTime(2024, 1, 2),
  updatedAt: DateTime(2024, 1, 2),
  items: [tKanjiListItem4, tKanjiListItem5],
  userName: 'Test User',
  userEmail: 'test@example.com',
);

final tKanjiList3 = KanjiList(
  id: 3,
  name: 'Public List',
  description: 'Shared with community',
  userId: 2,
  isPublic: true,
  createdAt: DateTime(2024, 1, 3),
  updatedAt: DateTime(2024, 1, 3),
  items: [],
  userName: 'Another User',
  userEmail: 'another@example.com',
);

final tKanjiListEmpty = KanjiList(
  id: 4,
  name: 'Empty List',
  userId: 1,
  isPublic: false,
  createdAt: DateTime(2024, 1, 4),
  updatedAt: DateTime(2024, 1, 4),
  items: [],
  userName: 'Test User',
  userEmail: 'test@example.com',
);

// List of test kanji lists WITH items (for GET by ID)
final tAllKanjiLists = [tKanjiList1, tKanjiList2, tKanjiList3];
final tUserKanjiLists = [tKanjiList1, tKanjiList2];
final tPublicKanjiLists = [tKanjiList1, tKanjiList3];
final tEmptyKanjiLists = <KanjiList>[];

// List of test kanji lists WITHOUT items (for GET all - realistic API behavior)
final tKanjiList1NoItems = KanjiList(
  id: 1,
  name: 'JLPT N5 Basics',
  description: 'Essential kanji for JLPT N5',
  userId: 1,
  isPublic: true,
  createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
  updatedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
  items: [],
  userName: 'Test User',
  userEmail: 'test@example.com',
);

final tKanjiList2NoItems = KanjiList(
  id: 2,
  name: 'My Custom List',
  description: 'Personal study list',
  userId: 1,
  isPublic: false,
  createdAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
  updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
  items: [],
  userName: 'Test User',
  userEmail: 'test@example.com',
);

final tKanjiList3NoItems = KanjiList(
  id: 3,
  name: 'Public List',
  description: 'Shared with community',
  userId: 2,
  isPublic: true,
  createdAt: DateTime.parse('2024-01-03T00:00:00.000Z'),
  updatedAt: DateTime.parse('2024-01-03T00:00:00.000Z'),
  items: [],
  userName: 'Another User',
  userEmail: 'another@example.com',
);

final tAllKanjiListsNoItems = [
  tKanjiList1NoItems,
  tKanjiList2NoItems,
  tKanjiList3NoItems,
];

// Aliases for common use
final tKanjiList = tKanjiList1; // Default test kanji list

// JSON responses
final tKanjiListJson = {
  'id': 1,
  'name': 'JLPT N5 Basics',
  'description': 'Essential kanji for JLPT N5',
  'userId': 1,
  'isPublic': true,
  'createdAt': '2024-01-01T00:00:00.000Z',
  'updatedAt': '2024-01-01T00:00:00.000Z',
  'user': {'account': 'Test User', 'email': 'test@example.com'},
  'items': [
    {
      'id': 1,
      'listId': 1,
      'kanjiId': 1,
      'order': 0,
      'kanji': {
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
    },
    {
      'id': 2,
      'listId': 1,
      'kanjiId': 2,
      'order': 1,
      'kanji': {
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
    },
  ],
};

final tAllKanjiListsJson = [
  {
    'id': 1,
    'name': 'JLPT N5 Basics',
    'description': 'Essential kanji for JLPT N5',
    'userId': 1,
    'isPublic': true,
    'createdAt': '2024-01-01T00:00:00.000Z',
    'updatedAt': '2024-01-01T00:00:00.000Z',
    'user': {'account': 'Test User', 'email': 'test@example.com'},
    'items': [],
  },
  {
    'id': 2,
    'name': 'My Custom List',
    'description': 'Personal study list',
    'userId': 1,
    'isPublic': false,
    'createdAt': '2024-01-02T00:00:00.000Z',
    'updatedAt': '2024-01-02T00:00:00.000Z',
    'user': {'account': 'Test User', 'email': 'test@example.com'},
    'items': [],
  },
  {
    'id': 3,
    'name': 'Public List',
    'description': 'Shared with community',
    'userId': 2,
    'isPublic': true,
    'createdAt': '2024-01-03T00:00:00.000Z',
    'updatedAt': '2024-01-03T00:00:00.000Z',
    'user': {'account': 'Another User', 'email': 'another@example.com'},
    'items': [],
  },
];

// Response wrapper for API (GET all - no items)
final tAllKanjiListsResponseJson = {
  'data': tAllKanjiListsJson,
  'total': tAllKanjiListsJson.length,
  'limit': 20,
  'offset': 0,
};

// JSON for GET by ID with full items (only first 2 items for testing)
final tKanjiListByIdJson = {
  'id': 1,
  'name': 'JLPT N5 Basics',
  'description': 'Essential kanji for JLPT N5',
  'userId': 1,
  'isPublic': true,
  'createdAt': '2024-01-01T00:00:00.000Z',
  'updatedAt': '2024-01-01T00:00:00.000Z',
  'user': {'account': 'Test User', 'email': 'test@example.com'},
  'items': [
    {
      'id': 1,
      'listId': 1,
      'kanjiId': 1,
      'order': 0,
      'kanji': {
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
    },
    {
      'id': 2,
      'listId': 1,
      'kanjiId': 2,
      'order': 1,
      'kanji': {
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
    },
  ],
};

// Entity for GET by ID (with only 2 items to match JSON)
final tKanjiListById = KanjiList(
  id: 1,
  name: 'JLPT N5 Basics',
  description: 'Essential kanji for JLPT N5',
  userId: 1,
  isPublic: true,
  createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
  updatedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
  items: [tKanjiListItem1, tKanjiListItem2], // Only 2 items to match JSON
  userName: 'Test User',
  userEmail: 'test@example.com',
);

// Create request data
final tCreateKanjiListData = {
  'name': 'New List',
  'description': 'A new kanji list',
  'isPublic': false,
};

// Update request data
final tUpdateKanjiListData = {
  'name': 'Updated List Name',
  'description': 'Updated description',
  'isPublic': true,
};

// Add kanji request data
final tAddKanjiData = {'kanjiId': 1};

// Query parameters
const tJlptLevel = 5;
const tCategory = 'CUSTOM';
const tSearchQuery = 'N5';
const tIsPublic = true;
const tUserId = 1;

// Pagination
const tLimit = 20;
const tOffset = 0;

// Error messages
const tKanjiListNotFoundError = 'Kanji list not found';
const tUnauthorizedError = 'Unauthorized to access this list';
const tKanjiAlreadyInListError = 'Kanji already exists in list';
const tInvalidKanjiListDataError = 'Invalid kanji list data';
const tNetworkError = 'Network error occurred';
const tServerError = 'Server error occurred';
