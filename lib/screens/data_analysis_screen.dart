import 'package:flutter/material.dart';
import '../services/user_data_service.dart';
import 'dart:convert';

class DataAnalysisScreen extends StatefulWidget {
  const DataAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<DataAnalysisScreen> createState() => _DataAnalysisScreenState();
}

class _DataAnalysisScreenState extends State<DataAnalysisScreen> {
  final UserDataService _userDataService = UserDataService();
  List<UserData> _userData = [];
  bool _isLoading = true;
  Map<String, int> _wordFrequency = {};
  int _totalMessages = 0;
  DateTime? _firstMessageDate;
  DateTime? _lastMessageDate;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await _userDataService.getUserData();

      // Process data for visualization
      if (userData.isNotEmpty) {
        _wordFrequency = _calculateWordFrequency(userData);
        _totalMessages = userData.length;

        // Sort messages by timestamp
        userData.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        _firstMessageDate =
            userData.isNotEmpty
                ? DateTime.parse(userData.first.timestamp)
                : null;
        _lastMessageDate =
            userData.isNotEmpty
                ? DateTime.parse(userData.last.timestamp)
                : null;
      }

      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    }
  }

  Map<String, int> _calculateWordFrequency(List<UserData> userData) {
    final Map<String, int> frequency = {};

    for (final data in userData) {
      final words = data.message.toLowerCase().split(RegExp(r'[^\w]+'))
        ..removeWhere((word) => word.isEmpty || word.length < 3);

      for (final word in words) {
        frequency[word] = (frequency[word] ?? 0) + 1;
      }
    }

    // Sort by frequency
    final sortedMap = Map.fromEntries(
      frequency.entries.toList()
        ..sort((e1, e2) => e2.value.compareTo(e1.value)),
    );

    // Take top 20 words
    return Map.fromEntries(sortedMap.entries.take(20));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Data Analysis'), elevation: 2),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _userData.isEmpty
              ? const Center(child: Text('No user data available for analysis'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(),
                    const SizedBox(height: 24),
                    _buildWordFrequencyChart(),
                    const SizedBox(height: 24),
                    _buildRawDataSection(),
                  ],
                ),
              ),
    );
  }

  Widget _buildSummaryCard() {
    final duration =
        _firstMessageDate != null && _lastMessageDate != null
            ? _lastMessageDate!.difference(_firstMessageDate!)
            : null;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildSummaryItem('Total Messages', '$_totalMessages'),
            _buildSummaryItem(
              'Collection Period',
              duration != null ? '${duration.inDays} days' : 'N/A',
            ),
            _buildSummaryItem(
              'First Message',
              _firstMessageDate != null
                  ? '${_firstMessageDate!.day}/${_firstMessageDate!.month}/${_firstMessageDate!.year}'
                  : 'N/A',
            ),
            _buildSummaryItem(
              'Most Recent Message',
              _lastMessageDate != null
                  ? '${_lastMessageDate!.day}/${_lastMessageDate!.month}/${_lastMessageDate!.year}'
                  : 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildWordFrequencyChart() {
    if (_wordFrequency.isEmpty) {
      return const SizedBox.shrink();
    }

    // Find max frequency for scaling
    final maxFrequency = _wordFrequency.values.reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Most Common Words',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 16),
            ..._wordFrequency.entries.take(10).map((entry) {
              // Calculate width percentage based on frequency
              final widthPercentage = entry.value / maxFrequency;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key} (${entry.value})',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 16,
                      width:
                          MediaQuery.of(context).size.width *
                          0.7 *
                          widthPercentage,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRawDataSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Messages',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _loadUserData,
                  child: const Row(
                    children: [
                      Icon(Icons.refresh, size: 16),
                      SizedBox(width: 4),
                      Text('Refresh'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            ..._userData.reversed.take(5).map((data) {
              final date = DateTime.parse(data.timestamp);
              final formattedDate =
                  '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(data.message),
                    const Divider(),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
