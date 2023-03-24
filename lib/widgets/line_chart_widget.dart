import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MoodPoint {
  final double x;
  final double y;

  MoodPoint({required this.x, required this.y});
}

List<MoodPoint> get moodPoints {
  final data = <double>[2, 4, 6, 11, 3, 6, 4];
  return data
      .mapIndexed(
          ((index, element) => MoodPoint(x: index.toDouble(), y: element)))
      .toList();
}

class LineChartWidget extends StatefulWidget {
  const LineChartWidget({required this.points, Key? key}) : super(key: key);

  final List<MoodPoint> points;

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: widget.points
                .map(
                  (point) => FlSpot(point.x, point.y),
                )
                .toList(),
          )
        ],
      ),
    );
  }
}
