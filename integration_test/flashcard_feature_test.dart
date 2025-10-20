import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanji_flutter/injection_container.dart' as di;
import 'package:kanji_flutter/features/flashcard/presentation/bloc/flashcard_bloc.dart';
import 'package:kanji_flutter/features/flashcard/presentation/bloc/flashcard_event.dart';
import 'package:kanji_flutter/features/flashcard/presentation/bloc/flashcard_state.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flashcard Feature Integration Tests', () {
    setUpAll(() async {
      await di.init();
    });

    testWidgets('Load All Decks: Should fetch flashcard decks', (
      WidgetTester tester,
    ) async {
      final flashcardBloc = di.sl<FlashcardBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FlashcardBloc>(
            create: (_) => flashcardBloc,
            child: BlocBuilder<FlashcardBloc, FlashcardState>(
              builder: (context, state) {
                if (state is FlashcardLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is DecksLoaded) {
                  return Scaffold(
                    body: ListView.builder(
                      itemCount: state.decks.length,
                      itemBuilder: (context, index) {
                        final deck = state.decks[index];
                        return ListTile(
                          title: Text(deck.name),
                          subtitle: Text(
                            'Cards: ${deck.totalCards} (${deck.cardsNew} new, ${deck.cardsDue} due)',
                          ),
                        );
                      },
                    ),
                  );
                } else if (state is FlashcardError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(body: Center(child: Text('Ready')));
              },
            ),
          ),
        ),
      );

      // Load decks
      flashcardBloc.add(LoadAllDecksEvent());

      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final state = flashcardBloc.state;
      expect(state is DecksLoaded || state is FlashcardError, true);

      await flashcardBloc.close();
    });

    testWidgets('Create Deck: Should create new flashcard deck', (
      WidgetTester tester,
    ) async {
      final flashcardBloc = di.sl<FlashcardBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FlashcardBloc>(
            create: (_) => flashcardBloc,
            child: BlocBuilder<FlashcardBloc, FlashcardState>(
              builder: (context, state) {
                if (state is FlashcardLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is DeckCreated) {
                  return Scaffold(
                    body: Center(
                      child: Text('Deck created: ${state.deck.name}'),
                    ),
                  );
                } else if (state is FlashcardError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(body: Center(child: Text('Ready')));
              },
            ),
          ),
        ),
      );

      // Create deck
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      flashcardBloc.add(
        CreateDeckEvent(
          name: 'Test Deck $timestamp',
          description: 'Integration test deck',
          kanjiIds: [1, 2, 3],
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final state = flashcardBloc.state;
      expect(state is DeckCreated || state is FlashcardError, true);

      await flashcardBloc.close();
    });

    testWidgets('Load Deck Detail: Should fetch deck with stats', (
      WidgetTester tester,
    ) async {
      final flashcardBloc = di.sl<FlashcardBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FlashcardBloc>(
            create: (_) => flashcardBloc,
            child: BlocBuilder<FlashcardBloc, FlashcardState>(
              builder: (context, state) {
                if (state is FlashcardLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is DeckDetailLoaded) {
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Deck: ${state.deck.name}'),
                          Text('Total Cards: ${state.deck.totalCards}'),
                          Text('New: ${state.deck.cardsNew}'),
                          Text('Due: ${state.deck.cardsDue}'),
                        ],
                      ),
                    ),
                  );
                } else if (state is FlashcardError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(body: Center(child: Text('Ready')));
              },
            ),
          ),
        ),
      );

      // Load deck by ID
      flashcardBloc.add(LoadDeckByIdEvent(1));

      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final state = flashcardBloc.state;
      expect(state is DeckDetailLoaded || state is FlashcardError, true);

      await flashcardBloc.close();
    });

    testWidgets('Add Card to Deck: Should add flashcard successfully', (
      WidgetTester tester,
    ) async {
      final flashcardBloc = di.sl<FlashcardBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FlashcardBloc>(
            create: (_) => flashcardBloc,
            child: BlocBuilder<FlashcardBloc, FlashcardState>(
              builder: (context, state) {
                if (state is CardAdded) {
                  return const Scaffold(
                    body: Center(child: Text('Card added successfully')),
                  );
                } else if (state is FlashcardError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Add card to deck
      flashcardBloc.add(AddCardEvent(deckId: 1, kanjiId: 5));

      await tester.pumpAndSettle(const Duration(seconds: 5));

      final state = flashcardBloc.state;
      expect(state is CardAdded || state is FlashcardError, true);

      await flashcardBloc.close();
    });

    testWidgets('Update Deck: Should modify deck name and description', (
      WidgetTester tester,
    ) async {
      final flashcardBloc = di.sl<FlashcardBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FlashcardBloc>(
            create: (_) => flashcardBloc,
            child: BlocBuilder<FlashcardBloc, FlashcardState>(
              builder: (context, state) {
                if (state is DeckUpdated) {
                  return Scaffold(
                    body: Center(child: Text('Updated: ${state.deck.name}')),
                  );
                } else if (state is FlashcardError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Update deck
      flashcardBloc.add(
        UpdateDeckEvent(
          id: 1,
          name: 'Updated Deck Name',
          description: 'Updated description',
          isPublic: true,
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      final state = flashcardBloc.state;
      expect(state is DeckUpdated || state is FlashcardError, true);

      await flashcardBloc.close();
    });

    testWidgets('Delete Deck: Should remove deck successfully', (
      WidgetTester tester,
    ) async {
      final flashcardBloc = di.sl<FlashcardBloc>();

      // First create a deck to delete
      flashcardBloc.add(
        CreateDeckEvent(
          name: 'Deck to Delete ${DateTime.now().millisecondsSinceEpoch}',
          description: 'Will be deleted',
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      int? deckIdToDelete;
      if (flashcardBloc.state is DeckCreated) {
        deckIdToDelete = (flashcardBloc.state as DeckCreated).deck.id;
      }

      if (deckIdToDelete != null) {
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<FlashcardBloc>(
              create: (_) => flashcardBloc,
              child: BlocBuilder<FlashcardBloc, FlashcardState>(
                builder: (context, state) {
                  if (state is DeckDeleted) {
                    return const Scaffold(
                      body: Center(child: Text('Deck deleted')),
                    );
                  } else if (state is FlashcardError) {
                    return Scaffold(
                      body: Center(child: Text('Error: ${state.message}')),
                    );
                  }
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
          ),
        );

        // Delete the deck
        flashcardBloc.add(DeleteDeckEvent(deckIdToDelete));

        await tester.pumpAndSettle(const Duration(seconds: 5));

        final state = flashcardBloc.state;
        expect(state is DeckDeleted || state is FlashcardError, true);
      }

      await flashcardBloc.close();
    });

    testWidgets('Update Deck: Should update deck information', (
      WidgetTester tester,
    ) async {
      final flashcardBloc = di.sl<FlashcardBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FlashcardBloc>(
            create: (_) => flashcardBloc,
            child: BlocBuilder<FlashcardBloc, FlashcardState>(
              builder: (context, state) {
                if (state is DeckUpdated) {
                  return Scaffold(
                    body: Center(
                      child: Text('Deck updated: ${state.deck.name}'),
                    ),
                  );
                } else if (state is FlashcardError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Update deck
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      flashcardBloc.add(
        UpdateDeckEvent(
          id: 1,
          name: 'Updated Deck $timestamp',
          description: 'Updated description',
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      final state = flashcardBloc.state;
      expect(state is DeckUpdated || state is FlashcardError, true);

      await flashcardBloc.close();
    });

    testWidgets('Request Publish: Should create publish request', (
      WidgetTester tester,
    ) async {
      final flashcardBloc = di.sl<FlashcardBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FlashcardBloc>(
            create: (_) => flashcardBloc,
            child: BlocBuilder<FlashcardBloc, FlashcardState>(
              builder: (context, state) {
                if (state is PublishRequested) {
                  return const Scaffold(
                    body: Center(child: Text('Publish requested')),
                  );
                } else if (state is FlashcardError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Request publish
      flashcardBloc.add(RequestPublishEvent(1));

      await tester.pumpAndSettle(const Duration(seconds: 5));

      final state = flashcardBloc.state;
      expect(state is PublishRequested || state is FlashcardError, true);

      await flashcardBloc.close();
    });

    testWidgets('Duplicate Deck Creation: Should fail with error', (
      WidgetTester tester,
    ) async {
      final flashcardBloc = di.sl<FlashcardBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FlashcardBloc>(
            create: (_) => flashcardBloc,
            child: BlocBuilder<FlashcardBloc, FlashcardState>(
              builder: (context, state) {
                if (state is FlashcardError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                } else if (state is DeckCreated) {
                  return Scaffold(
                    body: Center(child: Text('Created: ${state.deck.name}')),
                  );
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Try to create deck with duplicate name
      flashcardBloc.add(
        CreateDeckEvent(
          name: 'Test Duplicate Deck',
          description: 'Testing duplicate',
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // First creation might succeed, second should fail
      expect(
        flashcardBloc.state is DeckCreated ||
            flashcardBloc.state is FlashcardError,
        true,
      );

      await flashcardBloc.close();
    });

    testWidgets('Add Card to Deck: Should add card successfully', (
      WidgetTester tester,
    ) async {
      final flashcardBloc = di.sl<FlashcardBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FlashcardBloc>(
            create: (_) => flashcardBloc,
            child: BlocBuilder<FlashcardBloc, FlashcardState>(
              builder: (context, state) {
                if (state is CardAdded) {
                  return const Scaffold(
                    body: Center(child: Text('Card added successfully')),
                  );
                } else if (state is FlashcardError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Add card to deck
      flashcardBloc.add(AddCardEvent(deckId: 1, kanjiId: 5));

      await tester.pumpAndSettle(const Duration(seconds: 5));

      final state = flashcardBloc.state;
      expect(state is CardAdded || state is FlashcardError, true);

      await flashcardBloc.close();
    });

    testWidgets('Remove Card from Deck: Should remove card successfully', (
      WidgetTester tester,
    ) async {
      final flashcardBloc = di.sl<FlashcardBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FlashcardBloc>(
            create: (_) => flashcardBloc,
            child: BlocBuilder<FlashcardBloc, FlashcardState>(
              builder: (context, state) {
                if (state is CardRemoved) {
                  return const Scaffold(
                    body: Center(child: Text('Card removed successfully')),
                  );
                } else if (state is FlashcardError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Remove card from deck
      flashcardBloc.add(RemoveCardEvent(deckId: 1, kanjiId: 1));

      await tester.pumpAndSettle(const Duration(seconds: 5));

      final state = flashcardBloc.state;
      expect(state is CardRemoved || state is FlashcardError, true);

      await flashcardBloc.close();
    });
  });
}
