import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'config.dart';

class VitalsChartPage extends StatefulWidget {
  final int patientId;
  final String vitalType;

  const VitalsChartPage({
    super.key,
    required this.patientId,
    required this.vitalType,
  });

  @override
  State<VitalsChartPage> createState() => _VitalsChartPageState();
}

class _VitalsChartPageState extends State<VitalsChartPage> {
  List vitals = [];
  
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getVitalsHistory();
  }

  Future<void> getVitalsHistory() async {
    try {
      final response = await http.get(
        Uri.parse(
  "${AppConfig.baseUrl}/api/get_vitals_history.php?patient_id=${widget.patientId}",
        ),
      );
      final data = jsonDecode(response.body);
      if (data["success"] == true) {
        setState(() {
          vitals = data["data"];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2))
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // الهيدر
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.vitalType.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // كارت المنحنى
                      Container(
                        height: 300,
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(10, 25, 25, 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.08),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: LineChart(mainData()),
                      ),

                      const SizedBox(height: 40),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          "Analysis Summary",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ========== بطاقات الإحصائيات الرئيسية ==========
                      Row(
                        children: [
                          _buildStatCard(
                            title: "Current",
                            value: _getCurrentValue(),
                            unit: _getUnit(),
                            icon: Icons.trending_up,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            title: "Average",
                            value: _getAverageValue(),
                            unit: _getUnit(),
                            icon: Icons.show_chart,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            title: "Highest",
                            value: _getMaxValue(),
                            unit: _getUnit(),
                            icon: Icons.arrow_upward,
                            color: const Color.fromARGB(255, 255, 0, 0),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ========== بطاقة النطاق الصحي والاستقرار ==========
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Healthy Range",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _getHealthyRange(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getStatusMessage(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _getStatusColor(),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 50,
                              color: Colors.grey.shade200,
                            ),
                            Expanded(
                              child: Center(
                                child: Column(
                                  children: [
                                    Text(
                                      "Stability",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Icon(
                                      _getStabilityIcon(),
                                      color: _getStabilityColor(),
                                      size: 32,
                                    ),
                                    Text(
                                      _getStabilityText(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _getStabilityColor(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  LineChartData mainData() {
    double minY = 0;
    double maxY = 100;

    if (vitals.isNotEmpty) {
      List<double> values = vitals
          .map((e) => double.tryParse(e[widget.vitalType].toString()) ?? 0.0)
          .toList();
      minY = values.reduce((a, b) => a < b ? a : b) - 3;
      maxY = values.reduce((a, b) => a > b ? a : b) + 3;
    }

    return LineChartData(
      minY: minY,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: (maxY - minY) / 5,
        verticalInterval: vitals.length > 6 ? (vitals.length / 6) : 1,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.black.withOpacity(0.04),
          strokeWidth: 0.5,
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: Colors.black.withOpacity(0.04),
          strokeWidth: 0.5,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            interval: vitals.length > 4 ? (vitals.length / 4).floorToDouble() : 1,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index < 0 || index >= vitals.length) return const SizedBox();
              
              DateTime dt = DateTime.parse(vitals[index]["recorded_at"]);
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w600),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: vitals.asMap().entries.map((entry) {
            double y = double.tryParse(entry.value[widget.vitalType].toString()) ?? 0;
            return FlSpot(entry.key.toDouble(), y);
          }).toList(),
          isCurved: true,
          curveSmoothness: 0.4,
          color: Colors.green,
          barWidth: 3.5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.green.withOpacity(0.06),
                Colors.green.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (spot) => Colors.black,
          getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
            "${s.y.toInt()}",
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          )).toList(),
        ),
      ),
    );
  }

  // ========== دوال مساعدة للتحليلات ==========

  String _getCurrentValue() {
    if (vitals.isEmpty) return "--";
    return vitals.last[widget.vitalType].toString();
  }

  String _getUnit() {
    switch (widget.vitalType) {
      case "temperature":
        return "°C";
      case "heart_rate":
        return "BPM";
      case "spo2":
        return "%";
      default:
        return "";
    }
  }

  String _getAverageValue() {
    if (vitals.isEmpty) return "--";
    double sum = 0;
    for (var vital in vitals) {
      sum += double.tryParse(vital[widget.vitalType].toString()) ?? 0;
    }
    return (sum / vitals.length).toStringAsFixed(1);
  }

  String _getMaxValue() {
    if (vitals.isEmpty) return "--";
    double max = 0;
    for (var vital in vitals) {
      double value = double.tryParse(vital[widget.vitalType].toString()) ?? 0;
      if (value > max) max = value;
    }
    return max.toStringAsFixed(1);
  }

  String _getHealthyRange() {
    switch (widget.vitalType) {
      case "temperature":
        return "36.1°C - 37.2°C";
      case "heart_rate":
        return "60 - 100 BPM";
      case "spo2":
        return "95% - 100%";
      default:
        return "N/A";
    }
  }

  String _getStatusMessage() {
    double current = double.tryParse(_getCurrentValue()) ?? 0;
    
    if (widget.vitalType == "temperature") {
      if (current >= 36.1 && current <= 37.2) return "✓ Within healthy range";
      return "⚠️ Outside healthy range";
    } else if (widget.vitalType == "heart_rate") {
      if (current >= 60 && current <= 100) return "✓ Within healthy range";
      return "⚠️ Outside healthy range";
    } else if (widget.vitalType == "spo2") {
      if (current >= 95) return "✓ Within healthy range";
      return "⚠️ Below healthy range";
    }
    return "Monitoring";
  }

  Color _getStatusColor() {
    double current = double.tryParse(_getCurrentValue()) ?? 0;
    
    if (widget.vitalType == "temperature") {
      if (current >= 36.1 && current <= 37.2) return Colors.green.shade700;
      return Colors.orange.shade700;
    } else if (widget.vitalType == "heart_rate") {
      if (current >= 60 && current <= 100) return Colors.green.shade700;
      return Colors.orange.shade700;
    } else if (widget.vitalType == "spo2") {
      if (current >= 95) return Colors.green.shade700;
      return Colors.red.shade700;
    }
    return Colors.grey;
  }

  IconData _getStabilityIcon() {
    if (vitals.length < 2) return Icons.trending_flat;
    
    List<double> recentValues = vitals.take(5).map((e) => 
      double.tryParse(e[widget.vitalType].toString()) ?? 0
    ).toList();
    
    double avg = recentValues.reduce((a, b) => a + b) / recentValues.length;
    double stdDev = (recentValues.map((v) => (v - avg) * (v - avg)).reduce((a, b) => a + b) / recentValues.length).abs();
    
    if (stdDev < 2) return Icons.trending_flat;
    if (recentValues.first < recentValues.last) return Icons.trending_up;
    return Icons.trending_down;
  }

  Color _getStabilityColor() {
    if (vitals.length < 2) return Colors.grey;
    
    List<double> recentValues = vitals.take(5).map((e) => 
      double.tryParse(e[widget.vitalType].toString()) ?? 0
    ).toList();
    
    double avg = recentValues.reduce((a, b) => a + b) / recentValues.length;
    double stdDev = (recentValues.map((v) => (v - avg) * (v - avg)).reduce((a, b) => a + b) / recentValues.length).abs();
    
    if (stdDev < 2) return Colors.green;
    if (recentValues.first < recentValues.last) return Colors.orange;
    return Colors.blue;
  }

  String _getStabilityText() {
    if (vitals.length < 2) return "Insufficient";
    
    List<double> recentValues = vitals.take(5).map((e) => 
      double.tryParse(e[widget.vitalType].toString()) ?? 0
    ).toList();
    
    double avg = recentValues.reduce((a, b) => a + b) / recentValues.length;
    double stdDev = (recentValues.map((v) => (v - avg) * (v - avg)).reduce((a, b) => a + b) / recentValues.length).abs();
    
    if (stdDev < 2) return "Stable ✓";
    if (recentValues.first < recentValues.last) return "Increasing ↑";
    return "Decreasing ↓";
  }

  // دالة بناء بطاقة الإحصائيات
  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
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