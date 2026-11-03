import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() => runApp(const ExcelFinderApp());

class ExcelFinderApp extends StatelessWidget {
  const ExcelFinderApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Excel Data Finder',
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF123B67))),
    home: const DashboardPage(),
  );
}

class LocalStore {
  static Database? _db;
  static Future<Database> get db async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'excel_finder_local.db');
    _db = await openDatabase(path, version: 1, onCreate: (d, v) async {
      await d.execute('CREATE TABLE files(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE, imported_at TEXT)');
      await d.execute('CREATE TABLE records(id INTEGER PRIMARY KEY AUTOINCREMENT, file_id INTEGER, sheet_name TEXT, row_json TEXT)');
    });
    return _db!;
  }

  static Future<List<Map<String,Object?>>> files() async => (await db).query('files', orderBy: 'id DESC');
  static Future<int> count() async {
    final r = await (await db).rawQuery('SELECT COUNT(*) n FROM records');
    return (r.first['n'] as int?) ?? 0;
  }
  static Future<void> importExcel(String name, List<Map<String,dynamic>> rows) async {
    final d = await db;
    await d.transaction((txn) async {
      final existing = await txn.query('files', where: 'name=?', whereArgs: [name]);
      int fileId;
      if (existing.isNotEmpty) {
        fileId = existing.first['id'] as int;
        await txn.delete('records', where: 'file_id=?', whereArgs: [fileId]);
      } else {
        fileId = await txn.insert('files', {'name': name, 'imported_at': DateTime.now().toIso8601String()});
      }
      final batch = txn.batch();
      for (final row in rows) {
        batch.insert('records', {'file_id': fileId, 'sheet_name': row['sheet'] ?? '', 'row_json': jsonEncode(row['cells'])});
      }
      await batch.commit(noResult: true);
    });
  }
  static Future<List<Map<String,dynamic>>> search(String query) async {
    final d = await db;
    final data = await d.rawQuery('SELECT records.row_json, records.sheet_name, files.name file_name FROM records JOIN files ON files.id=records.file_id');
    final q = query.toLowerCase().replaceAll(RegExp(r'[\s\-]'), '');
    return data.map((r) {
      final cells = (jsonDecode(r['row_json'] as String) as List).map((e)=>e.toString()).toList();
      return {'cells':cells, 'sheet':r['sheet_name'], 'file':r['file_name']};
    }).where((r) => (r['cells'] as List<String>).any((v) => v.toLowerCase().replaceAll(RegExp(r'[\s\-]'), '').contains(q))).toList();
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}
class _DashboardPageState extends State<DashboardPage> {
  final search = TextEditingController();
  List<Map<String,Object?>> files = [];
  List<Map<String,dynamic>> results = [];
  int total = 0;
  bool busy = false;
  bool urdu = false;

  @override void initState() { super.initState(); _refresh(); }
  @override void dispose() { search.dispose(); super.dispose(); }
  Future<void> _refresh() async {
    final f = await LocalStore.files(); final c = await LocalStore.count();
    if (mounted) setState(() { files=f; total=c; });
  }
  Future<void> _import() async {
    try {
      final picked = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx'], withData: true);
      if (picked == null || picked.files.isEmpty) return;
      final file = picked.files.first;
      if (file.bytes == null) throw Exception('File bytes could not be read. Please select the file again.');
      setState(()=>busy=true);
      final workbook = Excel.decodeBytes(file.bytes!);
      final rows = <Map<String,dynamic>>[];
      for (final sheetName in workbook.tables.keys) {
        final sheet = workbook.tables[sheetName];
        if (sheet == null) continue;
        for (final row in sheet.rows) {
          final cells = row.map((c) => c?.value?.toString() ?? '').toList();
          if (cells.any((v)=>v.trim().isNotEmpty)) rows.add({'sheet':sheetName,'cells':cells});
        }
      }
      if (rows.isEmpty) throw Exception('Excel file has no readable rows.');
      await LocalStore.importExcel(file.name, rows);
      await _refresh();
      if (mounted) _message('${file.name}: ${rows.length} rows saved on this phone.');
    } catch(e) { if (mounted) _message('Import failed: $e'); }
    finally { if (mounted) setState(()=>busy=false); }
  }
  Future<void> _search(String q) async {
    if(q.trim().isEmpty) { setState(()=>results=[]); return; }
    final r=await LocalStore.search(q.trim());
    if(mounted) setState(()=>results=r);
  }
  void _message(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(m)));

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: const Color(0xFF123B67),foregroundColor:Colors.white,title:Text(urdu?'ایکسل ڈیٹا فائنڈر':'Excel Data Finder'),actions:[IconButton(onPressed:()=>setState(()=>urdu=!urdu),icon:const Icon(Icons.language))]),
    body: ListView(padding:const EdgeInsets.all(16),children:[
      Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(urdu?'ریکارڈ تلاش کریں':'Search Records',style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
        const SizedBox(height:10),
        TextField(controller:search,onChanged:_search,decoration:InputDecoration(prefixIcon:const Icon(Icons.search),hintText:urdu?'موبائل نمبر یا CNIC درج کریں':'Enter Mobile Number or CNIC',border:const OutlineInputBorder())),
      ]))),
      const SizedBox(height:12),
      Row(children:[Expanded(child:_stat('Excel Files','${files.length}',Icons.folder)),const SizedBox(width:10),Expanded(child:_stat('Total Records','$total',Icons.table_rows))]),
      const SizedBox(height:12),
      Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(urdu?'Excel فائلیں':'Excel Files',style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
        const SizedBox(height:10),
        FilledButton.icon(onPressed:busy?null:_import,icon:busy?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.upload_file),label:Text(busy?'Importing...':'Import Excel (.xlsx)')),
        if(files.isEmpty) const Padding(padding:EdgeInsets.all(12),child:Text('No Excel files imported yet.')),
        ...files.map((f)=>ListTile(leading:const Icon(Icons.description),title:Text(f['name'].toString()),subtitle:Text('Imported ${f['imported_at']}'))),
      ]))),
      if(results.isNotEmpty) ...[
        const SizedBox(height:12),Text('Search results: ${results.length}',style:const TextStyle(fontWeight:FontWeight.bold)),
        ...results.take(100).map((r)=>Card(child:ExpansionTile(title:Text(r['cells'].join('  |  '),maxLines:2,overflow:TextOverflow.ellipsis),subtitle:Text('File: ${r['file']}  •  Sheet: ${r['sheet']}'),children:[Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[for(int i=0;i<(r['cells'] as List).length;i++) Text('${i+1}. ${(r['cells'] as List)[i]}')]))]))),
      ] else if(search.text.isNotEmpty) const Padding(padding:EdgeInsets.all(12),child:Text('No matching records found.')),
    ]),
  );
  Widget _stat(String title,String value,IconData icon)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(icon),Text(value,style:const TextStyle(fontSize:25,fontWeight:FontWeight.bold)),Text(title)])));
}
