import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/kanjivg_service.dart';
import '../../../../core/services/rapidapi_service.dart';
import '../../domain/entities/kanji.dart';

/// Detail page for a single kanji showing full information
class KanjiDetailPage extends StatefulWidget {
  final Kanji kanji;

  const KanjiDetailPage({super.key, required this.kanji});

  @override
  State<KanjiDetailPage> createState() => _KanjiDetailPageState();
}

class _KanjiDetailPageState extends State<KanjiDetailPage> {
  final KanjiVGService _kanjiVGService = getIt<KanjiVGService>();
  final RapidAPIService _rapidAPIService = getIt<RapidAPIService>();
  final AudioPlayer _audioPlayer = AudioPlayer();

  String? _strokeSvg;
  List<KanjiExample>? _examples;
  bool _loadingStrokes = true;
  bool _loadingExamples = true;
  String? _playingAudioUrl;

  @override
  void initState() {
    super.initState();
    _loadStrokeOrder();
    _loadExamples();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadStrokeOrder() async {
    setState(() => _loadingStrokes = true);
    final svg = await _kanjiVGService.fetchStrokeSvg(widget.kanji.character);
    if (mounted) {
      setState(() {
        _strokeSvg = svg;
        _loadingStrokes = false;
      });
    }
  }

  Future<void> _loadExamples() async {
    setState(() => _loadingExamples = true);
    final examples = await _rapidAPIService.getExamples(widget.kanji.character);
    if (mounted) {
      setState(() {
        _examples = examples;
        _loadingExamples = false;
      });
    }
  }

  Future<void> _playAudio(String url) async {
    try {
      setState(() => _playingAudioUrl = url);
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      await _audioPlayer.processingStateStream.firstWhere(
        (state) => state == ProcessingState.completed,
      );
      if (mounted) {
        setState(() => _playingAudioUrl = null);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _playingAudioUrl = null);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to play audio: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.kanji.character,
          style: const TextStyle(color: Colors.white, fontSize: 32),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {
              // TODO: Add to favorites
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main character display
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: Center(
                  child: Text(
                    widget.kanji.character,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 120,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Noto Sans JP',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Badges (JLPT, Grade, Strokes)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (widget.kanji.jlpt != null)
                  _buildBadge(
                    'JLPT',
                    'N${widget.kanji.jlpt}',
                    _getJlptColor(widget.kanji.jlpt!),
                  ),
                if (widget.kanji.grade != null)
                  _buildBadge(
                    'Grade',
                    '${widget.kanji.grade}',
                    Colors.blue[300]!,
                  ),
                if (widget.kanji.strokeCount != null)
                  _buildBadge(
                    'Strokes',
                    '${widget.kanji.strokeCount}',
                    Colors.purple[300]!,
                  ),
                if (widget.kanji.frequency != null)
                  _buildBadge(
                    'Frequency',
                    '#${widget.kanji.frequency}',
                    Colors.orange[300]!,
                  ),
              ],
            ),
            const SizedBox(height: 32),

            // Readings
            _buildSection(
              'Readings',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.kanji.onyomi != null) ...[
                    _buildReadingRow('音読み (On-yomi)', widget.kanji.onyomi!),
                    const SizedBox(height: 12),
                  ],
                  if (widget.kanji.kunyomi != null) ...[
                    _buildReadingRow('訓読み (Kun-yomi)', widget.kanji.kunyomi!),
                  ],
                  if (widget.kanji.onyomi == null &&
                      widget.kanji.kunyomi == null)
                    const Text(
                      'No readings available',
                      style: TextStyle(
                        color: Colors.white54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Meanings
            _buildSection(
              'Meanings',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.kanji.meaningsList
                    .map(
                      (meaning) => Chip(
                        label: Text(meaning),
                        backgroundColor: const Color(0xFF2A2A2A),
                        labelStyle: const TextStyle(color: Colors.white),
                        side: const BorderSide(color: Colors.white24),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 32),

            // Stroke order with KanjiVG
            _buildSection(
              'Stroke Order',
              _loadingStrokes
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  : _strokeSvg != null
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: SvgPicture.string(
                        _strokeSvg!,
                        width: 300,
                        height: 300,
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.orange,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Stroke data not available',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _loadStrokeOrder,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 24),

            // Examples with RapidAPI
            _buildSection(
              'Examples',
              _loadingExamples
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  : _examples != null && _examples!.isNotEmpty
                  ? Column(
                      children: _examples!
                          .take(5)
                          .map((example) => _buildExampleCard(example))
                          .toList(),
                    )
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.library_books,
                            color: Colors.white54,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No examples available',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _loadExamples,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard(KanjiExample example) {
    final isPlaying = _playingAudioUrl == example.audio.bestUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  example.japanese,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (example.audio.bestUrl != null)
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.stop_circle : Icons.play_circle,
                    color: isPlaying ? Colors.green : Colors.blue,
                  ),
                  onPressed: () {
                    if (isPlaying) {
                      _audioPlayer.stop();
                      setState(() => _playingAudioUrl = null);
                    } else {
                      _playAudio(example.audio.bestUrl!);
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            example.meaning,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildReadingRow(String type, String reading) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            type,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            reading,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getJlptColor(int jlpt) {
    switch (jlpt) {
      case 5:
        return Colors.green[300]!;
      case 4:
        return Colors.lightGreen[300]!;
      case 3:
        return Colors.yellow[300]!;
      case 2:
        return Colors.orange[300]!;
      case 1:
        return Colors.red[300]!;
      default:
        return Colors.grey[300]!;
    }
  }
}
