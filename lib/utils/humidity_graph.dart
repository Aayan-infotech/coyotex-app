import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:flutter/material.dart';
import 'package:high_chart/high_chart.dart';

class HumidityChart extends StatelessWidget {
  final List<MarkerData> markers;

  HumidityChart({super.key, required this.markers});

  final List<String> humidityRanges = [
    "0 to 20",
    "20 to 40",
    "40 to 60",
    "60 to 80",
    "80 to 100"
  ];

  String getHumidityRange(int humidity) {
    if (humidity < 20) return "0 to 20";
    if (humidity < 40) return "20 to 40";
    if (humidity < 60) return "40 to 60";
    if (humidity < 80) return "60 to 80";
    return "80 to 100";
  }

  @override
  Widget build(BuildContext context) {
    final killedByHumidity = {for (var range in humidityRanges) range: 0.0};
    final seenByHumidity = {for (var range in humidityRanges) range: 0.0};

    for (final marker in markers) {
      String range = getHumidityRange(marker.humidity);

      if (killedByHumidity.containsKey(range)) {
        killedByHumidity[range] =
            killedByHumidity[range]! + double.parse(marker.animalKilled);
      }
      if (seenByHumidity.containsKey(range)) {
        seenByHumidity[range] =
            seenByHumidity[range]! + double.parse(marker.animalSeen);
      }
    }

    final jsCategories = humidityRanges.map((t) => "'$t'").join(',');
    final killedData = humidityRanges.map((t) => killedByHumidity[t]).join(',');
    final seenData = humidityRanges.map((t) => seenByHumidity[t]).join(',');

    final chartData = '''
    {
      chart: {
        type: 'line',
        backgroundColor: 'transparent'
      },
      title: {
        text: 'Animal Activity by Humidity Range',
        style: {
          color: '#ffffff'
        }
      },
      xAxis: {
        categories: [$jsCategories],
        title: {
          text: 'Humidity Range (%)',
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
