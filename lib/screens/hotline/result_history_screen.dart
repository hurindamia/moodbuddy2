import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class ResultHistoryScreen extends StatelessWidget {
  const ResultHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Self-Check History'),
      ),
      body: user == null
          ? const Center(child: Text('Please log in to view results.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('self_check_results')
                  .orderBy('date')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Text('No self-check results yet.'),
                  );
                }

                /* =========================
                   PREPARE TREND DATA
                ========================== */
                final spots = docs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value.data() as Map<String, dynamic>;
                  final percentage = (data['percentage'] ?? 0).toDouble();

                  return FlSpot(index.toDouble(), percentage);
                }).toList();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    /* =========================
                       TREND CHART (NEW)
                    ========================== */
                    const Text(
                      'Wellbeing Trend Over Time',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 220,
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: 100,
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 20,
                                reservedSize: 40,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    'Try ${value.toInt() + 1}',
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /* =========================
                       HISTORY LIST (OLD)
                    ========================== */
                    const Text(
                      'Past Results',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ...docs.reversed.map((d) {
                      final data =
                          d.data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          title: Text(
                            'Score: ${data['totalScore']} (${data['percentage'].toStringAsFixed(1)}%)',
                          ),
                          subtitle: Text(
                            (data['date'] as Timestamp)
                                .toDate()
                                .toString()
                                .substring(0, 16),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
    );
  }
}
