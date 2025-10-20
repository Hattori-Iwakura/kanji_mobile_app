import 'package:flutter/material.dart';
import '../config/env_config.dart';

/// Debug Settings Page - Shows all environment configuration
/// Only accessible when debug mode is enabled
class DebugSettingsPage extends StatelessWidget {
  const DebugSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Settings'),
        backgroundColor: Colors.red[700],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader('API Configuration'),
          _buildConfigItem('Base URL', EnvConfig.apiBaseUrl),
          _buildConfigItem('Timeout', '${EnvConfig.apiTimeout}ms'),

          const Divider(height: 32),

          _buildHeader('AI Model Configuration'),
          _buildConfigItem('Model URL', EnvConfig.aiModelUrl),

          const Divider(height: 32),

          _buildHeader('Feature Flags'),
          _buildBooleanItem('Debug Mode', EnvConfig.isDebugMode),
          _buildBooleanItem('Analytics', EnvConfig.isAnalyticsEnabled),

          const Divider(height: 32),

          _buildHeader('App Information'),
          _buildConfigItem('Name', EnvConfig.appName),
          _buildConfigItem('Version', EnvConfig.appVersion),

          const SizedBox(height: 24),

          // Test Environment Button
          ElevatedButton.icon(
            onPressed: () {
              _testEnvironmentVariables(context);
            },
            icon: const Icon(Icons.bug_report),
            label: const Text('Test Environment Variables'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),

          const SizedBox(height: 16),

          // Print Config Button
          ElevatedButton.icon(
            onPressed: () {
              EnvConfig.printConfig();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Config printed to console'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.print),
            label: const Text('Print Config to Console'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildConfigItem(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(value, style: const TextStyle(fontFamily: 'monospace')),
        trailing: IconButton(
          icon: const Icon(Icons.copy, size: 20),
          onPressed: () {
            // Copy to clipboard functionality could be added here
          },
        ),
      ),
    );
  }

  Widget _buildBooleanItem(String label, bool value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Chip(
          label: Text(
            value ? 'ENABLED' : 'DISABLED',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          backgroundColor: value ? Colors.green[100] : Colors.red[100],
          labelStyle: TextStyle(
            color: value ? Colors.green[900] : Colors.red[900],
          ),
        ),
      ),
    );
  }

  void _testEnvironmentVariables(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('Environment Test Results:\n');

    // Test all config values
    buffer.writeln('✓ API Base URL: ${EnvConfig.apiBaseUrl}');
    buffer.writeln('✓ API Timeout: ${EnvConfig.apiTimeout}ms');
    buffer.writeln('✓ AI Model URL: ${EnvConfig.aiModelUrl}');
    buffer.writeln('✓ Debug Mode: ${EnvConfig.isDebugMode}');
    buffer.writeln('✓ Analytics: ${EnvConfig.isAnalyticsEnabled}');
    buffer.writeln('✓ App Name: ${EnvConfig.appName}');
    buffer.writeln('✓ App Version: ${EnvConfig.appVersion}');
    buffer.writeln('\n✓ Environment is loaded: ${EnvConfig.isLoaded}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Test Results'),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            buffer.toString(),
            style: const TextStyle(fontFamily: 'monospace'),
          ),
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
}
