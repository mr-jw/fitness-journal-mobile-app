import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../themes/theme_provider.dart';

class Point {
  final double x;
  final double y;

  // define a point in the table.
  Point({required this.x, required this.y});
}

class LineChartWidget extends StatefulWidget {
  final List<Point> points;

  const LineChartWidget(this.points, {Key? key}) : super(key: key);

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  @override
  void initState() {
    super.initState();
  }

  double highestTally() {
    double result = 0.0;
    for (int i = 0; i < widget.points.length; i++) {
      if (result < widget.points[i].y) {
        result = widget.points[i].y;
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return AspectRatio(
      aspectRatio: 3,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: highestTally(),
          lineBarsData: [
            LineChartBarData(
                spots: widget.points
                    .map((point) => FlSpot(point.x, point.y))
                    .toList(),
                isCurved: true,
                dotData: FlDotData(
                  show: true,
                ),
                color: themeProvider.isDarkTheme
                    ? Colors.amber.shade300
                    : Colors.green.shade300),
          ],
          borderData: FlBorderData(
            border: Border(
              bottom: BorderSide(
                color: themeProvider.isDarkTheme ? Colors.white : Colors.black,
              ),
              left: BorderSide(
                color: themeProvider.isDarkTheme ? Colors.white : Colors.black,
              ),
            ),
          ),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: _bottomTitles),
            leftTitles: AxisTitles(sideTitles: _leftTiles),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }

  SideTitles get _bottomTitles => SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          String text = '';
          switch (value.toInt()) {
            case 0:
              text = 'Mon';
              break;
            case 1:
              text = 'Tue';
              break;
            case 2:
              text = 'Wed';
              break;
            case 3:
              text = 'Thu';
              break;
            case 4:
              text = 'Fri';
              break;
            case 5:
              text = 'Sat';
              break;
            case 6:
              text = 'Sun';
              break;
          }

          return Text(text);
        },
      );

  SideTitles get _leftTiles => SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          String text = '';
          switch (value.toInt()) {
            case 0:
              text = '0';
              break;
            case 1:
              text = '1';
              break;
            case 2:
              text = '2';
              break;
            case 3:
              text = '3';
              break;
            case 4:
              text = '4';
              break;
            case 5:
              text = '5';
              break;
            case 6:
              text = '6';
              break;
            case 7:
              text = '7';
              break;
            case 8:
              text = '8';
              break;
            case 9:
              text = '9';
              break;
            case 10:
              text = '10';
              break;
          }

          return Text(text);
        },
      );
}
