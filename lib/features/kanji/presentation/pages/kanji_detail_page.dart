import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/kanji_bloc.dart';
import '../bloc/kanji_event.dart';
import '../bloc/kanji_state.dart';
import '../widgets/stroke_order_animation.dart';
import '../widgets/audio_player_widget.dart';
import '../widgets/mini_audio_player.dart';

class KanjiDetailPage extends StatefulWidget {
  final String character;

  const KanjiDetailPage({super.key, required this.character});

  @override
  State<KanjiDetailPage> createState() => _KanjiDetailPageState();
}

class _KanjiDetailPageState extends State<KanjiDetailPage> {
  @override
  void initState() {
    super.initState();
    // Load kanji detail only once when page opens
    context.read<KanjiBloc>().add(LoadKanjiDetailEvent(widget.character));
  }

  void _showEditKanjiDialog(
    BuildContext context,
    Map<String, dynamic> kanjiData,
  ) {
    // Validate that we have the required id
    final kanjiId = kanjiData['id'];
    if (kanjiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot edit: Kanji ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => _EditKanjiDialog(
        kanjiData: kanjiData,
        kanjiId: kanjiId,
        parentContext: context,
        character: widget.character,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: BlocListener<KanjiBloc, KanjiState>(
        listener: (context, state) {
          if (state is KanjiUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kanji updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<KanjiBloc>().add(
              LoadKanjiDetailEvent(widget.character),
            );
          } else if (state is KanjiError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF071126), Color(0xFF0B0F14)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      final isAdmin =
                          authState is Authenticated &&
                          authState.user.role == 'ADMIN';

                      return Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Kanji: ${widget.character}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (isAdmin)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.deepPurpleAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.deepPurpleAccent,
                                ),
                                onPressed: () async {
                                  try {
                                    final response = await sl<ApiClient>().dio
                                        .get(
                                          '/kanji/character/${widget.character}',
                                        );

                                    if (response.statusCode == 200 &&
                                        response.data != null) {
                                      final responseData =
                                          response.data as Map<String, dynamic>;
                                      final kanjiData =
                                          responseData['data']
                                              as Map<String, dynamic>;
                                      if (mounted) {
                                        _showEditKanjiDialog(
                                          context,
                                          kanjiData,
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to load kanji data: $e',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                tooltip: 'Edit Kanji',
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),

                // Content
                Expanded(
                  child: BlocBuilder<KanjiBloc, KanjiState>(
                    builder: (context, state) {
                      if (state is KanjiLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.tealAccent,
                          ),
                        );
                      }

                      if (state is KanjiError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.redAccent,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                ),
                                child: Text(
                                  state.message,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<KanjiBloc>().add(
                                    LoadKanjiDetailEvent(widget.character),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.tealAccent,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Retry',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is KanjiDetailLoaded) {
                        final detail = state.kanjiDetail;

                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Main character display
                              Center(
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.tealAccent.withOpacity(0.1),
                                        Colors.white.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.tealAccent.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      detail.character,
                                      style: const TextStyle(
                                        fontSize: 120,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Basic Info (Stroke count, JLPT, Grade)
                              if (detail.strokeCount != null)
                                _buildSection(
                                  'Information',
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      _InfoChip(
                                        label: 'Strokes',
                                        value: '${detail.strokeCount}',
                                        icon: Icons.edit,
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 20),

                              // Meanings
                              _buildSection(
                                'Meanings',
                                Text(
                                  detail.meanings,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    height: 1.5,
                                  ),
                                ),
                              ),

                              // Readings
                              if (detail.onyomi != null ||
                                  detail.kunyomi != null) ...[
                                const SizedBox(height: 20),
                                _buildSection(
                                  'Readings',
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (detail.onyomi != null) ...[
                                        _ReadingRow(
                                          label: 'On-yomi',
                                          reading: detail.onyomi!,
                                          color: Colors.tealAccent,
                                        ),
                                        if (detail.kunyomi != null)
                                          const SizedBox(height: 12),
                                      ],
                                      if (detail.kunyomi != null)
                                        _ReadingRow(
                                          label: 'Kun-yomi',
                                          reading: detail.kunyomi!,
                                          color: Colors.amberAccent,
                                        ),
                                    ],
                                  ),
                                ),
                              ],

                              // Stroke Order Animation
                              if (detail.strokePaths != null &&
                                  detail.strokePaths!.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                _buildSection(
                                  'Stroke Order',
                                  StrokeOrderAnimation(
                                    strokePaths: detail.strokePaths!,
                                  ),
                                ),
                              ],

                              // Examples
                              if (detail.examples != null &&
                                  detail.examples!.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                _buildSection(
                                  'Examples',
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: detail.examples!
                                        .map(
                                          (example) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Colors.white.withOpacity(
                                                      0.05,
                                                    ),
                                                    Colors.white.withOpacity(
                                                      0.02,
                                                    ),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.1),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          example.japanese,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 6,
                                                        ),
                                                        Text(
                                                          example.meaning,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  0.7,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (example.audioUrl != null)
                                                    MiniAudioPlayer(
                                                      audioUrl:
                                                          example.audioUrl!,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ],

                              // Audio
                              if (detail.audioUrl != null) ...[
                                const SizedBox(height: 20),
                                _buildSection(
                                  'Pronunciation',
                                  AudioPlayerWidget(audioUrl: detail.audioUrl!),
                                ),
                              ],

                              const SizedBox(height: 40),
                            ],
                          ),
                        );
                      }

                      return const Center(
                        child: Text(
                          'Loading...',
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.tealAccent,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// Separate StatefulWidget for Edit Dialog with proper lifecycle
class _EditKanjiDialog extends StatefulWidget {
  final Map<String, dynamic> kanjiData;
  final int kanjiId;
  final BuildContext parentContext;
  final String character;

  const _EditKanjiDialog({
    required this.kanjiData,
    required this.kanjiId,
    required this.parentContext,
    required this.character,
  });

  @override
  State<_EditKanjiDialog> createState() => _EditKanjiDialogState();
}

class _EditKanjiDialogState extends State<_EditKanjiDialog> {
  late final TextEditingController _characterController;
  late final TextEditingController _meaningsController;
  late final TextEditingController _kunReadingsController;
  late final TextEditingController _onReadingsController;
  late final TextEditingController _jlptController;
  late final TextEditingController _gradeController;
  late final TextEditingController _strokeCountController;
  late final TextEditingController _frequencyController;

  @override
  void initState() {
    super.initState();
    _characterController = TextEditingController(
      text: widget.kanjiData['character'] ?? '',
    );
    _meaningsController = TextEditingController(
      text: widget.kanjiData['meanings'] ?? '',
    );
    _kunReadingsController = TextEditingController(
      text: widget.kanjiData['kunyomi'] ?? '',
    );
    _onReadingsController = TextEditingController(
      text: widget.kanjiData['onyomi'] ?? '',
    );
    _jlptController = TextEditingController(
      text: widget.kanjiData['jlpt']?.toString() ?? '',
    );
    _gradeController = TextEditingController(
      text: widget.kanjiData['grade']?.toString() ?? '',
    );
    _strokeCountController = TextEditingController(
      text: widget.kanjiData['strokeCount']?.toString() ?? '',
    );
    _frequencyController = TextEditingController(
      text: widget.kanjiData['frequency']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _characterController.dispose();
    _meaningsController.dispose();
    _kunReadingsController.dispose();
    _onReadingsController.dispose();
    _jlptController.dispose();
    _gradeController.dispose();
    _strokeCountController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_characterController.text.isEmpty || _meaningsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.parentContext.read<KanjiBloc>().add(
      UpdateKanjiEvent(
        id: widget.kanjiId,
        character: _characterController.text,
        meanings: _meaningsController.text,
        kunReadings: _kunReadingsController.text.isEmpty
            ? null
            : _kunReadingsController.text,
        onReadings: _onReadingsController.text.isEmpty
            ? null
            : _onReadingsController.text,
        jlptLevel: _jlptController.text.isEmpty
            ? null
            : int.tryParse(_jlptController.text),
        grade: _gradeController.text.isEmpty
            ? null
            : int.tryParse(_gradeController.text),
        strokeCount: _strokeCountController.text.isEmpty
            ? null
            : int.tryParse(_strokeCountController.text),
        frequency: _frequencyController.text.isEmpty
            ? null
            : int.tryParse(_frequencyController.text),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Kanji'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _characterController,
              decoration: const InputDecoration(labelText: 'Character *'),
              enabled: false,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _meaningsController,
              decoration: const InputDecoration(labelText: 'Meanings *'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _kunReadingsController,
              decoration: const InputDecoration(labelText: 'Kun Readings'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _onReadingsController,
              decoration: const InputDecoration(labelText: 'On Readings'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _jlptController,
              decoration: const InputDecoration(labelText: 'JLPT Level'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _gradeController,
              decoration: const InputDecoration(labelText: 'Grade'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _strokeCountController,
              decoration: const InputDecoration(labelText: 'Stroke Count'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _frequencyController,
              decoration: const InputDecoration(labelText: 'Frequency'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _ReadingRow extends StatelessWidget {
  final String label;
  final String reading;
  final Color color;

  const _ReadingRow({
    required this.label,
    required this.reading,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              reading,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.tealAccent.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.tealAccent.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.tealAccent),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
