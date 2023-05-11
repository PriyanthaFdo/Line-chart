import 'package:flutter/material.dart';
import 'package:line_chart/data.dart';
import 'package:line_chart/slider.dart';

import 'graph.dart';

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

    return Column(
      children: [
        const Graph(),
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
