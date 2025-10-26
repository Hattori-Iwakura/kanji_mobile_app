import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/entities/flashcard_deck_new.dart';
import 'package:kanji_mobile_v1/features/flashcard/presentation/widgets/flashcard_deck_card.dart';

import '../../helpers/fixtures/flashcard_fixtures.dart';

void main() {
  group('FlashcardDeckCard Widget Tests', () {
    testWidgets('should display deck name', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FlashcardDeckCard(deck: tFlashcardDeckNew1)),
        ),
      );

      // Assert
      expect(find.text('JLPT N5 Kanji'), findsOneWidget);
    });

    testWidgets('should display deck description when provided', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FlashcardDeckCard(deck: tFlashcardDeckNew1)),
        ),
      );

      // Assert
      expect(find.text('Basic kanji for JLPT N5'), findsOneWidget);
    });

    testWidgets('should not display description when null', (tester) async {
      // Arrange
      final deckWithoutDesc = FlashcardDeckNew(
        id: tFlashcardDeckNew1.id,
        name: tFlashcardDeckNew1.name,
        description: null,
        userId: tFlashcardDeckNew1.userId,
        isPublic: tFlashcardDeckNew1.isPublic,
        createdAt: tFlashcardDeckNew1.createdAt,
        updatedAt: tFlashcardDeckNew1.updatedAt,
        cards: tFlashcardDeckNew1.cards,
        userName: tFlashcardDeckNew1.userName,
        userEmail: tFlashcardDeckNew1.userEmail,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FlashcardDeckCard(deck: deckWithoutDesc)),
        ),
      );

      // Assert
      expect(find.text('Basic kanji for JLPT N5'), findsNothing);
    });

    testWidgets('should display total cards count', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FlashcardDeckCard(deck: tFlashcardDeckNew1)),
        ),
      );

      // Assert
      expect(find.text('5 cards'), findsOneWidget);
      expect(find.byIcon(Icons.layers), findsOneWidget);
    });

    testWidgets('should display public badge for public deck', (tester) async {
      // Arrange
      final publicDeck = FlashcardDeckNew(
        id: tFlashcardDeckNew1.id,
        name: tFlashcardDeckNew1.name,
        description: tFlashcardDeckNew1.description,
        userId: tFlashcardDeckNew1.userId,
        isPublic: true,
        createdAt: tFlashcardDeckNew1.createdAt,
        updatedAt: tFlashcardDeckNew1.updatedAt,
        cards: tFlashcardDeckNew1.cards,
        userName: tFlashcardDeckNew1.userName,
        userEmail: tFlashcardDeckNew1.userEmail,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FlashcardDeckCard(deck: publicDeck)),
        ),
      );

      // Assert
      expect(find.text('Public'), findsOneWidget);
      expect(find.byIcon(Icons.public), findsOneWidget);
    });

    testWidgets('should display private badge for private deck', (
      tester,
    ) async {
      // Arrange
      final privateDeck = FlashcardDeckNew(
        id: tFlashcardDeckNew1.id,
        name: tFlashcardDeckNew1.name,
        description: tFlashcardDeckNew1.description,
        userId: tFlashcardDeckNew1.userId,
        isPublic: false,
        createdAt: tFlashcardDeckNew1.createdAt,
        updatedAt: tFlashcardDeckNew1.updatedAt,
        cards: tFlashcardDeckNew1.cards,
        userName: tFlashcardDeckNew1.userName,
        userEmail: tFlashcardDeckNew1.userEmail,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FlashcardDeckCard(deck: privateDeck)),
        ),
      );

      // Assert
      expect(find.text('Private'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('should display user name', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FlashcardDeckCard(deck: tFlashcardDeckNew1)),
        ),
      );

      // Assert
      expect(find.text('testuser'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should display deck icon', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FlashcardDeckCard(deck: tFlashcardDeckNew1)),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.style), findsOneWidget);
    });

    testWidgets('should display updated time', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FlashcardDeckCard(deck: tFlashcardDeckNew1)),
        ),
      );

      // Assert
      expect(find.textContaining('Updated'), findsOneWidget);
    });

    testWidgets('should show actions menu when showActions is true', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardDeckCard(
              deck: tFlashcardDeckNew1,
              showActions: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('should hide actions menu when showActions is false', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardDeckCard(
              deck: tFlashcardDeckNew1,
              showActions: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.more_vert), findsNothing);
    });

    testWidgets('should call onTap when card is tapped', (tester) async {
      // Arrange
      bool tapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardDeckCard(
              deck: tFlashcardDeckNew1,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, true);
    });

    testWidgets('should call onEdit when edit is selected', (tester) async {
      // Arrange
      bool editCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardDeckCard(
              deck: tFlashcardDeckNew1,
              onEdit: () => editCalled = true,
            ),
          ),
        ),
      );

      // Open menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Tap edit
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Assert
      expect(editCalled, true);
    });

    testWidgets('should call onDelete when delete is selected', (tester) async {
      // Arrange
      bool deleteCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardDeckCard(
              deck: tFlashcardDeckNew1,
              onDelete: () => deleteCalled = true,
            ),
          ),
        ),
      );

      // Open menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Tap delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      expect(deleteCalled, true);
    });

    testWidgets('should show edit and delete options in menu', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FlashcardDeckCard(deck: tFlashcardDeckNew1)),
        ),
      );

      // Open menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });
  });
}
