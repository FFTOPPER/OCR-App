import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OCRResultPage extends StatefulWidget {
  const OCRResultPage({Key? key}) : super(key: key);

  @override
  _OCRResultPageState createState() => _OCRResultPageState();
}

class _OCRResultPageState extends State<OCRResultPage> {
  String? extractedText;
  bool isLoading = true;
  String? errorMessage;

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchOCRResult();
  }

  Future<void> fetchOCRResult() async {
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

      final url = Uri.parse('$savedIp/api/image'); // Endpoint to fetch text
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            extractedText = data['extracted_text'];
            _textController.text = extractedText ?? "";
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

    // Clean the text: trim spaces and remove empty lines
    String cleanedText = _textController.text
        .split('\n')                        // Split by lines
        .map((line) => line.trimRight())    // Trim trailing spaces
        .join('\n');                        // Join back with single newline

    final file = File("${directory.path}/OCR_Result.txt");
    await file.writeAsString(cleanedText);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Text saved at: ${file.path}")),
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
        title: const Text("OCR Result"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(2, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "OCR text will appear here...",
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
      ),
    );
  }
}
