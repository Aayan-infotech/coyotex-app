import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:flutter/material.dart';
import 'package:high_chart/high_chart.dart';

class WindSpeedChart extends StatelessWidget {
  final List<MarkerData> markers;

  WindSpeedChart({super.key, required this.markers});

  // Define fixed wind speed ranges
  final List<String> windSpeedRanges = [
    "0 to 10",
    "10 to 20",
    "20 to 30",
    "30 to 40",
    "40+"
  ];

  // Function to get the range a wind speed value falls into
  String getWindSpeedRange(double windSpeed) {
    if (windSpeed < 10) return "0 to 10";
    if (windSpeed < 20) return "10 to 20";
    if (windSpeed < 30) return "20 to 30";
    if (windSpeed < 40) return "30 to 40";
    return "40+";
  }

  @override
  Widget build(BuildContext context) {
    // Initialize maps with all wind speed ranges
    final killedByWindSpeed = {for (var range in windSpeedRanges) range: 0.0};
    final seenByWindSpeed = {for (var range in windSpeedRanges) range: 0.0};

    // Aggregate data based on wind speed ranges
    for (final marker in markers) {
      String range = getWindSpeedRange(marker.windSpeed);

      if (killedByWindSpeed.containsKey(range)) {
        killedByWindSpeed[range] =
            killedByWindSpeed[range]! + double.parse(marker.animalKilled);
      }
      if (seenByWindSpeed.containsKey(range)) {
        seenByWindSpeed[range] =
            seenByWindSpeed[range]! + double.parse(marker.animalSeen);
      }
    }

    // Convert to JavaScript-compatible format
    final jsCategories = windSpeedRanges.map((t) => "'$t'").join(',');
    final killedData =
        windSpeedRanges.map((t) => killedByWindSpeed[t]).join(',');
    final seenData = windSpeedRanges.map((t) => seenByWindSpeed[t]).join(',');

    final chartData = '''
    {
      chart: {
        type: 'line',
        backgroundColor: 'transparent'
      },
      title: {
        text: 'Animal Activity by Wind Speed Range',
        style: {
          color: '#ffffff'
        }
      },
      xAxis: {
        categories: [$jsCategories],
        title: {
          text: 'Wind Speed Range (mph)',
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
