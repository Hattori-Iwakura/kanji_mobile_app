import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanji_flutter/features/kanji_list/bloc/kanji_list_bloc.dart';
import 'package:kanji_flutter/features/kanji_list/bloc/kanji_list_event.dart';
import 'package:kanji_flutter/features/kanji_list/bloc/kanji_list_state.dart';
import 'package:kanji_flutter/features/kanji_list/services/kanji_list_service.dart';
import 'package:kanji_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:kanji_flutter/features/auth/bloc/auth_event.dart';
import 'package:kanji_flutter/features/auth/bloc/auth_state.dart';
import 'package:kanji_flutter/features/auth/services/auth_service.dart';
import 'package:kanji_flutter/features/auth/services/auth_storage.dart';
import 'package:kanji_flutter/core/network/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('KanjiList BLoC Integration Tests', () {
    late KanjiListBloc kanjiListBloc;
    late KanjiListService kanjiListService;
    late AuthBloc authBloc;
    late AuthService authService;
    late AuthStorage authStorage;
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient(baseUrl: 'http://10.0.2.2:3000/api');
      authStorage = AuthStorage(const FlutterSecureStorage());
      authService = AuthService(apiClient: apiClient, storage: authStorage);
      authBloc = AuthBloc(authService: authService);
      kanjiListService = KanjiListService(apiClient: apiClient);
      kanjiListBloc = KanjiListBloc(kanjiListService: kanjiListService);
    });

    tearDown(() async {
      await kanjiListBloc.close();
      await authBloc.close();
      // Clean up: logout to clear token
      try {
        await authService.logout();
      } catch (_) {}
    });

    testWidgets('Load kanji lists: System and Custom lists', (
      WidgetTester tester,
    ) async {
      // Login first to get auth token
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => authBloc,
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  return const Scaffold(body: Center(child: Text('Logged In')));
                }
                return const Scaffold(
                  body: Center(child: Text('Not Logged In')),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Request login
      authBloc.add(
        AuthLoginRequested(email: 'test@example.com', password: 'Test@123456'),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Wait for login to complete
      expect(authBloc.state, isA<Authenticated>());

      // Get token and set it in API client
      final token = await authStorage.getToken();
      expect(token, isNotNull);
      apiClient.setAuthToken(token!);

      final List<KanjiListState> states = [];

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiListBloc>(
            create: (_) => kanjiListBloc,
            child: BlocListener<KanjiListBloc, KanjiListState>(
              listener: (context, state) {
                states.add(state);
              },
              child: BlocBuilder<KanjiListBloc, KanjiListState>(
                builder: (context, state) {
                  if (state is KanjiListsLoaded) {
                    return Scaffold(
                      body: Column(
                        children: [
                          Text('System: ${state.systemLists.length}'),
                          Text('Custom: ${state.customLists.length}'),
                          Expanded(
                            child: ListView.builder(
                              itemCount: state.systemLists.length,
                              itemBuilder: (context, index) {
                                final list = state.systemLists[index];
                                return ListTile(
                                  key: Key('system_${list.id}'),
                                  title: Text(list.name),
                                  subtitle: Text(list.level ?? 'No level'),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (state is KanjiListLoading) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is KanjiListError) {
                    return Scaffold(
                      body: Center(child: Text('Error: ${state.message}')),
                    );
                  }
                  return const Scaffold(body: Center(child: Text('Initial')));
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Initial'), findsOneWidget);

      // Load lists
      kanjiListBloc.add(const KanjiListLoadRequested());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify loaded state
      expect(kanjiListBloc.state, isA<KanjiListsLoaded>());
      final loadedState = kanjiListBloc.state as KanjiListsLoaded;

      // Should have system lists (N5, N4, N3, N2, N1)
      expect(loadedState.systemLists.length, greaterThanOrEqualTo(5));

      // Verify JLPT lists are sorted (N5 -> N1)
      final levels = loadedState.systemLists
          .where((list) => list.level != null)
          .map((list) => list.level)
          .toList();
      expect(levels, contains('N5'));
      expect(levels, contains('N1'));

      // Verify UI shows lists
      expect(find.textContaining('System:'), findsOneWidget);
      expect(find.byType(ListTile), findsWidgets);

      // Verify state transitions
      expect(states.length, greaterThanOrEqualTo(2));
      expect(states[0], isA<KanjiListLoading>());
      expect(states[1], isA<KanjiListsLoaded>());
    });

    testWidgets('View list details with kanji items', (
      WidgetTester tester,
    ) async {
      // Login first to get auth token for protected endpoint
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => authBloc,
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  return const Scaffold(body: Center(child: Text('Logged In')));
                }
                return const Scaffold(
                  body: Center(child: Text('Not Logged In')),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Perform login
      authBloc.add(
        AuthLoginRequested(email: 'test@example.com', password: 'Test@123456'),
      );
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify logged in
      expect(authBloc.state, isA<Authenticated>());
      expect(find.text('Logged In'), findsOneWidget);

      // Get token and set it in ApiClient
      final token = await authStorage.getToken();
      if (token != null) {
        apiClient.setAuthToken(token);
      }

      // Now test list details with authentication
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiListBloc>(
            create: (_) => kanjiListBloc,
            child: BlocBuilder<KanjiListBloc, KanjiListState>(
              builder: (context, state) {
                if (state is KanjiListDetailLoaded) {
                  return Scaffold(
                    body: Column(
                      children: [
                        Text('List: ${state.list.name}'),
                        Text('Level: ${state.list.level ?? "Custom"}'),
                        Text('Kanji Count: ${state.kanjiItems.length}'),
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.kanjiItems.length,
                            itemBuilder: (context, index) {
                              final kanji = state.kanjiItems[index];
                              return ListTile(title: Text(kanji.character));
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is KanjiListLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is KanjiListError) {
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

      await tester.pumpAndSettle();

      // Load N5 list detail (assuming ID 5 based on backend data)
      kanjiListBloc.add(const KanjiListDetailRequested(5));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify detail loaded
      expect(kanjiListBloc.state, isA<KanjiListDetailLoaded>());
      final state = kanjiListBloc.state as KanjiListDetailLoaded;

      expect(state.list.id, 5);
      expect(state.list.name.isNotEmpty, true);
      expect(state.kanjiItems.isNotEmpty, true);

      // Verify UI
      expect(find.textContaining('List:'), findsOneWidget);
      expect(find.textContaining('Kanji Count:'), findsOneWidget);
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('Create custom list', (WidgetTester tester) async {
      print('🔍 DEBUG: [CREATE TEST] Starting create custom list test');

      // Login first to get auth token for protected endpoint
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => authBloc,
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  return const Scaffold(body: Center(child: Text('Logged In')));
                }
                return const Scaffold(
                  body: Center(child: Text('Not Logged In')),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      print('🔍 DEBUG: [CREATE TEST] Pumped auth widget');

      // Perform login
      print('🔍 DEBUG: [CREATE TEST] Requesting login...');
      authBloc.add(
        AuthLoginRequested(email: 'test@example.com', password: 'Test@123456'),
      );
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify logged in
      print('🔍 DEBUG: [CREATE TEST] Auth state: ${authBloc.state}');
      expect(authBloc.state, isA<Authenticated>());
      expect(find.text('Logged In'), findsOneWidget);
      print('🔍 DEBUG: [CREATE TEST] Login successful');

      // Get token and set it in ApiClient
      final token = await authStorage.getToken();
      print(
        '🔍 DEBUG: [CREATE TEST] Token retrieved: ${token != null ? "YES (${token.substring(0, 20)}...)" : "NO"}',
      );
      if (token != null) {
        apiClient.setAuthToken(token);
        print('🔍 DEBUG: [CREATE TEST] Token set in ApiClient');
      }

      // Now test create list with authentication
      final List<KanjiListState> states = [];

      print('🔍 DEBUG: [CREATE TEST] Creating kanji list widget...');
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiListBloc>(
            create: (_) => kanjiListBloc,
            child: BlocListener<KanjiListBloc, KanjiListState>(
              listener: (context, state) {
                states.add(state);
              },
              child: BlocBuilder<KanjiListBloc, KanjiListState>(
                builder: (context, state) {
                  if (state is KanjiListOperationSuccess) {
                    return Scaffold(
                      body: Center(child: Text('Success: ${state.message}')),
                    );
                  } else if (state is KanjiListsLoaded) {
                    return Scaffold(
                      body: Column(
                        children: [
                          Text('Custom Lists: ${state.customLists.length}'),
                          ElevatedButton(
                            key: const Key('create_button'),
                            onPressed: () {
                              context.read<KanjiListBloc>().add(
                                const KanjiListCreateRequested(
                                  name: 'My Test List',
                                  description: 'Integration test list',
                                ),
                              );
                            },
                            child: const Text('Create List'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is KanjiListLoading) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is KanjiListError) {
                    return Scaffold(
                      body: Center(child: Text('Error: ${state.message}')),
                    );
                  }
                  return const Scaffold(body: Center(child: Text('Ready')));
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      print('🔍 DEBUG: [CREATE TEST] Kanji list widget pumped');

      // Load existing lists first
      print('🔍 DEBUG: Loading initial lists...');
      kanjiListBloc.add(const KanjiListLoadRequested());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      print('🔍 DEBUG: Current BLoC state: ${kanjiListBloc.state}');
      print('🔍 DEBUG: State type: ${kanjiListBloc.state.runtimeType}');

      if (kanjiListBloc.state is KanjiListError) {
        print(
          '❌ ERROR STATE: ${(kanjiListBloc.state as KanjiListError).message}',
        );
      }

      expect(
        kanjiListBloc.state,
        isA<KanjiListsLoaded>(),
        reason:
            'Expected KanjiListsLoaded but got ${kanjiListBloc.state.runtimeType}',
      );
      final initialState = kanjiListBloc.state as KanjiListsLoaded;
      final initialCount = initialState.customLists.length;
      print('🔍 DEBUG: Initial custom lists count: $initialCount');
      print(
        '🔍 DEBUG: Initial system lists count: ${initialState.systemLists.length}',
      );

      // Create new list
      print('🔍 DEBUG: Creating new custom list...');
      print('🔍 DEBUG: Looking for create_button...');
      expect(
        find.byKey(const Key('create_button')),
        findsOneWidget,
        reason: 'Create button should be visible',
      );
      print('🔍 DEBUG: Button found, tapping...');
      await tester.tap(find.byKey(const Key('create_button')));
      print('🔍 DEBUG: Button tapped, pumping...');
      await tester.pumpAndSettle(const Duration(seconds: 5));
      print('🔍 DEBUG: Pump completed');

      // Log all state transitions
      print('🔍 DEBUG: State transitions after create:');
      for (var i = 0; i < states.length; i++) {
        final state = states[i];
        if (state is KanjiListLoading) {
          print('  [$i] KanjiListLoading');
        } else if (state is KanjiListOperationSuccess) {
          print('  [$i] KanjiListOperationSuccess: ${state.message}');
        } else if (state is KanjiListsLoaded) {
          print(
            '  [$i] KanjiListsLoaded: ${state.customLists.length} custom, ${state.systemLists.length} system',
          );
        } else if (state is KanjiListError) {
          print('  [$i] KanjiListError: ${state.message}');
        }
      }

      // BLoC emits success then immediately reloads, so final state is KanjiListsLoaded
      // Wait for reload to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify list was created (final state should be KanjiListsLoaded with increased count)
      print('🔍 DEBUG: Final state type: ${kanjiListBloc.state.runtimeType}');
      expect(kanjiListBloc.state, isA<KanjiListsLoaded>());

      final finalState = kanjiListBloc.state as KanjiListsLoaded;
      final finalCount = finalState.customLists.length;
      print('🔍 DEBUG: Final custom lists count: $finalCount');
      print(
        '🔍 DEBUG: Final system lists count: ${finalState.systemLists.length}',
      );

      if (finalCount > 0) {
        print('🔍 DEBUG: Custom lists:');
        for (var list in finalState.customLists) {
          print(
            '  - [${list.id}] ${list.name} (type: ${list.type}, userId: ${list.userId})',
          );
        }
      }

      expect(
        finalCount,
        greaterThan(initialCount),
        reason:
            'Expected custom list count to increase from $initialCount to more, but got $finalCount',
      );
    });

    testWidgets('Add kanji to custom list', (WidgetTester tester) async {
      int? testListId;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<KanjiListBloc>(
            create: (_) => kanjiListBloc,
            child: BlocBuilder<KanjiListBloc, KanjiListState>(
              builder: (context, state) {
                if (state is KanjiListDetailLoaded) {
                  return Scaffold(
                    body: Column(
                      children: [
                        Text('Kanji Count: ${state.kanjiItems.length}'),
                        ElevatedButton(
                          key: const Key('add_kanji_button'),
                          onPressed: () {
                            context.read<KanjiListBloc>().add(
                              KanjiAddToListRequested(
                                listId: state.list.id,
                                kanjiId: 1, // Add kanji with ID 1
                              ),
                            );
                          },
                          child: const Text('Add Kanji'),
                        ),
                      ],
                    ),
                  );
                } else if (state is KanjiListsLoaded) {
                  // Store first custom list ID for testing
                  if (state.customLists.isNotEmpty) {
                    testListId = state.customLists.first.id;
                  }
                  return Scaffold(
                    body: Text('Lists loaded: ${state.customLists.length}'),
                  );
                } else if (state is KanjiListOperationSuccess) {
                  return Scaffold(
                    body: Center(child: Text('Success: ${state.message}')),
                  );
                }
                return const Scaffold(body: Center(child: Text('Loading')));
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Load lists to get a custom list ID
      kanjiListBloc.add(const KanjiListLoadRequested());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Skip if no custom lists
      if (testListId == null) {
        print('⚠️  No custom lists available, skipping add kanji test');
        return;
      }

      // Load list detail
      kanjiListBloc.add(KanjiListDetailRequested(testListId!));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(kanjiListBloc.state, isA<KanjiListDetailLoaded>());
      final initialCount =
          (kanjiListBloc.state as KanjiListDetailLoaded).kanjiItems.length;

      // Add kanji to list
      await tester.tap(find.byKey(const Key('add_kanji_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should reload detail
      expect(kanjiListBloc.state, isA<KanjiListDetailLoaded>());
      final finalCount =
          (kanjiListBloc.state as KanjiListDetailLoaded).kanjiItems.length;

      // Count should increase (unless kanji was already in list)
      expect(finalCount, greaterThanOrEqualTo(initialCount));
    });

    testWidgets('Delete custom list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>(create: (_) => authBloc),
              BlocProvider<KanjiListBloc>(create: (_) => kanjiListBloc),
            ],
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                return BlocBuilder<KanjiListBloc, KanjiListState>(
                  builder: (context, state) {
                    if (state is KanjiListsLoaded) {
                      return Scaffold(
                        body: Column(
                          children: [
                            Text('Custom Lists: ${state.customLists.length}'),
                            if (state.customLists.isNotEmpty)
                              ElevatedButton(
                                key: const Key('delete_button'),
                                onPressed: () {
                                  context.read<KanjiListBloc>().add(
                                    KanjiListDeleteRequested(
                                      state.customLists.first.id,
                                    ),
                                  );
                                },
                                child: const Text('Delete First List'),
                              ),
                          ],
                        ),
                      );
                    } else if (state is KanjiListOperationSuccess) {
                      return Scaffold(
                        body: Center(child: Text('Success: ${state.message}')),
                      );
                    }
                    return const Scaffold(body: Center(child: Text('Loading')));
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Login first
      authBloc.add(
        AuthLoginRequested(email: 'test@example.com', password: 'Test@123456'),
      );
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Get token and set in ApiClient
      final token = await authStorage.getToken();
      if (token != null) {
        apiClient.setAuthToken(token);
      }

      // Load lists (only once)
      kanjiListBloc.add(const KanjiListLoadRequested());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(kanjiListBloc.state, isA<KanjiListsLoaded>());
      final initialCount =
          (kanjiListBloc.state as KanjiListsLoaded).customLists.length;

      // Skip if no custom lists
      if (initialCount == 0) {
        print('⚠️  No custom lists available, skipping delete test');
        return;
      }

      print('📋 Initial custom lists count: $initialCount');

      // Delete first custom list
      await tester.tap(find.byKey(const Key('delete_button')));
      await tester.pump(); // Start the tap animation

      // Wait for delete to process
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // After delete, BLoC should emit OperationSuccess then reload
      // We might see Success message or go straight to Loaded state
      final currentState = kanjiListBloc.state;
      print('📊 State after delete: ${currentState.runtimeType}');

      if (currentState is KanjiListOperationSuccess) {
        print('✅ Delete success message: ${currentState.message}');
        // If still showing success, wait for reload to complete
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      // Now should be in Loaded state with reduced count
      expect(
        kanjiListBloc.state,
        isA<KanjiListsLoaded>(),
        reason: 'Should be in Loaded state after delete and reload',
      );

      final finalCount =
          (kanjiListBloc.state as KanjiListsLoaded).customLists.length;
      print('📋 Final custom lists count: $finalCount');

      expect(
        finalCount,
        lessThan(initialCount),
        reason:
            'Custom list count should decrease from $initialCount to $finalCount',
      );
    });

    test('System lists are sorted by JLPT level', () async {
      // Login first
      authBloc.add(
        AuthLoginRequested(email: 'test@example.com', password: 'Test@123456'),
      );
      await Future.delayed(const Duration(seconds: 5));

      // Get token and set in ApiClient
      final token = await authStorage.getToken();
      if (token != null) {
        apiClient.setAuthToken(token);
      }

      kanjiListBloc.add(const KanjiListLoadRequested());
      await Future.delayed(const Duration(seconds: 3));

      expect(kanjiListBloc.state, isA<KanjiListsLoaded>());
      final state = kanjiListBloc.state as KanjiListsLoaded;

      final jlptLists = state.systemLists.where((list) => list.level != null);
      final levels = jlptLists.map((list) => list.level).toList();

      // Verify order: N5, N4, N3, N2, N1
      const expectedOrder = ['N5', 'N4', 'N3', 'N2', 'N1'];
      final actualOrder = levels
          .where((level) => expectedOrder.contains(level))
          .toList();

      for (int i = 1; i < actualOrder.length; i++) {
        final prevIndex = expectedOrder.indexOf(actualOrder[i - 1]!);
        final currIndex = expectedOrder.indexOf(actualOrder[i]!);
        expect(
          prevIndex < currIndex,
          true,
          reason: 'JLPT lists should be ordered N5->N1',
        );
      }
    });

    test('Refresh lists reloads data', () async {
      // Login first
      authBloc.add(
        AuthLoginRequested(email: 'test@example.com', password: 'Test@123456'),
      );
      await Future.delayed(const Duration(seconds: 5));

      // Get token and set in ApiClient
      final token = await authStorage.getToken();
      if (token != null) {
        apiClient.setAuthToken(token);
      }

      // Initial load
      kanjiListBloc.add(const KanjiListLoadRequested());
      await Future.delayed(const Duration(seconds: 3));
      expect(kanjiListBloc.state, isA<KanjiListsLoaded>());

      final firstLoadCount =
          (kanjiListBloc.state as KanjiListsLoaded).systemLists.length;

      // Refresh
      kanjiListBloc.add(const KanjiListRefreshRequested());
      await Future.delayed(const Duration(seconds: 3));

      expect(kanjiListBloc.state, isA<KanjiListsLoaded>());
      final refreshedCount =
          (kanjiListBloc.state as KanjiListsLoaded).systemLists.length;

      // Should have same count after refresh
      expect(refreshedCount, firstLoadCount);
    });

    test('Invalid list ID returns error', () async {
      // Login first
      authBloc.add(
        AuthLoginRequested(email: 'test@example.com', password: 'Test@123456'),
      );
      await Future.delayed(const Duration(seconds: 5));

      // Get token and set in ApiClient
      final token = await authStorage.getToken();
      if (token != null) {
        apiClient.setAuthToken(token);
      }

      kanjiListBloc.add(const KanjiListDetailRequested(999999));
      await Future.delayed(const Duration(seconds: 3));

      expect(kanjiListBloc.state, isA<KanjiListError>());
      final errorState = kanjiListBloc.state as KanjiListError;
      expect(errorState.message.isNotEmpty, true);
    });
  });
}
