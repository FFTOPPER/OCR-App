import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class TextAnalyzerPage extends StatefulWidget {
  const TextAnalyzerPage({Key? key}) : super(key: key);

  @override
  _TextAnalyzerPageState createState() => _TextAnalyzerPageState();
}

class _TextAnalyzerPageState extends State<TextAnalyzerPage> {
  final TextEditingController _textController = TextEditingController();
  String analysisResult = "";

  void analyzeText() {
    String text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        analysisResult = "No text provided for analysis.";
      });
      return;
    }

    List<String> words = text.split(RegExp(r'\s+'));
    int wordCount = words.length;
    int lineCount = text.split('\n').length;

    // Count frequency of words
    Map<String, int> freqMap = {};
    for (var word in words) {
      String w = word.toLowerCase();
      freqMap[w] = (freqMap[w] ?? 0) + 1;
    }

    // Sort by frequency
    var sortedWords = freqMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    String topWords = sortedWords.take(5).map((e) => "${e.key} (${e.value})").join(", ");

    setState(() {
      analysisResult =
      "Word Count: $wordCount\nLine Count: $lineCount\nTop Words: $topWords";
    });
  }

  Future<void> saveAnalysis() async {
    if (analysisResult.isEmpty) return;

    final directory = await getExternalStorageDirectory();
    if (directory == null) return;

    final file = File("${directory.path}/Text_Analysis.txt");
    await file.writeAsString("Text:\n${_textController.text}\n\nAnalysis:\n$analysisResult");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Analysis saved at: ${file.path}")),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Text Analyzer"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Paste your OCR text here...",
                ),
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: analyzeText,
              child: const Text("Analyze Text"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 10),
            if (analysisResult.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  analysisResult,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: saveAnalysis,
              child: const Text("Save Analysis as .txt"),
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
