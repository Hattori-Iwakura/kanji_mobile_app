import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/kanji_table.dart';
import '../bloc/kanji_table_bloc.dart';
import '../bloc/kanji_table_event.dart';
import '../bloc/kanji_table_state.dart';
import 'create_table_page.dart';
import 'add_kanji_to_table_page.dart';
import '../../../kanji/presentation/pages/kanji_detail_page.dart';
import '../../../kanji/presentation/bloc/kanji_bloc.dart';

class KanjiTableDetailPage extends StatefulWidget {
  final int tableId;

  const KanjiTableDetailPage({super.key, required this.tableId});

  @override
  State<KanjiTableDetailPage> createState() => _KanjiTableDetailPageState();
}

class _KanjiTableDetailPageState extends State<KanjiTableDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadTableDetail();
  }

  void _loadTableDetail() {
    context.read<KanjiTableBloc>().add(LoadTableDetailEvent(widget.tableId));
  }

  Future<void> _showDeleteConfirmation(KanjiTable table) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        title: const Text(
          'Delete Table',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${table.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<KanjiTableBloc>().add(DeleteTableEvent(widget.tableId));
    }
  }

  Future<void> _showRemoveKanjiConfirmation(
    int kanjiId,
    String character,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        title: const Text(
          'Remove Kanji',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Remove "$character" from this table?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<KanjiTableBloc>().add(
        RemoveKanjiFromTableEvent(tableId: widget.tableId, kanjiId: kanjiId),
      );
    }
  }

  Future<void> _showPublishDialog() async {
    final reasonController = TextEditingController();

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: const Color(0xFF1A1F2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Request Publish',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Submit this table for public approval?',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Reason (optional)',
                  labelStyle: TextStyle(
                    color: Colors.tealAccent.withOpacity(0.7),
                  ),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.tealAccent.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.tealAccent),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (Navigator.canPop(dialogContext)) {
                  Navigator.pop(dialogContext, false);
                }
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (Navigator.canPop(dialogContext)) {
                  Navigator.pop(dialogContext, true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                foregroundColor: Colors.black,
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      );

      if (confirmed == true && mounted) {
        context.read<KanjiTableBloc>().add(RequestPublishEvent(widget.tableId));
      }
    } finally {
      reasonController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF071126), Color(0xFF0B0F14)],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<KanjiTableBloc, KanjiTableState>(
            listenWhen: (previous, current) {
              // Always listen to loading states
              if (current is KanjiTableLoading) return false;

              // Always listen to errors and operation results
              if (current is KanjiTableError) return true;
              if (current is KanjiTableOperationSuccess) return true;

              // For other states, skip if same type
              if (previous.runtimeType == current.runtimeType) return false;
              return true;
            },
            listener: (context, state) {
              print('🔔 Listener triggered: ${state.runtimeType}');
              if (!mounted) {
                print('⚠️ Widget not mounted, skipping');
                return;
              }

              if (state is KanjiTableOperationSuccess) {
                print('✅ Operation success: ${state.message}');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.tealAccent,
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  if (state.message.contains('deleted')) {
                    if (mounted) Navigator.pop(context);
                  } else if (mounted) {
                    _loadTableDetail();
                  }
                });
              }

              if (state is KanjiTableError) {
                print('❌ Error: ${state.message}');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  print('📱 Showing error SnackBar');
                  if (!mounted) {
                    print('⚠️ Widget not mounted in callback');
                    return;
                  }

                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                });
              }
            },
            buildWhen: (previous, current) {
              if (current is KanjiTableLoading &&
                  previous is KanjiTableDetailLoaded) {
                return false;
              }
              return true;
            },
            builder: (context, state) {
              return Column(
                children: [
                  _buildAppBar(state),
                  Expanded(child: _buildContent(state)),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildAppBar(KanjiTableState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.tealAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.table_chart,
              color: Colors.tealAccent,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Table Detail',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          if (state is KanjiTableDetailLoaded && !state.table.isSystemTable)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: const Color(0xFF1A1F2E),
                onSelected: (value) {
                  final table = state.table;
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<KanjiTableBloc>(),
                          child: CreateTablePage(table: table),
                        ),
                      ),
                    ).then((_) => _loadTableDetail());
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(table);
                  } else if (value == 'publish') {
                    _showPublishDialog();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.tealAccent),
                        SizedBox(width: 8),
                        Text('Edit', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  if (!state.table.isPublic)
                    const PopupMenuItem(
                      value: 'publish',
                      child: Row(
                        children: [
                          Icon(Icons.upload, color: Colors.tealAccent),
                          SizedBox(width: 8),
                          Text(
                            'Request Publish',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(KanjiTableState state) {
    if (state is KanjiTableLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.tealAccent),
      );
    }

    if (state is KanjiTableDetailLoaded) {
      final table = state.table;
      final items = table.items ?? [];

      return Column(
        children: [
          _buildTableInfoCard(table, items.length),
          const SizedBox(height: 20),
          Expanded(child: _buildKanjiGrid(table, items)),
        ],
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.table_chart_outlined,
            size: 64,
            color: Colors.tealAccent.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Table not found',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTableInfoCard(KanjiTable table, int kanjiCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.tealAccent.withOpacity(0.1),
            const Color(0xFF1DE9B6).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  table.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: table.isPublic
                      ? Colors.tealAccent.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  table.isPublic ? Icons.public : Icons.lock,
                  color: table.isPublic ? Colors.tealAccent : Colors.white54,
                  size: 20,
                ),
              ),
            ],
          ),
          if (table.description != null) ...[
            const SizedBox(height: 12),
            Text(
              table.description!,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: table.isSystemTable
                      ? const LinearGradient(
                          colors: [Colors.tealAccent, Color(0xFF00BFA5)],
                        )
                      : LinearGradient(
                          colors: [
                            Colors.blueAccent.withOpacity(0.8),
                            Colors.blue.withOpacity(0.6),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      table.isSystemTable ? Icons.verified : Icons.person,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      table.isSystemTable ? 'System Table' : 'User Table',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.grid_on,
                      size: 14,
                      color: Colors.tealAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$kanjiCount kanji',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.tealAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKanjiGrid(KanjiTable table, List<dynamic> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.grid_off,
              size: 64,
              color: Colors.tealAccent.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No kanji in this table yet',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final kanji = item.kanji;

        return GestureDetector(
          onTap: kanji != null
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          KanjiDetailPage(character: kanji.character),
                    ),
                  );
                }
              : null,
          onLongPress: !table.isSystemTable && kanji != null
              ? () => _showRemoveKanjiConfirmation(kanji.id, kanji.character)
              : null,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.tealAccent.withOpacity(0.1),
                  const Color(0xFF1DE9B6).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 2,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        kanji?.character ?? '?',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (kanji?.meanings != null) ...[
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        kanji!.meanings,
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white70,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFAB() {
    return BlocBuilder<KanjiTableBloc, KanjiTableState>(
      builder: (context, state) {
        if (state is KanjiTableDetailLoaded && !state.table.isSystemTable) {
          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.tealAccent, Color(0xFF00BFA5)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.tealAccent.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () {
                final table = state.table;
                final existingKanjiIds =
                    table.items
                        ?.map((item) => item.kanji?.id)
                        .where((id) => id != null)
                        .cast<int>()
                        .toList() ??
                    [];

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(
                          value: context.read<KanjiTableBloc>(),
                        ),
                        BlocProvider.value(value: context.read<KanjiBloc>()),
                      ],
                      child: AddKanjiToTablePage(
                        tableId: table.id,
                        tableName: table.name,
                        existingKanjiIds: existingKanjiIds,
                      ),
                    ),
                  ),
                ).then((added) {
                  if (added == true) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) _loadTableDetail();
                    });
                  }
                });
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text(
                'Add Kanji',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
