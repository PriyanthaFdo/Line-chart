import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_chart/data.dart';
import 'package:line_chart/slider.dart';

/// Created By Priyantha Fernando on 10-05-2023

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
    double height = 600;
    EdgeInsets? padding = const EdgeInsets.all(50);

    // The limit ranges defined for highlighting as requried
    const double leftUpperLimit = 8;
    const double leftLowerLimit = 2;

    // The min and max of the chart
    const double leftMax = 6; /*leftUpperLimit + 5;  (leftUpperLimit - leftLowerLimit) / 2;*/
    const double leftMin = 0; /*leftLowerLimit - /*5; */ (leftUpperLimit - leftLowerLimit) / 2;*/
    const double rightMax = 100;
    const double rightMin = 0;

    // Colors for the lines
    const leftColor = Color(0xFFFF9800);
    const rightColor = Color(0xff03A9F4);

    // Converts the left into a value that is in the right scale
    double convertLeftValue(double val) {
      return (val - leftMin) / (leftMax - leftMin) * (rightMax - rightMin) + rightMin;
    }

    // Re-converts left value to original value for display purposes
    double reConvertLeftValue(double val) {
      return (val - rightMin) / (rightMax - rightMin) * (leftMax - leftMin) + leftMin;
    }

    // Convert a unix dateTime stamp into readable text in given format
    String unixToDateTimeString({required int unixStamp, required String dateFormat}) {
      final date = DateTime.fromMillisecondsSinceEpoch(unixStamp * 1000);
      final formatter = DateFormat(dateFormat);
      return formatter.format(date);
    }

    // Create the right FlSpot points
    List<FlSpot> rightSpots = [];
    for (int i = 0; i < data.length; i++) {
      rightSpots.add(FlSpot(double.parse(data[i].unixTime.toString()), data[i].right));
    }

    // Create the left FlSpot points
    List<FlSpot> leftSpots = [];
    for (int i = 0; i < data.length; i++) {
      leftSpots.add(FlSpot(double.parse(data[i].unixTime.toString()), convertLeftValue(data[i].left)));
    }

    // Create the left upperLimit FlSpot points
    List<FlSpot> leftUpperLimitSpots = [];
    for (int i = 0; i < data.length; i++) {
      leftUpperLimitSpots.add(FlSpot(data[i].unixTime.toDouble(), convertLeftValue(leftUpperLimit)));
    }

    // Create the left lowerLimit FlSpot points
    List<FlSpot> leftLowerLimitSpots = [];
    for (int i = 0; i < data.length; i++) {
      leftLowerLimitSpots.add(FlSpot(data[i].unixTime.toDouble(), convertLeftValue(leftLowerLimit)));
    }

    return Column(
      children: [
        Container(
          height: height,
          padding: padding,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: leftSpots,
                  color: leftColor,
                  isCurved: false,
                  dotData: FlDotData(show: false),
                  barWidth: 1,
                ),
                LineChartBarData(
                  spots: rightSpots,
                  color: rightColor,
                  isCurved: false,
                  dotData: FlDotData(show: false),
                  barWidth: 1,
                ),

                // Following 2 LineChartBarData are created to draw the limit horizontal lines
                LineChartBarData(
                  show: false,
                  spots: leftUpperLimitSpots,
                  color: leftColor,
                  isCurved: false,
                  dotData: FlDotData(show: false),
                  barWidth: 1,
                ),
                LineChartBarData(
                  show: false,
                  spots: leftLowerLimitSpots,
                  color: leftColor,
                  isCurved: false,
                  dotData: FlDotData(show: false),
                  barWidth: 1,
                ),
              ],
              betweenBarsData: [
                BetweenBarsData(
                  fromIndex: 2,
                  toIndex: 3,
                  color: leftColor.withOpacity(0.25),
                )
              ],
              clipData: FlClipData.all(),
              minX: data.first.unixTime.toDouble(),
              maxX: data.last.unixTime.toDouble(),
              minY: rightMin,
              maxY: rightMax,
              titlesData: FlTitlesData(
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(
                  axisNameWidget: const Text("Humidity"),
                  axisNameSize: 18,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    interval: 10,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        " $value %",
                        style: const TextStyle(color: rightColor),
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
                            unixToDateTimeString(
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
                        "${reConvertLeftValue(value).toStringAsFixed(2)} ℃",
                        style: const TextStyle(color: leftColor),
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
                  fitInsideHorizontally: true,
                  tooltipHorizontalAlignment: FLHorizontalAlignment.right,
                  tooltipHorizontalOffset: 16,
                  getTooltipItems: (touchedSpots) {
                    List<LineTooltipItem> toolTipList = [];

                    toolTipList.add(LineTooltipItem(
                      "${unixToDateTimeString(unixStamp: touchedSpots[0].x.toInt(), dateFormat: "yyyy-MMM-dd, hh:mm")} \n Temperature: ${reConvertLeftValue(touchedSpots[0].y).toStringAsFixed(1)} ℃",
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
        ),
        ChartSlider(
          min: data.first.unixTime,
          max: data.last.unixTime,
          onChanged: (RangeValues value) {},
          onChangeEnd: (RangeValues value) {},
        ),
      ],
    );
  }
}
