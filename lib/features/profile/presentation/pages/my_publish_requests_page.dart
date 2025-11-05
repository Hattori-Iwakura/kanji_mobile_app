import 'package:flutter/material.dart';
import 'package:kanji_mobile_app/core/network/api_client.dart';

class MyPublishRequestsPage extends StatefulWidget {
  final ApiClient apiClient;

  const MyPublishRequestsPage({super.key, required this.apiClient});

  @override
  State<MyPublishRequestsPage> createState() => _MyPublishRequestsPageState();
}

class _MyPublishRequestsPageState extends State<MyPublishRequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;

  List<PublishRequestItem> _quizRequests = [];
  List<PublishRequestItem> _listRequests = [];
  List<PublishRequestItem> _deckRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load Kanji List publish requests
      final listResponse = await widget.apiClient.dio.get(
        '/kanji-lists/my-publish-requests',
      );
      final listData = listResponse.data['data'] as List;
      _listRequests = listData
          .map((json) => PublishRequestItem.fromJson(json, 'list'))
          .toList();

      // TODO: Load Quiz publish requests when backend is ready
      // For now, show empty
      _quizRequests = [];
      _deckRequests = [];

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading publish requests: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF071126), Color(0xFF0B0F14)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'My Publish Requests',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white70),
                      onPressed: _loadRequests,
                    ),
                  ],
                ),
              ),

              // Tab Bar
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.tealAccent,
                labelColor: Colors.tealAccent,
                unselectedLabelColor: Colors.white54,
                tabs: const [
                  Tab(text: 'Quizzes'),
                  Tab(text: 'Lists'),
                  Tab(text: 'Decks'),
                ],
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.tealAccent,
                        ),
                      )
                    : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error: $_error',
                              style: const TextStyle(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadRequests,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildRequestsList(_quizRequests, 'quiz'),
                          _buildRequestsList(_listRequests, 'list'),
                          _buildRequestsList(_deckRequests, 'deck'),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsList(List<PublishRequestItem> requests, String type) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'quiz'
                  ? Icons.quiz
                  : type == 'list'
                  ? Icons.list
                  : Icons.style,
              size: 64,
              color: Colors.white30,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${type}es submitted for publishing',
              style: const TextStyle(color: Colors.white60, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Create and submit a ${type} to see it here',
              style: const TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      color: Colors.tealAccent,
      backgroundColor: const Color(0xFF1A1F2E),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildRequestCard(PublishRequestItem request) {
    Color statusColor;
    IconData statusIcon;

    switch (request.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        request.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (request.description != null) ...[
              const SizedBox(height: 8),
              Text(
                request.description!,
                style: const TextStyle(color: Colors.white60, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  'Submitted ${_formatDate(request.createdAt)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                if (request.reviewedAt != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.rate_review,
                    size: 14,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Reviewed ${_formatDate(request.reviewedAt!)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            if (request.reviewNote != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.comment, size: 16, color: statusColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.reviewNote!,
                        style: TextStyle(color: statusColor, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Temporary model - should be moved to proper models file
class PublishRequestItem {
  final int id;
  final String title;
  final String? description;
  final String status;
  final String type;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewNote;

  PublishRequestItem({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.type,
    required this.createdAt,
    this.reviewedAt,
    this.reviewNote,
  });

  factory PublishRequestItem.fromJson(Map<String, dynamic> json, String type) {
    return PublishRequestItem(
      id: json['id'] as int,
      title: json['list']?['name'] ?? json['quiz']?['title'] ?? 'Untitled',
      description: json['list']?['description'] ?? json['quiz']?['description'],
      status: json['status'] as String,
      type: type,
      createdAt: DateTime.parse(json['createdAt'] as String),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
      reviewNote: json['message'] as String?,
    );
  }
}
