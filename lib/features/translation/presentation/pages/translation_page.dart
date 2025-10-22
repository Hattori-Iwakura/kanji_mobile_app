import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

/// Translation page with TTS, STT, and text translation
class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key});

  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage>
    with SingleTickerProviderStateMixin {
  // Controllers
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();

  // Services
  late FlutterTts _flutterTts;
  late stt.SpeechToText _speechToText;
  late OnDeviceTranslator _translator;

  // State
  bool _isListening = false;
  bool _isTranslating = false;
  bool _isSpeaking = false;
  String _selectedSourceLang = 'en';
  String _selectedTargetLang = 'ja';
  double _speechVolume = 1.0;
  double _speechRate = 0.5;

  // Tab Controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeTts();
    _initializeStt();
    _initializeTranslator();
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _translatedController.dispose();
    _flutterTts.stop();
    _translator.close();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage(_selectedTargetLang);
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(_speechVolume);

    _flutterTts.setStartHandler(() {
      setState(() => _isSpeaking = true);
    });

    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() => _isSpeaking = false);
      _showSnackBar('TTS Error: $msg', Colors.red);
    });
  }

  Future<void> _initializeStt() async {
    _speechToText = stt.SpeechToText();
    bool available = await _speechToText.initialize(
      onError: (error) {
        _showSnackBar('STT Error: ${error.errorMsg}', Colors.red);
        setState(() => _isListening = false);
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );

    if (!available) {
      _showSnackBar('Speech recognition not available', Colors.orange);
    }
  }

  Future<void> _initializeTranslator() async {
    _translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.japanese,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Translation', style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.5),
          tabs: const [
            Tab(icon: Icon(Icons.translate), text: 'Text Translation'),
            Tab(icon: Icon(Icons.mic), text: 'Voice'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTextTranslationTab(), _buildVoiceTab()],
      ),
    );
  }

  Widget _buildTextTranslationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Language selector
          _buildLanguageSelector(),

          const SizedBox(height: 20),

          // Source text input
          _buildSourceTextField(),

          const SizedBox(height: 20),

          // Translate button
          _buildTranslateButton(),

          const SizedBox(height: 20),

          // Translation result
          _buildTranslationResult(),

          const SizedBox(height: 20),

          // Quick phrases
          _buildQuickPhrases(),
        ],
      ),
    );
  }

  Widget _buildVoiceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // Voice input section
          _buildVoiceInputSection(),

          const SizedBox(height: 32),

          // TTS controls
          _buildTtsControls(),

          const SizedBox(height: 32),

          // Example phrases for TTS
          _buildTtsExamples(),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Source language
          Expanded(
            child: _buildLanguageDropdown(
              label: 'From',
              value: _selectedSourceLang,
              onChanged: (value) {
                setState(() => _selectedSourceLang = value!);
                _updateTranslator();
              },
            ),
          ),

          // Swap button
          IconButton(
            onPressed: _swapLanguages,
            icon: const Icon(Icons.swap_horiz, color: Colors.blue),
          ),

          // Target language
          Expanded(
            child: _buildLanguageDropdown(
              label: 'To',
              value: _selectedTargetLang,
              onChanged: (value) {
                setState(() => _selectedTargetLang = value!);
                _updateTranslator();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    final languages = {
      'en': 'English',
      'ja': '日本語',
      'vi': 'Tiếng Việt',
      'zh': '中文',
      'ko': '한국어',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
        const SizedBox(height: 4),
        DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          dropdownColor: const Color(0xFF1A1A1A),
          style: const TextStyle(color: Colors.white),
          underline: Container(),
          isExpanded: true,
          items: languages.entries.map((entry) {
            return DropdownMenuItem(value: entry.key, child: Text(entry.value));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSourceTextField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enter text',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_sourceController.text.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _sourceController.clear();
                        _translatedController.clear();
                      });
                    },
                    icon: Icon(
                      Icons.clear,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
              ],
            ),
          ),
          TextField(
            controller: _sourceController,
            maxLines: 5,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Type or paste text here...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslateButton() {
    return ElevatedButton.icon(
      onPressed: _sourceController.text.isEmpty || _isTranslating
          ? null
          : _translateText,
      icon: _isTranslating
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.translate),
      label: Text(_isTranslating ? 'Translating...' : 'Translate'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade800,
        disabledForegroundColor: Colors.white38,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size.fromHeight(50),
      ),
    );
  }

  Widget _buildTranslationResult() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Translation',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_translatedController.text.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _speakText(_translatedController.text),
                      icon: Icon(
                        _isSpeaking ? Icons.stop : Icons.volume_up,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: _copyTranslation,
                      icon: const Icon(Icons.copy, color: Colors.blue),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _translatedController,
            maxLines: 5,
            readOnly: true,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Translation will appear here...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPhrases() {
    final phrases = [
      {'en': 'Hello', 'ja': 'こんにちは'},
      {'en': 'Thank you', 'ja': 'ありがとうございます'},
      {'en': 'Excuse me', 'ja': 'すみません'},
      {'en': 'Good morning', 'ja': 'おはようございます'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Phrases',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: phrases.map((phrase) {
            return InkWell(
              onTap: () {
                _sourceController.text = phrase['en']!;
                _translateText();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Text(
                  phrase['en']!,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVoiceInputSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isListening
              ? [Colors.red.shade800, Colors.red.shade600]
              : [Colors.blue.shade800, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            size: 80,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          Text(
            _isListening ? 'Listening...' : 'Tap to speak',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _toggleListening,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _isListening ? Colors.red : Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              _isListening ? 'Stop' : 'Start Recording',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTtsControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Text-to-Speech Controls',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Volume slider
          Row(
            children: [
              const Icon(Icons.volume_up, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Volume: ${(_speechVolume * 100).toInt()}%',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                    Slider(
                      value: _speechVolume,
                      onChanged: (value) {
                        setState(() => _speechVolume = value);
                        _flutterTts.setVolume(value);
                      },
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Speed slider
          Row(
            children: [
              const Icon(Icons.speed, color: Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Speed: ${_speechRate.toStringAsFixed(1)}x',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                    Slider(
                      value: _speechRate,
                      min: 0.1,
                      max: 1.0,
                      onChanged: (value) {
                        setState(() => _speechRate = value);
                        _flutterTts.setSpeechRate(value);
                      },
                      activeColor: Colors.green,
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

  Widget _buildTtsExamples() {
    final examples = ['こんにちは', 'ありがとうございます', 'おはようございます', 'さようなら', '元気ですか？'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Try these phrases',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...examples.map((text) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: ListTile(
              title: Text(text, style: const TextStyle(color: Colors.white)),
              trailing: IconButton(
                onPressed: () => _speakText(text),
                icon: Icon(
                  _isSpeaking ? Icons.stop : Icons.play_arrow,
                  color: Colors.blue,
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Future<void> _translateText() async {
    if (_sourceController.text.isEmpty) return;

    setState(() => _isTranslating = true);

    try {
      final translatedText = await _translator.translateText(
        _sourceController.text,
      );
      setState(() {
        _translatedController.text = translatedText;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() => _isTranslating = false);
      _showSnackBar('Translation error: $e', Colors.red);
    }
  }

  Future<void> _speakText(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
    } else {
      await _flutterTts.speak(text);
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
    } else {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        await _speechToText.listen(
          onResult: (result) {
            setState(() {
              _sourceController.text = result.recognizedWords;
            });
          },
          localeId: _selectedSourceLang == 'en' ? 'en_US' : 'ja_JP',
        );
      }
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _selectedSourceLang;
      _selectedSourceLang = _selectedTargetLang;
      _selectedTargetLang = temp;

      final tempText = _sourceController.text;
      _sourceController.text = _translatedController.text;
      _translatedController.text = tempText;
    });
    _updateTranslator();
  }

  Future<void> _updateTranslator() async {
    await _translator.close();

    _translator = OnDeviceTranslator(
      sourceLanguage: _getTranslateLanguage(_selectedSourceLang),
      targetLanguage: _getTranslateLanguage(_selectedTargetLang),
    );

    await _flutterTts.setLanguage(_selectedTargetLang);
  }

  TranslateLanguage _getTranslateLanguage(String code) {
    switch (code) {
      case 'en':
        return TranslateLanguage.english;
      case 'ja':
        return TranslateLanguage.japanese;
      case 'vi':
        return TranslateLanguage.vietnamese;
      case 'zh':
        return TranslateLanguage.chinese;
      case 'ko':
        return TranslateLanguage.korean;
      default:
        return TranslateLanguage.english;
    }
  }

  void _copyTranslation() {
    // TODO: Implement clipboard copy
    _showSnackBar('Copied to clipboard', Colors.green);
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
