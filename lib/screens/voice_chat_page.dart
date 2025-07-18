import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VoiceChatPage extends StatefulWidget {
  const VoiceChatPage({Key? key}) : super(key: key);

  @override
  State<VoiceChatPage> createState() => _VoiceChatPageState();
}

class _VoiceChatPageState extends State<VoiceChatPage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  bool _isLoading = false;
  String _userMessage = '';
  String _aiReply = '';
  String _partialResult = '';
  List<Map<String, String>> _chat = [];
  String _selectedLocaleId = 'en_US';
  final Map<String, String> _supportedLanguages = {
    'English': 'en_US',
    'Hindi': 'hi_IN',
    'Malayalam': 'ml_IN',
    // Add more languages as needed
  };

  Future<void> _toggleListening() async {
    if (_isListening) {
      // Stop listening and send message
      await _speech.stop();
      setState(() {
        _isListening = false;
        _userMessage = _partialResult;
        _partialResult = '';
      });
      if (_userMessage.trim().isNotEmpty) {
        setState(() {
          _chat.add({'user': _userMessage});
          _isLoading = true;
        });
        await _sendToWebhook(_userMessage);
      }
    } else {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _partialResult = '';
        });
        _speech.listen(
          localeId: _selectedLocaleId,
          onResult: (result) {
            setState(() {
              _partialResult = result.recognizedWords;
            });
          },
        );
      }
    }
  }

  Future<void> _sendToWebhook(String message) async {
    try {
      final response = await http.post(
        Uri.parse('https://razyeryt.app.n8n.cloud/webhook/native-language'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _aiReply = data['solution'] ?? '';
          _chat.add({'ai': _aiReply});
          _isLoading = false;
        });
        await _speak(_aiReply);
      } else {
        setState(() {
          _aiReply = 'Error: ${response.statusCode}';
          _chat.add({'ai': _aiReply});
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _aiReply = 'Error: $e';
        _chat.add({'ai': _aiReply});
        _isLoading = false;
      });
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Chat')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Language: ', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: _selectedLocaleId,
                  items: _supportedLanguages.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.value,
                      child: Text(entry.key),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLocaleId = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          if (_partialResult.isNotEmpty && _isListening)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                _partialResult,
                style: const TextStyle(fontSize: 18, color: Colors.black54, fontStyle: FontStyle.italic),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _chat.length,
              itemBuilder: (context, index) {
                final entry = _chat[index];
                if (entry.containsKey('user')) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Card(
                      color: Colors.blue[100],
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(entry['user']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                } else {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Card(
                      color: Colors.green[100],
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(entry['ai']!, style: const TextStyle(fontStyle: FontStyle.italic)),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: GestureDetector(
              onTap: _toggleListening,
              child: CircleAvatar(
                radius: 36,
                backgroundColor: _isListening ? Colors.red : Colors.blue,
                child: Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 