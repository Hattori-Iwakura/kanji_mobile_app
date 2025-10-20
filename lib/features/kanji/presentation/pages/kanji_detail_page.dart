import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../injection_container.dart' as di;
import '../../../../core/services/kanji_alive_service.dart';
import '../../../../core/services/kanjivg_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/kanji_bloc.dart';
import '../bloc/kanji_event.dart';
import '../bloc/kanji_state.dart';

class KanjiDetailPage extends StatelessWidget {
  final int kanjiId;

  const KanjiDetailPage({Key? key, required this.kanjiId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<KanjiBloc>()..add(LoadKanjiByIdEvent(kanjiId)),
      child: const _KanjiDetailView(),
    );
  }
}

class _KanjiDetailView extends StatefulWidget {
  const _KanjiDetailView();

  @override
  State<_KanjiDetailView> createState() => _KanjiDetailViewState();
}

class _KanjiDetailViewState extends State<_KanjiDetailView> {
  final _kanjiAliveService = di.sl<KanjiAliveService>();
  final _kanjiVGService = di.sl<KanjiVGService>();
  final _audioPlayer = AudioPlayer();

  KanjiAliveInfo? _kanjiAliveInfo;
  KanjiStrokeInfo? _strokeInfo;
  bool _loadingExternal = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadExternalData(String character) async {
    setState(() => _loadingExternal = true);

    try {
      final results = await Future.wait([
        _kanjiAliveService.getKanjiInfo(character),
        _kanjiVGService.getStrokeInfo(character),
      ]);

      setState(() {
        _kanjiAliveInfo = results[0] as KanjiAliveInfo?;
        _strokeInfo = results[1] as KanjiStrokeInfo?;
        _loadingExternal = false;
      });
    } catch (e) {
      print('Error loading external data: $e');
      setState(() => _loadingExternal = false);
    }
  }

  Future<void> _playAudio(String url) async {
    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isAdmin =
        authState is Authenticated && authState.user.role == 'ADMIN';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanji Detail'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit feature coming soon')),
                );
              },
            ),
        ],
      ),
      body: BlocBuilder<KanjiBloc, KanjiState>(
        builder: (context, state) {
          if (state is KanjiLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is KanjiError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 80, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          if (state is KanjiDetailLoaded) {
            final kanji = state.kanji;

            // Load external data when kanji is loaded
            if (_kanjiAliveInfo == null && !_loadingExternal) {
              Future.microtask(() => _loadExternalData(kanji.character));
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Large Character Display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          kanji.character,
                          style: const TextStyle(
                            fontSize: 120,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (kanji.jlptLevel != null || kanji.grade != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (kanji.jlptLevel != null)
                                _buildChip(kanji.jlptLevel!, Icons.school),
                              if (kanji.grade != null) ...[
                                if (kanji.jlptLevel != null)
                                  const SizedBox(width: 8),
                                _buildChip('Grade ${kanji.grade}', Icons.grade),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Meanings
                  _buildSection(
                    'Meanings',
                    kanji.meanings.join(', '),
                    Icons.translate,
                  ),

                  // Readings
                  if (kanji.onyomi != null || kanji.kunyomi != null)
                    _buildSection(
                      'Readings',
                      [
                        if (kanji.onyomi != null) 'On: ${kanji.onyomi}',
                        if (kanji.kunyomi != null) 'Kun: ${kanji.kunyomi}',
                      ].join('\n'),
                      Icons.volume_up,
                    ),

                  // Han Viet
                  if (kanji.hanviet != null)
                    _buildSection('Hán Việt', kanji.hanviet!, Icons.language),

                  // Stroke Count
                  _buildSection(
                    'Stroke Count',
                    '${kanji.strokeCount} strokes',
                    Icons.edit,
                  ),

                  // Stroke Animation (from KanjiVG)
                  if (_strokeInfo != null && _strokeInfo!.hasSvg)
                    _buildStrokeAnimationSection(_strokeInfo!),

                  if (_loadingExternal && _strokeInfo == null)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  // Frequency
                  if (kanji.frequency != null)
                    _buildSection(
                      'Frequency',
                      'Rank ${kanji.frequency}',
                      Icons.trending_up,
                    ),

                  // Examples with Audio (from KanjiAlive)
                  if (_kanjiAliveInfo != null &&
                      _kanjiAliveInfo!.examples.isNotEmpty)
                    _buildExamplesSection(_kanjiAliveInfo!.examples),

                  // Mnemonics
                  if (kanji.meaningMnemonic != null)
                    _buildSection(
                      'Meaning Mnemonic',
                      kanji.meaningMnemonic!,
                      Icons.lightbulb,
                    ),

                  if (kanji.readingMnemonic != null)
                    _buildSection(
                      'Reading Mnemonic',
                      kanji.readingMnemonic!,
                      Icons.menu_book,
                    ),

                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add to flashcard - Coming soon')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add to Deck'),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 16)),
          const Divider(height: 32),
        ],
      ),
    );
  }

  Widget _buildStrokeAnimationSection(KanjiStrokeInfo strokeInfo) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.draw, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Stroke Order Animation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: SvgPicture.network(
                strokeInfo.svgUrl,
                width: 200,
                height: 200,
                placeholderBuilder: (context) =>
                    const CircularProgressIndicator(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'SVG Stroke Diagram from KanjiVG',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const Divider(height: 32),
        ],
      ),
    );
  }

  Widget _buildExamplesSection(List<KanjiExample> examples) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.library_books, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Usage Examples',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...examples.take(5).map((example) => _buildExampleCard(example)),
          const Divider(height: 32),
        ],
      ),
    );
  }

  Widget _buildExampleCard(KanjiExample example) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          example.japanese,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          example.meaning.english,
          style: const TextStyle(fontSize: 14),
        ),
        trailing: example.audio.hasAudio
            ? IconButton(
                icon: const Icon(Icons.volume_up, color: Colors.blue),
                onPressed: () => _playAudio(example.audio.bestAudioUrl),
                tooltip: 'Play audio',
              )
            : null,
      ),
    );
  }
}
