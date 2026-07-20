import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';

class LanguageSelectorPage extends StatefulWidget {
  const LanguageSelectorPage({Key? key}) : super(key: key);

  @override
  _LanguageSelectorPageState createState() => _LanguageSelectorPageState();
}

class _LanguageSelectorPageState extends State<LanguageSelectorPage> {
  String? selectedLanguage;
  final TextEditingController _textController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;
  final FlutterTts flutterTts = FlutterTts();

  final Map<String, String> languageMap = {
    "English": "0",
    "Tamil": "1",
    "Hindi": "2",
  };

  final Map<String, String> ttsLanguageMap = {
    "English": "en-US",
    "Tamil": "ta-IN",
    "Hindi": "hi-IN",
  };

  Future<void> sendLanguageSelection() async {
    if (selectedLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a language")),
      );
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedIp = prefs.getString('server_ip');

      if (savedIp == null || savedIp.isEmpty) {
        setState(() {
          errorMessage = "Server IP is not set in settings.";
          isLoading = false;
        });
        return;
      }

      final url = Uri.parse('$savedIp/api/translate?lang=${languageMap[selectedLanguage]}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          String serverText = data['extracted_text'] ?? "";

          String cleanedText = serverText
              .split('\n')
              .map((line) => line.trimRight())
              .join('\n');

          setState(() {
            _textController.text = cleanedText;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? "Unknown error from server";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Failed to fetch data. Status: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  Future<void> saveAsTextFile() async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) return;

    String cleanedText = _textController.text
        .split('\n')
        .map((line) => line.trimRight())
        .join('\n');

    final file = File("${directory.path}/Language_Text.txt");
    await file.writeAsString(cleanedText);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Text saved at: ${file.path}")),
    );
  }

  Future<void> speakText() async {
    if (_textController.text.isEmpty || selectedLanguage == null) return;

    await flutterTts.setLanguage(ttsLanguageMap[selectedLanguage]!);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(_textController.text);
  }

  @override
  void dispose() {
    _textController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Language Selector"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedLanguage,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Select Language",
              ),
              items: languageMap.keys
                  .map((lang) => DropdownMenuItem(
                value: lang,
                child: Text(lang),
              ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedLanguage = val;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendLanguageSelection,
              child: const Text("Submit"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
                : Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "Translated text will appear here...",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.mic),
                    onPressed: speakText,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: saveAsTextFile,
              child: const Text("Save as .txt"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
