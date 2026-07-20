import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  File? _selectedImage;
  String? _base64Image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _base64Image = base64Encode(File(pickedFile.path).readAsBytesSync());
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? savedIp = prefs.getString('server_ip');

    if (savedIp == null || savedIp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set the server IP in settings')),
      );
      return;
    }

    final String endpoint = "$savedIp/api/image";

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"image": _base64Image}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Image')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 200)
                : Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(child: Text('No image selected')),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo),
                  label: const Text("Gallery"),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: const Text('Submit'),
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
