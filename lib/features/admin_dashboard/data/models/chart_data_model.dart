import '../domain/entities/chart_data.dart';

/// Model for ChartDataPoint with JSON serialization
class ChartDataPointModel extends ChartDataPoint {
  const ChartDataPointModel({required super.date, required super.count});

  factory ChartDataPointModel.fromJson(Map<String, dynamic> json) {
    return ChartDataPointModel(
      date: json['date'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date, 'count': count};
  }
}

/// Model for ChartData with JSON serialization
class ChartDataModel extends ChartData {
  const ChartDataModel({required super.dataPoints});

  factory ChartDataModel.fromJson(List<dynamic> jsonList) {
    final dataPoints = jsonList
        .map(
          (json) => ChartDataPointModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();

    return ChartDataModel(dataPoints: dataPoints);
  }

  List<Map<String, dynamic>> toJson() {
    return dataPoints
        .map((point) => {'date': point.date, 'count': point.count})
        .toList();
  }
}
