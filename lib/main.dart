import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'image_upload_page.dart';
import 'new.dart';
import 'ocr_result_page.dart';
import 'transaleted.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Upload & OCR',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomeTabs(),
    );
  }
}

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePageTabs(), // Centered 4 tabs
    HistoryPage(),
    SettingsPage(),
    PlaceholderPage(),
  ];

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'OCR App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "More"),
        ],
      ),
    );
  }
}

class HomePageTabs extends StatelessWidget {
  const HomePageTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GridView.count(
        shrinkWrap: true, // Take only necessary space
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildTabCard(
            icon: Icons.image,
            title: "Upload Image",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImageUploadPage()),
              );
            },
          ),
          _buildTabCard(
            icon: Icons.text_snippet,
            title: "OCR Output",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OCRResultPage()),
              );
            },
          ),
          _buildTabCard(
            icon: Icons.translate,
            title: "Translated Results",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LanguageSelectorPage()),
              );
            },
          ),
          _buildTabCard(
            icon: Icons.analytics,
            title: "Text Analyzer",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TextAnalyzerPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabCard({required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 6,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green[100],
                child: Icon(icon, size: 30, color: Colors.green[800]),
              ),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class OcrOutputPage extends StatelessWidget {
  const OcrOutputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildCard(
      icon: Icons.text_snippet,
      title: "OCR Output",
      description: "Once you upload and process the image,\nrecognized text will be displayed here.",
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildCard(
      icon: Icons.history,
      title: "Upload History",
      description: "This is where your previously uploaded images and results will appear.",
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedIP();
  }

  Future<void> _loadSavedIP() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ipController.text = prefs.getString('server_ip') ?? "";
    });
  }

  Future<void> _saveIP() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', _ipController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("IP Address Saved Successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.settings, size: 60, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                "Enter Server IP Address",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _ipController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  labelText: "Server IP (e.g., http://192.168.0.179:5000)",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveIP,
                icon: const Icon(Icons.save),
                label: const Text("Save IP"),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildCard(
      icon: Icons.dashboard,
      title: "More Features",
      description: "Future feature tabs can go here.",
    );
  }
}

Widget _buildCard({required IconData icon, required String title, required String description}) {
  return Center(
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.green[100],
              child: Icon(icon, size: 50, color: Colors.green[800]),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
