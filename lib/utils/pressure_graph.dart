import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:flutter/material.dart';
import 'package:high_chart/high_chart.dart';

class PressureChart extends StatelessWidget {
  final List<MarkerData> markers;

  PressureChart({super.key, required this.markers});

  final List<String> pressureRanges = [
    "28.0 to 29.0",
    "29.0 to 30.0",
    "30.0 to 31.0",
    "31.0 to 32.0",
    "32.0+"
  ];

  String getPressureRange(double pressure) {
    if (pressure < 29.0) return "28.0 to 29.0";
    if (pressure < 30.0) return "29.0 to 30.0";
    if (pressure < 31.0) return "30.0 to 31.0";
    if (pressure < 32.0) return "31.0 to 32.0";
    return "32.0+";
  }

  @override
  Widget build(BuildContext context) {
    final killedByPressure = {for (var range in pressureRanges) range: 0.0};
    final seenByPressure = {for (var range in pressureRanges) range: 0.0};

    for (final marker in markers) {
      String range = getPressureRange(marker.pressure);
      killedByPressure[range] =
          killedByPressure[range]! + double.parse(marker.animalKilled);
      seenByPressure[range] =
          seenByPressure[range]! + double.parse(marker.animalSeen);
    }

    final jsCategories = pressureRanges.map((t) => "'$t'").join(',');
    final killedData = pressureRanges.map((t) => killedByPressure[t]).join(',');
    final seenData = pressureRanges.map((t) => seenByPressure[t]).join(',');

    final chartData = '''
    {
      chart: {
        type: 'line',
        backgroundColor: 'transparent'
      },
      title: {
        text: 'Animal Activity by Pressure Range',
        style: {
          color: '#ffffff'
        }
      },
      xAxis: {
        categories: [$jsCategories],
        title: {
          text: 'Pressure Range (inHg)',
          style: {
            color: '#ffffff'
          }
        },
        labels: {
          style: {
            color: '#ffffff'
          }
        }
      },
      yAxis: {
        min: 0,
        title: {
          text: 'Number of Animals',
          style: {
            color: '#ffffff'
          }
        },
        labels: {
          style: {
            color: '#ffffff'
          }
        }
      },
      plotOptions: {
        line: {
          dataLabels: {
            enabled: true,
            color: '#ffffff'
          },
          enableMouseTracking: true
        }
      },
      legend: {
        itemStyle: {
          color: '#ffffff'
        }
      },
      series: [{
        name: 'Killed',
        data: [$killedData],
        color: '#FF0000'
      }, {
        name: 'Seen',
        data: [$seenData],
        color: '#00FF00'
      }]
    }
    ''';

    return Container(
      height: 400,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(16),
      ),
      child: HighCharts(
        size: const Size(double.infinity, 400),
        data: chartData,
        scripts: const [
          "https://code.highcharts.com/highcharts.js",
          "https://code.highcharts.com/modules/exporting.js"
        ],
      ),
    );
  }
}
