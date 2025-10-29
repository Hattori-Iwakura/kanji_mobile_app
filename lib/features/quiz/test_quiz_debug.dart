import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class QuizDebugPage extends StatefulWidget {
  const QuizDebugPage({super.key});

  @override
  State<QuizDebugPage> createState() => _QuizDebugPageState();
}

class _QuizDebugPageState extends State<QuizDebugPage> {
  String _output = 'Tap button to test API';
  bool _loading = false;

  Future<void> testQuizAPI() async {
    setState(() {
      _loading = true;
      _output = 'Loading...';
    });

    try {
      final dio = Dio();
      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Replace with your token
      final token = 'YOUR_TOKEN_HERE';
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.get('http://10.0.2.2:3000/api/quizzes');

      final data = response.data;
      debugPrint('🔍 Response type: ${data.runtimeType}');
      debugPrint('🔍 Response data: $data');

      if (data is Map<String, dynamic>) {
        debugPrint('✅ Response is Map');
        debugPrint('🔍 Keys: ${data.keys}');

        if (data.containsKey('data')) {
          final innerData = data['data'];
          debugPrint('🔍 Inner data type: ${innerData.runtimeType}');
          debugPrint('🔍 Inner data: $innerData');

          if (innerData is Map<String, dynamic>) {
            debugPrint('✅ Inner data is Map');
            debugPrint('🔍 Inner keys: ${innerData.keys}');

            if (innerData.containsKey('data')) {
              final quizList = innerData['data'];
              debugPrint('🔍 Quiz list type: ${quizList.runtimeType}');
              debugPrint('🔍 Quiz list length: ${quizList.length}');

              if (quizList is List) {
                debugPrint('✅ Quiz list is List');
                debugPrint('🔍 First item type: ${quizList.isNotEmpty ? quizList[0].runtimeType : "empty"}');
                debugPrint('🔍 First item: ${quizList.isNotEmpty ? quizList[0] : "empty"}');

                setState(() {
                  _output = 'SUCCESS!\n\n'
                      'Response is Map: ✅\n'
                      'Inner data is Map: ✅\n'
                      'Quiz list is List: ✅\n'
                      'Quiz count: ${quizList.length}\n\n'
                      'Structure:\n'
                      '- statusCode: ${data['statusCode']}\n'
                      '- data.total: ${innerData['total']}\n'
                      '- data.limit: ${innerData['limit']}\n'
                      '- data.offset: ${innerData['offset']}\n'
                      '- data.data: List with ${quizList.length} items\n\n'
                      'First quiz: ${quizList.isNotEmpty ? quizList[0]['title'] : "none"}';
                });
              } else {
                setState(() {
                  _output = 'ERROR: Quiz list is not List, it is ${quizList.runtimeType}';
                });
              }
            } else {
              setState(() {
                _output = 'ERROR: Inner data does not have "data" key. Keys: ${innerData.keys}';
              });
            }
          } else {
            setState(() {
              _output = 'ERROR: Inner data is not Map, it is ${innerData.runtimeType}';
            });
          }
        } else {
          setState(() {
            _output = 'ERROR: Response does not have "data" key. Keys: ${data.keys}';
          });
        }
      } else {
        setState(() {
          _output = 'ERROR: Response is not Map, it is ${data.runtimeType}';
        });
      }
    } catch (e, stack) {
      debugPrint('❌ ERROR: $e');
      debugPrint('Stack: $stack');
      setState(() {
        _output = 'ERROR:\n$e\n\nStack:\n$stack';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz API Debug'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _loading ? null : testQuizAPI,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Test Quiz API'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _output,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
