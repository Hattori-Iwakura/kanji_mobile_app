import 'package:flutter/material.dart';

/// Admin Kanji Management Page with CRUD operations
class AdminKanjiPage extends StatefulWidget {
  const AdminKanjiPage({super.key});

  @override
  State<AdminKanjiPage> createState() => _AdminKanjiPageState();
}

class _AdminKanjiPageState extends State<AdminKanjiPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  // Mock kanji data
  List<Map<String, dynamic>> _kanjis = [
    {
      'id': '1',
      'character': '日',
      'meanings': ['sun', 'day'],
      'onReading': ['ニチ', 'ジツ'],
      'kunReading': ['ひ', 'か'],
      'jlptLevel': 'N5',
      'grade': 1,
      'strokeCount': 4,
      'frequency': 1,
    },
    {
      'id': '2',
      'character': '月',
      'meanings': ['moon', 'month'],
      'onReading': ['ゲツ', 'ガツ'],
      'kunReading': ['つき'],
      'jlptLevel': 'N5',
      'grade': 1,
      'strokeCount': 4,
      'frequency': 2,
    },
    {
      'id': '3',
      'character': '火',
      'meanings': ['fire'],
      'onReading': ['カ'],
      'kunReading': ['ひ', 'ほ'],
      'jlptLevel': 'N5',
      'grade': 1,
      'strokeCount': 4,
      'frequency': 3,
    },
    {
      'id': '4',
      'character': '水',
      'meanings': ['water'],
      'onReading': ['スイ'],
      'kunReading': ['みず'],
      'jlptLevel': 'N5',
      'grade': 1,
      'strokeCount': 4,
      'frequency': 4,
    },
    {
      'id': '5',
      'character': '木',
      'meanings': ['tree', 'wood'],
      'onReading': ['モク', 'ボク'],
      'kunReading': ['き', 'こ'],
      'jlptLevel': 'N5',
      'grade': 1,
      'strokeCount': 4,
      'frequency': 5,
    },
  ];

  List<Map<String, dynamic>> get _filteredKanjis {
    var kanjis = _kanjis;

    // Apply filter
    if (_selectedFilter != 'All') {
      kanjis = kanjis.where((k) => k['jlptLevel'] == _selectedFilter).toList();
    }

    // Apply search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      kanjis = kanjis.where((k) {
        final character = k['character'] as String;
        final meanings = (k['meanings'] as List).join(' ').toLowerCase();
        return character.contains(query) || meanings.contains(query);
      }).toList();
    }

    return kanjis;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Kanji Management',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddKanjiDialog,
          ),
          IconButton(
            icon: const Icon(Icons.file_upload, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bulk Import - Coming Soon'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(child: _buildKanjiList()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search kanji or meanings...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white.withOpacity(0.5),
              ),
              filled: true,
              fillColor: Colors.black,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('N5'),
                _buildFilterChip('N4'),
                _buildFilterChip('N3'),
                _buildFilterChip('N2'),
                _buildFilterChip('N1'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        backgroundColor: Colors.black,
        selectedColor: Colors.blue.withOpacity(0.3),
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue : Colors.white.withOpacity(0.7),
        ),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.white.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildKanjiList() {
    final kanjis = _filteredKanjis;

    if (kanjis.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No kanji found',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: kanjis.length,
      itemBuilder: (context, index) {
        final kanji = kanjis[index];
        return _buildKanjiCard(kanji);
      },
    );
  }

  Widget _buildKanjiCard(Map<String, dynamic> kanji) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Kanji Character
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                kanji['character'],
                style: const TextStyle(fontSize: 48, color: Colors.white),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Kanji Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meanings
                Text(
                  (kanji['meanings'] as List).join(', '),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Readings
                Text(
                  'On: ${(kanji['onReading'] as List).join(', ')}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Kun: ${(kanji['kunReading'] as List).join(', ')}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 8),

                // Tags
                Wrap(
                  spacing: 8,
                  children: [
                    _buildTag(kanji['jlptLevel'], Colors.blue),
                    _buildTag('Grade ${kanji['grade']}', Colors.purple),
                    _buildTag('${kanji['strokeCount']} strokes', Colors.orange),
                  ],
                ),
              ],
            ),
          ),

          // Actions Menu
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.7)),
            color: const Color(0xFF2A2A2A),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text('Edit', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                _showEditKanjiDialog(kanji);
              } else if (value == 'delete') {
                _showDeleteConfirmation(kanji);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAddKanjiDialog() {
    final characterController = TextEditingController();
    final meaningsController = TextEditingController();
    final onReadingController = TextEditingController();
    final kunReadingController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Add New Kanji',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: characterController,
                style: const TextStyle(color: Colors.white, fontSize: 32),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Kanji Character',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: meaningsController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Meanings (comma-separated)',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: onReadingController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'On Reading (comma-separated)',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: kunReadingController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Kun Reading (comma-separated)',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () {
              // Add kanji logic here
              setState(() {
                _kanjis.add({
                  'id': DateTime.now().toString(),
                  'character': characterController.text,
                  'meanings': meaningsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .toList(),
                  'onReading': onReadingController.text
                      .split(',')
                      .map((e) => e.trim())
                      .toList(),
                  'kunReading': kunReadingController.text
                      .split(',')
                      .map((e) => e.trim())
                      .toList(),
                  'jlptLevel': 'N5',
                  'grade': 1,
                  'strokeCount': 4,
                  'frequency': _kanjis.length + 1,
                });
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kanji added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditKanjiDialog(Map<String, dynamic> kanji) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Edit Kanji', style: TextStyle(color: Colors.white)),
        content: Text(
          'Edit functionality coming soon for ${kanji['character']}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> kanji) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Delete Kanji',
          style: TextStyle(color: Colors.white),
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.white),
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(
                text: kanji['character'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: '?\n\nThis action cannot be undone.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _kanjis.removeWhere((k) => k['id'] == kanji['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kanji deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
