import 'package:flutter/material.dart';
import 'package:kanji_mobile_app/core/network/api_client.dart';
import 'package:kanji_mobile_app/features/admin/services/admin_api_service.dart';
import 'package:kanji_mobile_app/features/admin/models/admin_models.dart';

class AdminPublishRequestDetailPage extends StatefulWidget {
  final ApiClient apiClient;
  final PublishRequest request;

  const AdminPublishRequestDetailPage({
    super.key,
    required this.apiClient,
    required this.request,
  });

  @override
  State<AdminPublishRequestDetailPage> createState() =>
      _AdminPublishRequestDetailPageState();
}

class _AdminPublishRequestDetailPageState
    extends State<AdminPublishRequestDetailPage> {
  late final AdminApiService _adminApiService;
  bool _isLoading = true;
  bool _isReviewing = false;
  String? _error;

  PublishRequest? _fullRequest;

  @override
  void initState() {
    super.initState();
    _adminApiService = AdminApiService(widget.apiClient);
    _loadRequestDetail();
  }

  Future<void> _loadRequestDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final request = await _adminApiService.getPublishRequestById(
        widget.request.id,
        widget.request.type,
      );

      setState(() {
        _fullRequest = request;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _reviewRequest(String status) async {
    final messageController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildReviewDialog(status, messageController),
    );

    if (confirmed != true) return;

    setState(() => _isReviewing = true);

    try {
      await _adminApiService.reviewPublishRequest(
        id: widget.request.id,
        type: widget.request.type,
        status: status,
        reviewMessage: messageController.text.trim().isEmpty
            ? null
            : messageController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'approved'
                  ? 'Request approved successfully!'
                  : 'Request rejected',
            ),
            backgroundColor: status == 'approved'
                ? Colors.tealAccent
                : Colors.redAccent,
          ),
        );

        // Return true to indicate the request was reviewed
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() => _isReviewing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to review request: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
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
              _buildAppBar(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _error != null
                    ? _buildErrorState()
                    : _buildContent(),
              ),
              if (widget.request.status == 'pending' && !_isReviewing)
                _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00BFA5), Color(0xFF1DE9B6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTypeIcon(widget.request.type),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Review & Approve',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          _buildStatusBadge(widget.request.status),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.tealAccent),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Error Loading Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadRequestDetail,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              foregroundColor: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(),
        const SizedBox(height: 16),
        _buildAuthorCard(),
        const SizedBox(height: 16),
        _buildContentCard(),
        if (widget.request.reviewedAt != null) ...[
          const SizedBox(height: 16),
          _buildReviewInfoCard(),
        ],
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Colors.tealAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Request Information',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Title', widget.request.title),
          const SizedBox(height: 12),
          _buildInfoRow('Type', widget.request.typeLabel),
          const SizedBox(height: 12),
          _buildInfoRow('Requested At', _formatDate(widget.request.createdAt)),
        ],
      ),
    );
  }

  Widget _buildAuthorCard() {
    final user = widget.request.user;
    if (user == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Created By',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  user.name ?? user.email,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user.name != null)
                  Text(
                    user.email,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.article, color: Colors.tealAccent, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Content Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContentDetails(),
        ],
      ),
    );
  }

  Widget _buildContentDetails() {
    final request = _fullRequest ?? widget.request;

    if (request.quiz != null) {
      final quiz = request.quiz as Map<String, dynamic>;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Title', quiz['title'] ?? 'Untitled'),
          const SizedBox(height: 12),
          _buildInfoRow('Description', quiz['description'] ?? 'No description'),
          const SizedBox(height: 12),
          _buildInfoRow('Difficulty', quiz['difficulty'] ?? 'Unknown'),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Questions',
            (quiz['questions'] as List?)?.length.toString() ?? '0',
          ),
        ],
      );
    }

    return const Text(
      'Content details not available',
      style: TextStyle(
        color: Colors.white60,
        fontSize: 14,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildReviewInfoCard() {
    final reviewer = widget.request.reviewer;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.request.status == 'approved'
              ? Colors.tealAccent.withOpacity(0.3)
              : Colors.redAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.request.status == 'approved'
                    ? Icons.check_circle
                    : Icons.cancel,
                color: widget.request.status == 'approved'
                    ? Colors.tealAccent
                    : Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.request.status == 'approved' ? 'Approved' : 'Rejected',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (reviewer != null) ...[
            _buildInfoRow('Reviewed By', reviewer.email),
            const SizedBox(height: 12),
          ],
          _buildInfoRow('Reviewed At', _formatDate(widget.request.reviewedAt!)),
          if (widget.request.reviewMessage != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow('Message', widget.request.reviewMessage!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F2E),
        border: Border(top: BorderSide(color: Color(0xFF2A2F3E), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _reviewRequest('rejected'),
              icon: const Icon(Icons.cancel),
              label: const Text('Reject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.redAccent, width: 1),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _reviewRequest('approved'),
              icon: const Icon(Icons.check_circle),
              label: const Text('Approve'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.tealAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.tealAccent, width: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewDialog(String status, TextEditingController controller) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1F2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            status == 'approved' ? Icons.check_circle : Icons.cancel,
            color: status == 'approved' ? Colors.tealAccent : Colors.redAccent,
          ),
          const SizedBox(width: 12),
          Text(
            status == 'approved' ? 'Approve Request' : 'Reject Request',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Are you sure you want to ${status == 'approved' ? 'approve' : 'reject'} this publish request?',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Add a message (optional)',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF0F1419),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.tealAccent,
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: status == 'approved'
                ? Colors.tealAccent
                : Colors.redAccent,
            foregroundColor: Colors.black87,
          ),
          child: Text(status == 'approved' ? 'Approve' : 'Reject'),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'pending':
        color = Colors.orangeAccent;
        icon = Icons.pending;
        break;
      case 'approved':
        color = Colors.tealAccent;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.redAccent;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'quiz':
        return Icons.quiz;
      case 'list':
        return Icons.list;
      case 'deck':
        return Icons.style;
      default:
        return Icons.article;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
