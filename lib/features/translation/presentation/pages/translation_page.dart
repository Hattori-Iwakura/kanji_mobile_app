import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:permission_handler/permission_handler.dart';

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
  bool _hasPermission = false;
  bool _isInitializing = false;
  String _selectedSourceLang = 'en';
  String _selectedTargetLang = 'ja';
  double _speechVolume = 1.0;
  double _speechRate = 0.5;
  String _recognizedText = '';
  String _detectedLanguage = '';
  int _retryCount = 0;
  final int _maxRetries = 3;

  // Tab Controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeTts();
    _checkPermissions();
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
    setState(() => _isInitializing = true);

    _speechToText = stt.SpeechToText();
    bool available = await _speechToText.initialize(
      onError: (error) {
        _handleSttError(error.errorMsg);
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );

    setState(() => _isInitializing = false);

    if (!available) {
      _showSnackBar('Speech recognition not available', Colors.orange);
    }
  }

  /// Check and request microphone permissions
  Future<void> _checkPermissions() async {
    final status = await Permission.microphone.status;

    if (status.isDenied) {
      final result = await Permission.microphone.request();
      setState(() => _hasPermission = result.isGranted);

      if (result.isPermanentlyDenied) {
        _showPermissionDialog();
      }
    } else if (status.isGranted) {
      setState(() => _hasPermission = true);
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog();
    }
  }

  /// Show dialog to open app settings for permissions
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Microphone Permission Required',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This app needs microphone access for speech recognition. Please enable it in settings.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Handle STT errors with retry mechanism
  void _handleSttError(String errorMsg) {
    setState(() => _isListening = false);

    if (_retryCount < _maxRetries) {
      _retryCount++;
      _showSnackBar(
        'Error: $errorMsg - Retry $_retryCount/$_maxRetries',
        Colors.orange,
      );

      // Auto-retry after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (!_isListening && _retryCount < _maxRetries) {
          _toggleListening();
        }
      });
    } else {
      _showSnackBar(
        'Speech recognition failed after $_maxRetries attempts',
        Colors.red,
      );
      _retryCount = 0; // Reset for next attempt
    }
  }

  /// Detect language from recognized text
  Future<String> _detectLanguage(String text) async {
    if (text.isEmpty) return '';

    // Simple heuristic detection
    // Check for Japanese characters (Hiragana, Katakana, Kanji)
    final japaneseRegex = RegExp(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]');
    // Check for Vietnamese diacritics
    final vietnameseRegex = RegExp(
      r'[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]',
    );
    // Check for Chinese characters
    final chineseRegex = RegExp(r'[\u4E00-\u9FFF]');
    // Check for Korean characters
    final koreanRegex = RegExp(r'[\uAC00-\uD7AF\u1100-\u11FF\u3130-\u318F]');

    if (japaneseRegex.hasMatch(text)) {
      return 'ja';
    } else if (vietnameseRegex.hasMatch(text.toLowerCase())) {
      return 'vi';
    } else if (koreanRegex.hasMatch(text)) {
      return 'ko';
    } else if (chineseRegex.hasMatch(text)) {
      return 'zh';
    } else {
      // Default to English for Latin characters
      return 'en';
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isListening
                  ? [Colors.red.shade800, Colors.red.shade600]
                  : _hasPermission
                  ? [Colors.blue.shade800, Colors.blue.shade600]
                  : [Colors.grey.shade800, Colors.grey.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Animated mic icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: _isListening ? 90 : 80,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                _isListening
                    ? 'Listening...'
                    : _hasPermission
                    ? 'Tap to speak'
                    : 'Permission needed',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              if (_isListening && _recognizedText.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _recognizedText,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main record button
                  ElevatedButton.icon(
                    onPressed: _hasPermission || !_isListening
                        ? _toggleListening
                        : _checkPermissions,
                    icon: Icon(_isListening ? Icons.stop : Icons.mic, size: 20),
                    label: Text(
                      _isListening
                          ? 'Stop'
                          : _hasPermission
                          ? 'Start Recording'
                          : 'Grant Permission',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _isListening ? Colors.red : Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),

                  if (!_isListening && _recognizedText.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    // Retry button
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _recognizedText = '';
                          _sourceController.clear();
                        });
                        _toggleListening();
                      },
                      icon: const Icon(Icons.refresh),
                      color: Colors.white,
                      iconSize: 32,
                      tooltip: 'Retry recording',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Language detection indicator
        if (_detectedLanguage.isNotEmpty &&
            _detectedLanguage != _selectedSourceLang)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.language, color: Colors.blue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Language Detected',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getLanguageName(_detectedLanguage),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedSourceLang = _detectedLanguage;
                      _detectedLanguage = '';
                    });
                    _updateTranslator();
                  },
                  child: const Text('Use this'),
                ),
              ],
            ),
          ),

        // Permission status indicator
        if (!_hasPermission && !_isInitializing)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Microphone permission is required for speech recognition',
                    style: TextStyle(color: Colors.orange, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
      ],
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
        }),
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
      setState(() {
        _isListening = false;
        _retryCount = 0; // Reset retry count
      });
    } else {
      // Check permission first
      if (!_hasPermission) {
        await _checkPermissions();
        if (!_hasPermission) {
          _showSnackBar('Microphone permission denied', Colors.red);
          return;
        }
      }

      // Reset retry count for new attempt
      _retryCount = 0;

      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);

        // Get available locales for debugging
        final locales = await _speechToText.locales();
        final supportedLocales = locales.map((l) => l.localeId).join(', ');
        debugPrint('Available locales: $supportedLocales');

        await _speechToText.listen(
          onResult: (result) async {
            final recognizedWords = result.recognizedWords;
            setState(() {
              _sourceController.text = recognizedWords;
              _recognizedText = recognizedWords;
            });

            // Auto-detect language
            if (recognizedWords.isNotEmpty && result.finalResult) {
              final detected = await _detectLanguage(recognizedWords);
              if (detected.isNotEmpty && detected != _selectedSourceLang) {
                setState(() => _detectedLanguage = detected);
                _showSnackBar(
                  'Detected language: ${_getLanguageName(detected)}',
                  Colors.blue,
                );
              }
            }
          },
          localeId: _getLocaleId(_selectedSourceLang),
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          onSoundLevelChange: (level) {
            // Visual feedback for sound level
            debugPrint('Sound level: $level');
          },
        );
      } else {
        _showSnackBar('Speech recognition not available', Colors.red);
      }
    }
  }

  /// Get locale ID for speech recognition
  String _getLocaleId(String langCode) {
    switch (langCode) {
      case 'en':
        return 'en_US';
      case 'ja':
        return 'ja_JP';
      case 'vi':
        return 'vi_VN';
      case 'zh':
        return 'zh_CN';
      case 'ko':
        return 'ko_KR';
      default:
        return 'en_US';
    }
  }

  /// Get language name for display
  String _getLanguageName(String langCode) {
    switch (langCode) {
      case 'en':
        return 'English';
      case 'ja':
        return 'Japanese (日本語)';
      case 'vi':
        return 'Vietnamese (Tiếng Việt)';
      case 'zh':
        return 'Chinese (中文)';
      case 'ko':
        return 'Korean (한국어)';
      default:
        return 'Unknown';
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
    if (_translatedController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _translatedController.text));
      _showSnackBar('Copied to clipboard', Colors.green);
    }
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
