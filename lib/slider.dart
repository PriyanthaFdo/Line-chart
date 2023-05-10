import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChartSlider extends StatefulWidget {
  final int min;
  final int max;
  final ValueChanged<RangeValues> onChanged;
  final ValueChanged<RangeValues> onChangeEnd;

  const ChartSlider({
    super.key,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  State<ChartSlider> createState() => _ChartSliderState();
}

class _ChartSliderState extends State<ChartSlider> {
  RangeValues _values = const RangeValues(0, 1);

  @override
  void initState() {
    super.initState();
    _values = RangeValues(widget.min.toDouble(), widget.max.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    String unixToDateTime({required int unixStamp, required String dateFormat}) {
      final date = DateTime.fromMillisecondsSinceEpoch(unixStamp * 1000);
      final formatter = DateFormat(dateFormat);
      return formatter.format(date);
    }

    return Column(
      children: [
        RangeSlider(
          min: widget.min.toDouble(),
          max: widget.max.toDouble(),
          values: _values,
          onChanged: (values) {
            setState(() {
              _values = values;
            });
            widget.onChanged(values);
          },
          onChangeEnd: (values) {
            widget.onChangeEnd(values);
          },
        ),
        Text("Start: ${unixToDateTime(unixStamp: _values.start.toInt(), dateFormat: "MMM dd, yyyy H:mm")}, End: ${unixToDateTime(unixStamp: _values.end.toInt(), dateFormat: "MMM dd, yyyy H:mm")} ")
      ],
    );
  }
}
