import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MoodPoint {
  final double x;
  final double y;

  // define a point in the table.
  MoodPoint({required this.x, required this.y});
}

class LineChartWidget extends StatelessWidget {
  final List<MoodPoint> points;
  final int highestY;

  const LineChartWidget(this.points, this.highestY, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: highestY.toDouble(),
          lineBarsData: [
            LineChartBarData(
                spots: points.map((point) => FlSpot(point.x, point.y)).toList(),
                isCurved: false,
                dotData: FlDotData(
                  show: true,
                ),
                color: Colors.green.shade300),
          ],
          borderData: FlBorderData(
              border: const Border(bottom: BorderSide(), left: BorderSide())),
          gridData: FlGridData(show: true),
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
