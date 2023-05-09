import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// https://github.com/imaNNeo/fl_chart/blob/master/repo_files/documentations/line_chart.md
// fl_charts line-chart documentation ↑

class LineGraph extends StatefulWidget {
  const LineGraph({Key? key}) : super(key: key);

  @override
  State<LineGraph> createState() => _LineGraphState();
}

class _LineGraphState extends State<LineGraph> {
  @override
  Widget build(BuildContext context) {
    // Raw data
    List<double> temperature = [
      3.69,
      3.43,
      3.56,
      3.99,
      2.89,
      4.08,
      4.43,
      4.21,
      4.29,
      4.11,
      4.01,
      2.61,
      2.52,
      6.5,
      4.53,
      4.34,
      2.85,
      2.16,
      2.49,
      5.8
    ];
    List<double> humidity = [
      3.02,
      5.46,
      4.61,
      6.88,
      1.37,
      7.45,
      0.32,
      2.55,
      2.03,
      2.75,
      9.06,
      1.05,
      3.62,
      7.67,
      3.42,
      1.20,
      3.01,
      5.58,
      4.90,
      6.03
    ];
    List<double> time = [
      1646858397,
      1646934788,
      1646935084,
      1646936481,
      1646940403,
      1646980909,
      1646984407,
      1646985500,
      1647002715,
      1647031200,
      1647033917,
      1647053214,
      1647054561,
      1647070985,
      1647075350,
      1647076565,
      1647083145,
      1647090292,
      1647103899,
      1647105974
    ];

    // calculate min and max for left and right
    double tempMin = temperature.reduce((a, b) => a < b ? a : b);
    double tempMax = temperature.reduce((a, b) => a > b ? a : b);
    double humiMin = humidity.reduce((a, b) => a < b ? a : b);
    double humiMax = humidity.reduce((a, b) => a > b ? a : b);

    // create the humidity FlSpot points
    List<FlSpot> humiSpots = [];
    for (int i = 0; i < time.length; i++) {
      humiSpots.add(FlSpot(time[i], humidity[i]));
    }

    // create the temperature FlSpot points in the scale of humidity
    List<FlSpot> tempSpots = [];
    for (int i = 0; i < time.length; i++) {
      double calculatedTempSpot = (temperature[i] - tempMin) / (tempMax - tempMin) * (humiMax - humiMin) + humiMin;
      tempSpots.add(FlSpot(time[i], calculatedTempSpot));
    }

    return Container(
      height: 500,
      margin: const EdgeInsets.all(50),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: tempSpots,
              color: Colors.red,
              isCurved: false,
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              spots: humiSpots,
              color: Colors.blue,
              isCurved: false,
              dotData: FlDotData(show: false),
            ),
          ],
          minX: time.first,
          maxX: time.last,
          minY: 0,
          maxY: 100,
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                interval: 10,
                getTitlesWidget: (value, meta) {
                  return Text(
                    "$value %",
                    style: const TextStyle(color: Colors.blue),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 150,
                interval: (time.last - time.first) / 10, // divide x-axis titles for 10 sections
                getTitlesWidget: (value, meta) {
                  final date = DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000);
                  final formatter = DateFormat('MMM d, yyyy H:mm');
                  return RotatedBox(
                    quarterTurns: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        formatter.format(date),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 80,
                interval: 10,
                getTitlesWidget: (value, meta) {
                  double displayTemp = (value - humiMin) * (tempMax - tempMin) / (humiMax - humiMin) + tempMin;

                  return Text(
                    "${displayTemp.toStringAsFixed(2)} ℃",
                    style: const TextStyle(color: Colors.red),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(enabled: true),
        ),
      ),
    );
  }
}
