import 'dart:math';
import 'package.chetegram/services/firestore_service.dart';
import 'package.fl_chart/fl_chart.dart';
import 'package.flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<Map<String, double>> _subjectDataFuture;
  late Future<int> _totalTopicsFuture;
  late Future<int> _completedTopicsFuture;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  void _loadAnalyticsData() {
    setState(() {
      _subjectDataFuture = _firestoreService.getTasksCountBySubject();
      _totalTopicsFuture = _firestoreService.getTasksCount();
      // Completed tasks ke liye hum getCompletedTasks ka count lenge
      _completedTopicsFuture = _firestoreService.getCompletedTasks().then((list) => list.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress 📊'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalyticsData,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Stats Cards ---
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total Topics',
                  future: _totalTopicsFuture,
                  icon: Icons.topic,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Mastered',
                  future: _completedTopicsFuture,
                  icon: Icons.star,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- Pie Chart Card ---
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subject Distribution',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: FutureBuilder<Map<String, double>>(
                      future: _subjectDataFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No data for chart.'));
                        }
                        return PieChart(
                          PieChartData(
                            sections: _generatePieChartSections(snapshot.data!),
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // पाई-चार्ट के सेक्शन बनाने का फंक्शन
  List<PieChartSectionData> _generatePieChartSections(Map<String, double> data) {
    final List<Color> colors = Colors.primaries;
    int colorIndex = 0;
    
    return data.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${entry.key}\n(${entry.value.toInt()})',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    }).toList();
  }

  // स्टैट्स कार्ड बनाने के लिए एक हेल्पर विजेट
  Widget _buildStatCard({
    required String title,
    required Future<int> future,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            FutureBuilder<int>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 28, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
                }
                return Text(
                  (snapshot.data ?? 0).toString(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
