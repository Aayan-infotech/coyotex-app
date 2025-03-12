import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:flutter/material.dart';
import 'package:high_chart/high_chart.dart';

class TemperatureChart extends StatelessWidget {
  final List<MarkerData> markers;

  TemperatureChart({super.key, required this.markers});

  // Define fixed temperature ranges
  final List<String> temperatureRanges = [
    "-20 to -10",
    "-10 to 0",
    "0 to 10",
    "10 to 20",
    "20 to 30",
    "30 to 40",
    "40+"
  ];

  // Function to get the range a temperature falls into
  String getTemperatureRange(double temperature) {
    if (temperature < -10) return "-20 to -10";
    if (temperature < 0) return "-10 to 0";
    if (temperature < 10) return "0 to 10";
    if (temperature < 20) return "10 to 20";
    if (temperature < 30) return "20 to 30";
    if (temperature < 40) return "30 to 40";
    return "40+";
  }

  @override
  Widget build(BuildContext context) {
    // Initialize maps with all temperature ranges
    final killedByTemp = Map<String, double>.fromIterable(
      temperatureRanges,
      key: (range) => range,
      value: (_) => 0.0,
    );
    final seenByTemp = Map<String, double>.fromIterable(
      temperatureRanges,
      key: (range) => range,
      value: (_) => 0.0,
    );

    // Aggregate data based on temperature ranges
    for (final marker in markers) {
      String range = getTemperatureRange(marker.temperature);

      if (killedByTemp.containsKey(range)) {
        killedByTemp[range] =
            killedByTemp[range]! + double.parse(marker.animalKilled);
      }
      if (seenByTemp.containsKey(range)) {
        seenByTemp[range] =
            seenByTemp[range]! + double.parse(marker.animalSeen);
      }
    }

    // Convert to JavaScript-compatible format
    final jsCategories = temperatureRanges.map((t) => "'$t'").join(',');
    final killedData = temperatureRanges.map((t) => killedByTemp[t]).join(',');
    final seenData = temperatureRanges.map((t) => seenByTemp[t]).join(',');

    final chartData = '''
    {
      chart: {
        type: 'column',
        backgroundColor: 'transparent'
      },
      title: {
        text: 'Animal Activity by Temperature Range',
        style: {
          color: '#ffffff'
        }
      },
      xAxis: {
        categories: [$jsCategories],
        title: {
          text: 'Temperature Range (°C)',
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
        column: {
          grouping: true,
          borderRadius: 3,
          dataLabels: {
            enabled: true,
            color: '#ffffff'
          }
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
        color: '#FF0000' // Explicitly setting red for killed
      }, {
        name: 'Seen',
        data: [$seenData],
        color: '#00FF00' // Explicitly setting green for seen
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
