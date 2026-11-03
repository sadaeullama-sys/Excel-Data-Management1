import 'package:flutter/material.dart';

void main() {
  runApp(const ExcelFinderApp());
}

class ExcelFinderApp extends StatelessWidget {
  const ExcelFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Excel Data Finder',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF123B67),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController searchController = TextEditingController();

  bool urduMode = false;
  String searchText = '';

  String get appTitle =>
      urduMode ? 'ایکسل ڈیٹا فائنڈر' : 'Excel Data Finder';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF123B67),
        foregroundColor: Colors.white,
        title: Text(appTitle),
        actions: [
          IconButton(
            tooltip: 'Language / زبان',
            onPressed: () {
              setState(() {
                urduMode = !urduMode;
              });
            },
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _welcomeCard(),
            const SizedBox(height: 18),
            _searchSection(),
            const SizedBox(height: 18),
            _statsSection(),
            const SizedBox(height: 18),
            _excelFilesSection(),
            const SizedBox(height: 18),
            _backupSection(),
          ],
        ),
      ),
    );
  }

  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF123B67),
            Color(0xFF1E6B91),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            urduMode ? 'خوش آمدید' : 'Welcome',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            urduMode
                ? 'اپنی Excel فائلوں میں موبائل نمبر اور CNIC تلاش کریں۔'
                : 'Find mobile numbers and CNIC records in your Excel files.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              urduMode ? 'ریکارڈ تلاش کریں' : 'Search Records',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: searchController,
              keyboardType: TextInputType.text,
              onChanged: (value) {
                setState(() {
                  searchText = value.trim();
                });
              },
              decoration: InputDecoration(
                hintText: urduMode
                    ? 'موبائل نمبر یا CNIC درج کریں'
                    : 'Enter Mobile Number or CNIC',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
              ),
            ),
            const SizedBox(height: 12),
            if (searchText.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4D8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  urduMode
                      ? 'سرچ: $searchText\nExcel ڈیٹا امپورٹ کرنے کے بعد نتائج یہاں دکھائی دیں گے۔'
                      : 'Search: $searchText\nResults will appear here after Excel data is imported.',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          urduMode ? 'ڈیش بورڈ' : 'Dashboard',
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.folder,
                title: urduMode ? 'Excel فائلیں' : 'Excel Files',
                value: '0',
                color: const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                icon: Icons.table_rows,
                title: urduMode ? 'کل ریکارڈز' : 'Total Records',
                value: '0',
                color: const Color(0xFF059669),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _excelFilesSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              urduMode ? 'Excel فائلیں' : 'Excel Files',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Icon(
                Icons.insert_drive_file_outlined,
                size: 52,
                color: Color(0xFF7B8794),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                urduMode
                    ? 'ابھی کوئی Excel فائل شامل نہیں'
                    : 'No Excel files added yet',
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  _showMessage(
                    urduMode
                        ? 'Excel امپورٹ کا فیچر اگلے مرحلے میں شامل ہوگا۔'
                        : 'Excel import will be added in the next step.',
                  );
                },
                icon: const Icon(Icons.upload_file),
                label: Text(
                  urduMode ? 'Excel فائل امپورٹ کریں' : 'Import Excel File',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backupSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE0F2FE),
          child: Icon(
            Icons.backup,
            color: Color(0xFF0369A1),
          ),
        ),
        title: Text(
          urduMode ? 'مقامی بیک اپ' : 'Local Backup',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          urduMode
              ? 'ڈیٹا کا بیک اپ اور ریسٹور'
              : 'Backup and restore your local data',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          _showMessage(
            urduMode
                ? 'بیک اپ کا فیچر اگلے مرحلے میں شامل ہوگا۔'
                : 'Backup will be added in the next step.',
          );
        },
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
