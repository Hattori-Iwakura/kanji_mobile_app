import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/translation_result.dart';
import '../../services/translation_service.dart';
import '../../services/text_to_speech_service.dart';
import '../../services/speech_to_text_service.dart';
import '../../services/translation_history_service.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _sourceController = TextEditingController();
  final TranslationService _translationService = TranslationService();
  final TextToSpeechService _ttsService = TextToSpeechService();
  final SpeechToTextService _sttService = SpeechToTextService();
  late TranslationHistoryService _historyService;

  Language _sourceLanguage = Language.supportedLanguages[0]; // Auto
  Language _targetLanguage = Language.supportedLanguages[1]; // Vietnamese
  String _translatedText = '';
  bool _isTranslating = false;
  List<TranslationResult> _history = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initServices();
  }

  Future<void> _initServices() async {
    final prefs = await SharedPreferences.getInstance();
    _historyService = TranslationHistoryService(prefs);
    _history = _historyService.getHistory();
    await _ttsService.initialize();
    await _sttService.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _ttsService.dispose();
    _sttService.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    if (_sourceController.text.trim().isEmpty) return;

    setState(() {
      _isTranslating = true;
      _translatedText = '';
    });

    try {
      final result = await _translationService.translate(
        text: _sourceController.text,
        from: _sourceLanguage.code,
        to: _targetLanguage.code,
      );

      setState(() {
        _translatedText = result.translatedText;
        _isTranslating = false;
      });

      // Save to history
      await _historyService.addToHistory(result);
      _history = _historyService.getHistory();
    } catch (e) {
      setState(() {
        _isTranslating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Translation failed: $e')));
      }
    }
  }

  Future<void> _speakSource() async {
    if (_sourceController.text.isEmpty) return;
    try {
      await _ttsService.speak(
        _sourceController.text,
        _sourceLanguage.code == 'auto' ? 'en' : _sourceLanguage.code,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('TTS failed: $e')));
      }
    }
  }

  Future<void> _speakTranslated() async {
    if (_translatedText.isEmpty) return;
    try {
      await _ttsService.speak(_translatedText, _targetLanguage.code);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('TTS failed: $e')));
      }
    }
  }

  Future<void> _startListening() async {
    try {
      await _sttService.startListening(
        languageCode: _sourceLanguage.code == 'auto'
            ? 'en'
            : _sourceLanguage.code,
        onResult: (text) {
          setState(() {
            _sourceController.text = text;
          });
        },
      );
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Speech recognition failed: $e')),
        );
      }
    }
  }

  Future<void> _stopListening() async {
    await _sttService.stopListening();
    setState(() {});
    // Auto translate after speech input
    if (_sourceController.text.isNotEmpty) {
      await _translate();
    }
  }

  void _swapLanguages() {
    if (_sourceLanguage.code == 'auto') return;

    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;

      // Swap texts
      final tempText = _sourceController.text;
      _sourceController.text = _translatedText;
      _translatedText = tempText;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        title: const Text('Dịch thuật'),
        backgroundColor: const Color(0xFF1A1F2E),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00BFA5),
          labelColor: const Color(0xFF00BFA5),
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.translate), text: 'Translate'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTranslateTab(), _buildHistoryTab()],
      ),
    );
  }

  Widget _buildTranslateTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Language selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1F2E), Color(0xFF151920)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildLanguageSelector(
                    label: 'From',
                    language: _sourceLanguage,
                    onChanged: (lang) {
                      setState(() {
                        _sourceLanguage = lang;
                      });
                    },
                    showAutoDetect: true,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, color: Color(0xFF00BFA5)),
                  onPressed: _swapLanguages,
                  tooltip: 'Swap languages',
                ),
                Expanded(
                  child: _buildLanguageSelector(
                    label: 'To',
                    language: _targetLanguage,
                    onChanged: (lang) {
                      setState(() {
                        _targetLanguage = lang;
                      });
                    },
                    showAutoDetect: false,
                  ),
                ),
              ],
            ),
          ),

          // Source text input
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00BFA5).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _sourceController,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter text to translate...',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    suffixIcon: _sourceController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.white54,
                            ),
                            onPressed: () {
                              setState(() {
                                _sourceController.clear();
                                _translatedText = '';
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                Divider(color: Colors.white24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Microphone button
                    IconButton(
                      icon: Icon(
                        _sttService.isListening ? Icons.mic : Icons.mic_none,
                        color: _sttService.isListening
                            ? Colors.red
                            : const Color(0xFF00BFA5),
                      ),
                      onPressed: _sttService.isListening
                          ? _stopListening
                          : _startListening,
                      tooltip: 'Voice input',
                    ),
                    // Speak button
                    IconButton(
                      icon: const Icon(
                        Icons.volume_up,
                        color: Color(0xFF00BFA5),
                      ),
                      onPressed: _sourceController.text.isEmpty
                          ? null
                          : _speakSource,
                      tooltip: 'Speak',
                    ),
                    // Copy button
                    IconButton(
                      icon: const Icon(Icons.copy, color: Color(0xFF00BFA5)),
                      onPressed: _sourceController.text.isEmpty
                          ? null
                          : () => _copyToClipboard(_sourceController.text),
                      tooltip: 'Copy',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Translate button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTranslating ? null : _translate,
                icon: _isTranslating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.translate),
                label: Text(_isTranslating ? 'Translating...' : 'Translate'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF00BFA5),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),

          // Translated text
          if (_translatedText.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00BFA5).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    _translatedText,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const Divider(color: Colors.white24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Speak button
                      IconButton(
                        icon: const Icon(
                          Icons.volume_up,
                          color: Color(0xFF00BFA5),
                        ),
                        onPressed: _speakTranslated,
                        tooltip: 'Speak translation',
                      ),
                      // Copy button
                      IconButton(
                        icon: const Icon(Icons.copy, color: Color(0xFF00BFA5)),
                        onPressed: () => _copyToClipboard(_translatedText),
                        tooltip: 'Copy translation',
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.white.withOpacity(0.38),
            ),
            const SizedBox(height: 16),
            Text(
              'No translation history',
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Clear history button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_history.length} translations',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1F2E),
                      title: const Text(
                        'Clear history',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        'Are you sure you want to clear all translation history?',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await _historyService.clearHistory();
                    setState(() {
                      _history = [];
                    });
                  }
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  'Clear all',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.white.withOpacity(0.12)),
        Expanded(
          child: ListView.builder(
            itemCount: _history.length,
            itemBuilder: (context, index) {
              final item = _history[index];
              return _buildHistoryItem(item, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(TranslationResult item, int index) {
    final sourceLanguage = Language.getLanguageByCode(item.sourceLanguage);
    final targetLanguage = Language.getLanguageByCode(item.targetLanguage);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1A1F2E),
      child: InkWell(
        onTap: () {
          // Load into translator
          _tabController.animateTo(0);
          setState(() {
            _sourceController.text = item.originalText;
            _translatedText = item.translatedText;
            if (sourceLanguage != null) _sourceLanguage = sourceLanguage;
            if (targetLanguage != null) _targetLanguage = targetLanguage;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${sourceLanguage?.flag ?? '🌐'} ${sourceLanguage?.code.toUpperCase() ?? 'AUTO'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  Text(
                    '${targetLanguage?.flag ?? '🌐'} ${targetLanguage?.code.toUpperCase() ?? ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(item.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.54),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    color: Colors.red,
                    onPressed: () async {
                      await _historyService.removeFromHistory(index);
                      setState(() {
                        _history = _historyService.getHistory();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.originalText,
                style: const TextStyle(fontSize: 14, color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Divider(height: 16, color: Colors.white.withOpacity(0.12)),
              Text(
                item.translatedText,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF00BFA5),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector({
    required String label,
    required Language language,
    required Function(Language) onChanged,
    bool showAutoDetect = false,
  }) {
    return InkWell(
      onTap: () => _showLanguagePicker(
        title: label,
        current: language,
        onChanged: onChanged,
        showAutoDetect: showAutoDetect,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(language.flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                language.nativeName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker({
    required String title,
    required Language current,
    required Function(Language) onChanged,
    bool showAutoDetect = false,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1F2E),
      builder: (context) {
        final languages = showAutoDetect
            ? Language.supportedLanguages
            : Language.supportedLanguages
                  .where((lang) => lang.code != 'auto')
                  .toList();

        return ListView.builder(
          itemCount: languages.length,
          itemBuilder: (context, index) {
            final lang = languages[index];
            final isSelected = lang.code == current.code;

            return ListTile(
              leading: Text(lang.flag, style: const TextStyle(fontSize: 24)),
              title: Text(
                lang.nativeName,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                lang.name,
                style: TextStyle(color: Colors.white.withOpacity(0.6)),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Color(0xFF00BFA5))
                  : null,
              selected: isSelected,
              onTap: () {
                Navigator.pop(context);
                onChanged(lang);
              },
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
