import 'dart:html';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_chart/data.dart';

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
    // Initial Data
    List<ChartData> data = initialData;

    // Humidity chart should display from 0% to 100%
    const double humidityFixedUpperLimit = 100;
    const double humidityFixedLowerLimit = 0;

    // Colors for the lines
    const temperatureColor = Color(0xFFFF9800);
    const humidityColor = Color(0xff03A9F4);

    // The UpperLimit and LowerLimit can vary according to the Logger
    double tempUpperLimit = 8;
    double tempLowerLimit = 2;
    // Calculate the min & max to display in chart
    double calculatedTempMax = 6; //tempUpperLimit + (tempUpperLimit - tempLowerLimit) / 2;
    double calculatedTempMin = 0; //tempLowerLimit - (tempUpperLimit - tempLowerLimit) / 2;

    // Converts the temperature into a value that is compared to the humidity scale
    double convertTemperatureValue(double temperature) {
      return (temperature - calculatedTempMin) / (calculatedTempMax - calculatedTempMin) * (humidityFixedUpperLimit - humidityFixedLowerLimit) + humidityFixedLowerLimit;
    }

    // Converts converted temperature into display value that is according to the original temperature
    double displayTemperatureValue(double convertedTemperature) {
      return (convertedTemperature - humidityFixedLowerLimit) / (humidityFixedUpperLimit - humidityFixedLowerLimit) * (calculatedTempMax - calculatedTempMin) + calculatedTempMin;
    }

    String unixToDateTime({required int unixStamp, required String dateFormat}) {
      final date = DateTime.fromMillisecondsSinceEpoch(unixStamp * 1000);
      final formatter = DateFormat(dateFormat);
      return formatter.format(date);
    }

    // create the humidity FlSpot points
    List<FlSpot> humiSpots = [];
    for (int i = 0; i < data.length; i++) {
      humiSpots.add(FlSpot(double.parse(data[i].unixTime.toString()), data[i].humidity));
    }

    // create the temperature FlSpot points
    List<FlSpot> tempSpots = [];
    for (int i = 0; i < data.length; i++) {
      tempSpots.add(FlSpot(double.parse(data[i].unixTime.toString()), convertTemperatureValue(data[i].temperature)));
    }

    return Container(
      height: 500,
      margin: const EdgeInsets.all(50),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: tempSpots,
              color: temperatureColor,
              isCurved: false,
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              spots: humiSpots,
              color: humidityColor,
              isCurved: false,
              dotData: FlDotData(show: false),
            ),
          ],
          minX: double.parse(data.first.unixTime.toString()),
          maxX: double.parse(data.last.unixTime.toString()),
          minY: humidityFixedLowerLimit,
          maxY: humidityFixedUpperLimit,
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(
              axisNameWidget: const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text("Humidity"),
              ),
              axisNameSize: 40,
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                interval: 10,
                getTitlesWidget: (value, meta) {
                  return Text(
                    " $value %",
                    style: const TextStyle(color: humidityColor),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 150,
                getTitlesWidget: (value, meta) {
                  return RotatedBox(
                    quarterTurns: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        unixToDateTime(
                          unixStamp: value.toInt(),
                          dateFormat: 'MMM d, yyyy H:mm',
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text("Temperature"),
              ),
              axisNameSize: 40,
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  return Text(
                    "${displayTemperatureValue(value).toStringAsFixed(2)} ℃",
                    style: const TextStyle(color: temperatureColor),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              maxContentWidth: 150,
              tooltipMargin: 32,
              fitInsideVertically: true,
              tooltipHorizontalAlignment: FLHorizontalAlignment.right,
              tooltipHorizontalOffset: 16,
              getTooltipItems: (touchedSpots) {
                List<LineTooltipItem> toolTipList = [];

                toolTipList.add(LineTooltipItem(
                  "${unixToDateTime(unixStamp: touchedSpots[0].x.toInt(), dateFormat: "yyyy-MMM-dd, hh:mm")} \n Temperature: ${displayTemperatureValue(touchedSpots[0].y).toStringAsFixed(1)} ℃",
                  const TextStyle(color: Colors.white),
                ));

                toolTipList.add(LineTooltipItem(
                  "Humidity: ${touchedSpots[1].y} %",
                  const TextStyle(color: Colors.white),
                ));

                return toolTipList;
              },
            ),
            getTouchedSpotIndicator: (LineChartBarData barData, List<int> indicators) {
              return indicators.map(
                (int index) {
                  final line = FlLine(
                    color: Colors.grey,
                    strokeWidth: 3,
                  );
                  return TouchedSpotIndicatorData(
                    line,
                    FlDotData(),
                  );
                },
              ).toList();
            },
          ),
        ),
      ),
    );
  }
}
