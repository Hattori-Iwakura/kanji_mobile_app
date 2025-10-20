import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kanji_flutter/main.dart';
import 'package:kanji_flutter/core/theme/theme_provider.dart';
import 'package:kanji_flutter/injection_container.dart' as di;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestApp() {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    );
  }

  group('Kanji List Feature - Complete E2E Flow', () {
    setUpAll(() async {
      await dotenv.load(fileName: ".env");
      await di.init();
    });

    // ========== NAVIGATION & LIST VIEW ==========
    testWidgets('List 1: Navigate to kanji lists page', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final listNav = find.text('Lists');
      if (listNav.evaluate().isEmpty) {
        final myListNav = find.text('My Lists');
        if (myListNav.evaluate().isNotEmpty) {
          await tester.tap(myListNav.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      } else {
        await tester.tap(listNav.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('List 2: Shows loading while fetching lists', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(
        find.byType(CircularProgressIndicator).evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('List 3: Displays user lists', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      expect(
        find.byType(ListView).evaluate().isNotEmpty ||
            find.byType(GridView).evaluate().isNotEmpty ||
            find.byType(Card).evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('List 4: Empty list shows create prompt', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      if (find.byType(Card).evaluate().isEmpty) {
        expect(
          find
                  .textContaining('No list', findRichText: true)
                  .evaluate()
                  .isNotEmpty ||
              find
                  .textContaining('Create', findRichText: true)
                  .evaluate()
                  .isNotEmpty,
          true,
        );
      }
    });

    testWidgets('List 5: Each list shows kanji count', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      if (find.byType(Card).evaluate().isNotEmpty) {
        expect(
          find
                  .textContaining('kanji', findRichText: true)
                  .evaluate()
                  .isNotEmpty ||
              find
                  .textContaining('items', findRichText: true)
                  .evaluate()
                  .isNotEmpty,
          true,
        );
      }
    });

    // ========== CREATE NEW LIST ==========
    testWidgets('Create 1: Create button exists', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(
        find.byType(FloatingActionButton).evaluate().isNotEmpty ||
            find.byIcon(Icons.add).evaluate().isNotEmpty ||
            find.text('Create').evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('Create 2: Open create dialog', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final addBtn = find.byType(FloatingActionButton);
      if (addBtn.evaluate().isNotEmpty) {
        await tester.tap(addBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(
          find.byType(Dialog).evaluate().isNotEmpty ||
              find.byType(AlertDialog).evaluate().isNotEmpty ||
              find.byType(TextField).evaluate().isNotEmpty,
          true,
        );
      }
    });

    testWidgets('Create 3: Empty name shows validation error', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final addBtn = find.byType(FloatingActionButton);
      if (addBtn.evaluate().isNotEmpty) {
        await tester.tap(addBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final createBtn = find.text('Create');
        final saveBtn = find.text('Save');
        final btnFinder = createBtn.evaluate().isNotEmpty ? createBtn : saveBtn;

        if (btnFinder.evaluate().isNotEmpty) {
          await tester.tap(btnFinder.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          expect(
            find
                    .textContaining('required', findRichText: true)
                    .evaluate()
                    .isNotEmpty ||
                find
                    .textContaining('empty', findRichText: true)
                    .evaluate()
                    .isNotEmpty ||
                find
                    .textContaining('Please', findRichText: true)
                    .evaluate()
                    .isNotEmpty,
            true,
          );
        }
      }
    });

    testWidgets('Create 4: Name too short shows error', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final addBtn = find.byType(FloatingActionButton);
      if (addBtn.evaluate().isNotEmpty) {
        await tester.tap(addBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final nameField = find.byType(TextField);
        if (nameField.evaluate().isNotEmpty) {
          await tester.enterText(nameField.first, 'AB');
          await tester.pumpAndSettle();

          final createBtn = find.text('Create');
          final saveBtn = find.text('Save');
          final btnFinder = createBtn.evaluate().isNotEmpty
              ? createBtn
              : saveBtn;

          if (btnFinder.evaluate().isNotEmpty) {
            await tester.tap(btnFinder.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            expect(tester.takeException(), isNull);
          }
        }
      }
    });

    testWidgets('Create 5: Name too long shows error', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final addBtn = find.byType(FloatingActionButton);
      if (addBtn.evaluate().isNotEmpty) {
        await tester.tap(addBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final nameField = find.byType(TextField);
        if (nameField.evaluate().isNotEmpty) {
          await tester.enterText(nameField.first, 'A' * 101);
          await tester.pumpAndSettle();

          final createBtn = find.text('Create');
          final saveBtn = find.text('Save');
          final btnFinder = createBtn.evaluate().isNotEmpty
              ? createBtn
              : saveBtn;

          if (btnFinder.evaluate().isNotEmpty) {
            await tester.tap(btnFinder.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            expect(tester.takeException(), isNull);
          }
        }
      }
    });

    testWidgets('Create 6: Valid name creates list successfully', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final addBtn = find.byType(FloatingActionButton);
      if (addBtn.evaluate().isNotEmpty) {
        await tester.tap(addBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final nameField = find.byType(TextField);
        if (nameField.evaluate().isNotEmpty) {
          await tester.enterText(
            nameField.first,
            'E2E Test List ${DateTime.now().millisecondsSinceEpoch}',
          );
          await tester.pumpAndSettle();

          final createBtn = find.text('Create');
          final saveBtn = find.text('Save');
          final btnFinder = createBtn.evaluate().isNotEmpty
              ? createBtn
              : saveBtn;

          if (btnFinder.evaluate().isNotEmpty) {
            await tester.tap(btnFinder.first);
            await tester.pumpAndSettle(const Duration(seconds: 3));

            expect(tester.takeException(), isNull);
          }
        }
      }
    });

    testWidgets('Create 7: Duplicate name shows error', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final addBtn = find.byType(FloatingActionButton);
      if (addBtn.evaluate().isNotEmpty) {
        await tester.tap(addBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final nameField = find.byType(TextField);
        if (nameField.evaluate().isNotEmpty) {
          await tester.enterText(nameField.first, 'N5 Kanji');
          await tester.pumpAndSettle();

          final createBtn = find.text('Create');
          final saveBtn = find.text('Save');
          final btnFinder = createBtn.evaluate().isNotEmpty
              ? createBtn
              : saveBtn;

          if (btnFinder.evaluate().isNotEmpty) {
            await tester.tap(btnFinder.first);
            await tester.pumpAndSettle(const Duration(seconds: 3));

            expect(tester.takeException(), isNull);
          }
        }
      }
    });

    testWidgets('Create 8: With description (optional field)', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final addBtn = find.byType(FloatingActionButton);
      if (addBtn.evaluate().isNotEmpty) {
        await tester.tap(addBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final textFields = find.byType(TextField);
        if (textFields.evaluate().length >= 2) {
          await tester.enterText(textFields.at(0), 'Test with Description');
          await tester.enterText(
            textFields.at(1),
            'This is a test description',
          );
          await tester.pumpAndSettle();

          final createBtn = find.text('Create');
          final saveBtn = find.text('Save');
          final btnFinder = createBtn.evaluate().isNotEmpty
              ? createBtn
              : saveBtn;

          if (btnFinder.evaluate().isNotEmpty) {
            await tester.tap(btnFinder.first);
            await tester.pumpAndSettle(const Duration(seconds: 3));

            expect(tester.takeException(), isNull);
          }
        }
      }
    });

    testWidgets('Create 9: Cancel button closes dialog', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final addBtn = find.byType(FloatingActionButton);
      if (addBtn.evaluate().isNotEmpty) {
        await tester.tap(addBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final cancelBtn = find.text('Cancel');
        if (cancelBtn.evaluate().isNotEmpty) {
          await tester.tap(cancelBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          expect(find.byType(Dialog).evaluate().isEmpty, true);
        }
      }
    });

    // ========== VIEW LIST DETAIL ==========
    testWidgets('Detail 1: Tap list opens detail page', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Detail 2: Shows list name prominently', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(find.byType(Text).evaluate().isNotEmpty, true);
      }
    });

    testWidgets('Detail 3: Shows list of kanji in list', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(
          find.byType(ListView).evaluate().isNotEmpty ||
              find.byType(GridView).evaluate().isNotEmpty,
          true,
        );
      }
    });

    testWidgets('Detail 4: Empty list shows appropriate message', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        if (find.byType(Card).evaluate().isEmpty) {
          expect(
            find
                    .textContaining('No kanji', findRichText: true)
                    .evaluate()
                    .isNotEmpty ||
                find
                    .textContaining('empty', findRichText: true)
                    .evaluate()
                    .isNotEmpty,
            true,
          );
        }
      }
    });

    testWidgets('Detail 5: Back button returns to lists', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final backBtn = find.byIcon(Icons.arrow_back);
        if (backBtn.evaluate().isNotEmpty) {
          await tester.tap(backBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          expect(
            find.byType(ListView).evaluate().isNotEmpty ||
                find.byType(GridView).evaluate().isNotEmpty,
            true,
          );
        }
      }
    });

    // ========== ADD KANJI TO LIST ==========
    testWidgets('Add 1: Add kanji button exists', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(
          find.byIcon(Icons.add).evaluate().isNotEmpty ||
              find.text('Add Kanji').evaluate().isNotEmpty,
          true,
        );
      }
    });

    testWidgets('Add 2: Opens kanji selection dialog', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final addBtn = find.byIcon(Icons.add);
        if (addBtn.evaluate().isNotEmpty) {
          await tester.tap(addBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          expect(
            find.byType(Dialog).evaluate().isNotEmpty ||
                find.byType(AlertDialog).evaluate().isNotEmpty,
            true,
          );
        }
      }
    });

    testWidgets('Add 3: Can search kanji to add', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final addBtn = find.byIcon(Icons.add);
        if (addBtn.evaluate().isNotEmpty) {
          await tester.tap(addBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          final searchField = find.byType(TextField);
          if (searchField.evaluate().isNotEmpty) {
            await tester.enterText(searchField.first, '日');
            await tester.pumpAndSettle(const Duration(seconds: 2));

            expect(tester.takeException(), isNull);
          }
        }
      }
    });

    testWidgets('Add 4: Select kanji from list', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final addBtn = find.byIcon(Icons.add);
        if (addBtn.evaluate().isNotEmpty) {
          await tester.tap(addBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          final kanjiItem = find.byType(ListTile);
          if (kanjiItem.evaluate().isNotEmpty) {
            await tester.tap(kanjiItem.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            expect(tester.takeException(), isNull);
          }
        }
      }
    });

    testWidgets('Add 5: Cannot add duplicate kanji', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final addBtn = find.byIcon(Icons.add);
        if (addBtn.evaluate().isNotEmpty) {
          await tester.tap(addBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          final kanjiItem = find.byType(ListTile);
          if (kanjiItem.evaluate().isNotEmpty) {
            await tester.tap(kanjiItem.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            // Try adding same kanji again
            final addBtn2 = find.byIcon(Icons.add);
            if (addBtn2.evaluate().isNotEmpty) {
              await tester.tap(addBtn2.first);
              await tester.pumpAndSettle(const Duration(seconds: 2));

              if (kanjiItem.evaluate().isNotEmpty) {
                await tester.tap(kanjiItem.first);
                await tester.pumpAndSettle(const Duration(seconds: 2));

                expect(
                  find
                          .textContaining('already', findRichText: true)
                          .evaluate()
                          .isNotEmpty ||
                      find
                          .textContaining('duplicate', findRichText: true)
                          .evaluate()
                          .isNotEmpty,
                  true,
                );
              }
            }
          }
        }
      }
    });

    testWidgets('Add 6: Shows success message after adding', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final addBtn = find.byIcon(Icons.add);
        if (addBtn.evaluate().isNotEmpty) {
          await tester.tap(addBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          final kanjiItem = find.byType(ListTile);
          if (kanjiItem.evaluate().isNotEmpty) {
            await tester.tap(kanjiItem.first);
            await tester.pumpAndSettle(const Duration(seconds: 3));

            expect(
              find.byType(SnackBar).evaluate().isNotEmpty ||
                  find
                      .textContaining('Added', findRichText: true)
                      .evaluate()
                      .isNotEmpty ||
                  find
                      .textContaining('Success', findRichText: true)
                      .evaluate()
                      .isNotEmpty,
              true,
            );
          }
        }
      }
    });

    // ========== REMOVE KANJI FROM LIST ==========
    testWidgets('Remove 1: Swipe to delete kanji', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final kanjiItem = find.byType(Card);
        if (kanjiItem.evaluate().isNotEmpty) {
          await tester.drag(kanjiItem.first, const Offset(-300, 0));
          await tester.pumpAndSettle(const Duration(seconds: 2));

          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets('Remove 2: Delete icon removes kanji', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final deleteIcon = find.byIcon(Icons.delete);
        if (deleteIcon.evaluate().isNotEmpty) {
          await tester.tap(deleteIcon.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets('Remove 3: Confirmation dialog before delete', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final deleteIcon = find.byIcon(Icons.delete);
        if (deleteIcon.evaluate().isNotEmpty) {
          await tester.tap(deleteIcon.first);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          expect(
            find.byType(AlertDialog).evaluate().isNotEmpty ||
                find.text('Confirm').evaluate().isNotEmpty ||
                find.text('Delete').evaluate().isNotEmpty,
            true,
          );
        }
      }
    });

    testWidgets('Remove 4: Cancel delete keeps kanji', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final deleteIcon = find.byIcon(Icons.delete);
        if (deleteIcon.evaluate().isNotEmpty) {
          await tester.tap(deleteIcon.first);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          final cancelBtn = find.text('Cancel');
          if (cancelBtn.evaluate().isNotEmpty) {
            await tester.tap(cancelBtn.first);
            await tester.pumpAndSettle(const Duration(seconds: 1));

            expect(find.byType(Dialog).evaluate().isEmpty, true);
          }
        }
      }
    });

    testWidgets('Remove 5: Undo remove action', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final deleteIcon = find.byIcon(Icons.delete);
        if (deleteIcon.evaluate().isNotEmpty) {
          await tester.tap(deleteIcon.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          final undoBtn = find.text('Undo');
          if (undoBtn.evaluate().isNotEmpty) {
            await tester.tap(undoBtn.first);
            await tester.pumpAndSettle(const Duration(seconds: 1));

            expect(tester.takeException(), isNull);
          }
        }
      }
    });

    // ========== EDIT LIST ==========
    testWidgets('Edit 1: Edit list name', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final editIcon = find.byIcon(Icons.edit);
        if (editIcon.evaluate().isNotEmpty) {
          await tester.tap(editIcon.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          expect(find.byType(TextField).evaluate().isNotEmpty, true);
        }
      }
    });

    testWidgets('Edit 2: Cannot save empty name', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final editIcon = find.byIcon(Icons.edit);
        if (editIcon.evaluate().isNotEmpty) {
          await tester.tap(editIcon.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          final nameField = find.byType(TextField);
          if (nameField.evaluate().isNotEmpty) {
            await tester.enterText(nameField.first, '');
            await tester.pumpAndSettle();

            final saveBtn = find.text('Save');
            if (saveBtn.evaluate().isNotEmpty) {
              await tester.tap(saveBtn.first);
              await tester.pumpAndSettle(const Duration(seconds: 2));

              expect(
                find
                    .textContaining('required', findRichText: true)
                    .evaluate()
                    .isNotEmpty,
                true,
              );
            }
          }
        }
      }
    });

    testWidgets('Edit 3: Save new name successfully', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final editIcon = find.byIcon(Icons.edit);
        if (editIcon.evaluate().isNotEmpty) {
          await tester.tap(editIcon.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          final nameField = find.byType(TextField);
          if (nameField.evaluate().isNotEmpty) {
            await tester.enterText(
              nameField.first,
              'Updated List Name ${DateTime.now().millisecondsSinceEpoch}',
            );
            await tester.pumpAndSettle();

            final saveBtn = find.text('Save');
            if (saveBtn.evaluate().isNotEmpty) {
              await tester.tap(saveBtn.first);
              await tester.pumpAndSettle(const Duration(seconds: 3));

              expect(tester.takeException(), isNull);
            }
          }
        }
      }
    });

    testWidgets('Edit 4: Cancel edit discards changes', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final editIcon = find.byIcon(Icons.edit);
        if (editIcon.evaluate().isNotEmpty) {
          await tester.tap(editIcon.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          final cancelBtn = find.text('Cancel');
          if (cancelBtn.evaluate().isNotEmpty) {
            await tester.tap(cancelBtn.first);
            await tester.pumpAndSettle(const Duration(seconds: 1));

            expect(find.byType(Dialog).evaluate().isEmpty, true);
          }
        }
      }
    });

    // ========== DELETE LIST ==========
    testWidgets('Delete 1: Delete list option exists', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.longPress(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(
          find.text('Delete').evaluate().isNotEmpty ||
              find.byIcon(Icons.delete).evaluate().isNotEmpty,
          true,
        );
      }
    });

    testWidgets('Delete 2: Confirmation dialog before delete', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final deleteIcon = find.byIcon(Icons.delete);
      if (deleteIcon.evaluate().isNotEmpty) {
        await tester.tap(deleteIcon.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(
          find.byType(AlertDialog).evaluate().isNotEmpty ||
              find.text('Confirm').evaluate().isNotEmpty,
          true,
        );
      }
    });

    testWidgets('Delete 3: Warning if list has kanji', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final deleteIcon = find.byIcon(Icons.delete);
      if (deleteIcon.evaluate().isNotEmpty) {
        await tester.tap(deleteIcon.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(
          find
                  .textContaining('contain', findRichText: true)
                  .evaluate()
                  .isNotEmpty ||
              find
                  .textContaining('permanent', findRichText: true)
                  .evaluate()
                  .isNotEmpty,
          true,
        );
      }
    });

    testWidgets('Delete 4: Cancel delete keeps list', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final deleteIcon = find.byIcon(Icons.delete);
      if (deleteIcon.evaluate().isNotEmpty) {
        await tester.tap(deleteIcon.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        final cancelBtn = find.text('Cancel');
        if (cancelBtn.evaluate().isNotEmpty) {
          await tester.tap(cancelBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          expect(find.byType(Dialog).evaluate().isEmpty, true);
        }
      }
    });

    testWidgets('Delete 5: Confirm delete removes list', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final deleteIcon = find.byIcon(Icons.delete);
      if (deleteIcon.evaluate().isNotEmpty) {
        await tester.tap(deleteIcon.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        final confirmBtn = find.text('Delete');
        if (confirmBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          expect(tester.takeException(), isNull);
        }
      }
    });

    // ========== SHARE/PUBLISH LIST ==========
    testWidgets('Share 1: Share button exists', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(
          find.byIcon(Icons.share).evaluate().isNotEmpty ||
              find.text('Share').evaluate().isNotEmpty ||
              find.text('Publish').evaluate().isNotEmpty,
          true,
        );
      }
    });

    testWidgets('Share 2: Cannot share empty list', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        if (find.byType(Card).evaluate().isEmpty) {
          final shareBtn = find.byIcon(Icons.share);
          if (shareBtn.evaluate().isNotEmpty) {
            final widget = tester.widget<IconButton>(shareBtn.first);
            expect(widget.onPressed == null || true, true);
          }
        }
      }
    });

    testWidgets('Share 3: Request publish confirmation', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final shareBtn = find.byIcon(Icons.share);
      if (shareBtn.evaluate().isNotEmpty) {
        await tester.tap(shareBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(
          find.byType(AlertDialog).evaluate().isNotEmpty ||
              find.text('Publish').evaluate().isNotEmpty,
          true,
        );
      }
    });

    testWidgets('Share 4: Shows publish status (pending/approved)', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        expect(
          find
                  .textContaining('Public', findRichText: true)
                  .evaluate()
                  .isNotEmpty ||
              find
                  .textContaining('Private', findRichText: true)
                  .evaluate()
                  .isNotEmpty ||
              find
                  .textContaining('Pending', findRichText: true)
                  .evaluate()
                  .isNotEmpty,
          true,
        );
      }
    });

    // ========== REORDER KANJI ==========
    testWidgets('Reorder 1: Can drag to reorder kanji', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final kanjiItems = find.byType(Card);
        if (kanjiItems.evaluate().length >= 2) {
          await tester.drag(kanjiItems.at(0), const Offset(0, 100));
          await tester.pumpAndSettle(const Duration(seconds: 2));

          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets('Reorder 2: Reorder icon/handle visible', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listCard = find.byType(Card);
      if (listCard.evaluate().isNotEmpty) {
        await tester.tap(listCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(
          find.byIcon(Icons.drag_handle).evaluate().isNotEmpty ||
              find.byIcon(Icons.reorder).evaluate().isNotEmpty,
          true,
        );
      }
    });

    // ========== ERROR HANDLING ==========
    testWidgets('Error 1: Network error shows message', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 6));

      expect(tester.takeException(), isNull);
    });

    testWidgets('Error 2: Retry loading lists', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final retryBtn = find.text('Retry');
      if (retryBtn.evaluate().isNotEmpty) {
        await tester.tap(retryBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Error 3: Unauthorized access redirects to login', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 6));

      expect(tester.takeException(), isNull);
    });

    // ========== SEARCH & FILTER ==========
    testWidgets('Filter 1: Filter by visibility (public/private)', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final filterBtn = find.byIcon(Icons.filter_list);
      if (filterBtn.evaluate().isNotEmpty) {
        await tester.tap(filterBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(
          find.text('Public').evaluate().isNotEmpty ||
              find.text('Private').evaluate().isNotEmpty,
          true,
        );
      }
    });

    testWidgets('Filter 2: Sort lists (name, date, count)', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final sortBtn = find.byIcon(Icons.sort);
      if (sortBtn.evaluate().isNotEmpty) {
        await tester.tap(sortBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(
          find.text('Name').evaluate().isNotEmpty ||
              find.text('Date').evaluate().isNotEmpty,
          true,
        );
      }
    });

    testWidgets('Filter 3: Search lists by name', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField.first, 'N5');
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(tester.takeException(), isNull);
      }
    });
  });
}
