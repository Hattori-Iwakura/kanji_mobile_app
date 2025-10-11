import 'package:flutter/material.dart';
import '../../data/repositories/kanji_repository_hybrid.dart';

class SyncStatusWidget extends StatefulWidget {
  final KanjiRepositoryHybrid repository;

  const SyncStatusWidget({Key? key, required this.repository})
    : super(key: key);

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  bool _isOnline = false;
  int _localCount = 0;
  int _pendingSync = 0;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _updateStatus();
  }

  Future<void> _updateStatus() async {
    final isOnline = await widget.repository.isOnline();
    final localCount = await widget.repository.getLocalKanjiCount();
    final pendingSync = await widget.repository.getPendingSyncCount();

    if (mounted) {
      setState(() {
        _isOnline = isOnline;
        _localCount = localCount;
        _pendingSync = pendingSync;
      });
    }
  }

  Future<void> _syncFromRemote() async {
    setState(() => _isSyncing = true);

    try {
      await widget.repository.syncFromRemote();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sync from remote successful!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $e'), backgroundColor: Colors.red),
      );
    }

    setState(() => _isSyncing = false);
    _updateStatus();
  }

  Future<void> _syncToRemote() async {
    setState(() => _isSyncing = true);

    try {
      await widget.repository.syncToRemote();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sync to remote successful!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $e'), backgroundColor: Colors.red),
      );
    }

    setState(() => _isSyncing = false);
    _updateStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: _isOnline ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isOnline ? Colors.green : Colors.orange,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _updateStatus,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh Status',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Local Kanjis: $_localCount'),
            if (_pendingSync > 0)
              Text(
                'Pending Sync: $_pendingSync',
                style: const TextStyle(color: Colors.orange),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSyncing ? null : _syncFromRemote,
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: const Text('Sync From Remote'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSyncing || _pendingSync == 0
                        ? null
                        : _syncToRemote,
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload),
                    label: const Text('Sync To Remote'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
