import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:flutter/material.dart';
import 'package:high_chart/high_chart.dart';

final List<String> _windDirections = [
  "North",
  "South",
  "East",
  "West",
  "Northeast",
  "Northwest",
  "Southeast",
  "Southwest"
];

class WindDirectionChart extends StatelessWidget {
  final List<MarkerData> markers;

  const WindDirectionChart({super.key, required this.markers});

  @override
  Widget build(BuildContext context) {
    // Initialize maps with all wind directions
    final killedByWind = Map<String, double>.fromIterable(
      _windDirections,
      key: (dir) => dir,
      value: (_) => 0.0,
    );
    final seenByWind = Map<String, double>.fromIterable(
      _windDirections,
      key: (dir) => dir,
      value: (_) => 0.0,
    );

    // Aggregate data
    for (final marker in markers) {
      final dir = marker.wind_direction;
      if (killedByWind.containsKey(dir)) {
        killedByWind[dir] =
            killedByWind[dir]! + double.parse(marker.animalKilled);
      }
      if (seenByWind.containsKey(dir)) {
        seenByWind[dir] = seenByWind[dir]! + double.parse(marker.animalSeen);
      }
    }

    // Convert to JavaScript-compatible format
    final jsCategories = _windDirections.map((d) => "'$d'").join(',');
    final killedData = _windDirections.map((d) => killedByWind[d]).join(',');
    final seenData = _windDirections.map((d) => seenByWind[d]).join(',');

    final chartData = '''
    {
      chart: {
        type: 'column',
        backgroundColor: 'transparent'
      },
      title: {
        text: 'Animal Activity by Wind Direction',
        style: {
          color: '#ffffff'
        }
      },
      xAxis: {
        categories: [$jsCategories],
        title: {
          text: 'Wind Direction',
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
        color: '#FF0000' // Explicit red for killed
      }, {
        name: 'Seen',
        data: [$seenData],
        color: '#00FF00' // Explicit green for seen
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
