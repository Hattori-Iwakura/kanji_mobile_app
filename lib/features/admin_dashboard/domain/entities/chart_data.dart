import 'package:equatable/equatable.dart';

/// Entity representing a single data point in a chart
class ChartDataPoint extends Equatable {
  final String date;
  final int count;

  const ChartDataPoint({required this.date, required this.count});

  @override
  List<Object?> get props => [date, count];
}

/// Entity representing chart data (list of data points)
class ChartData extends Equatable {
  final List<ChartDataPoint> dataPoints;

  const ChartData({required this.dataPoints});

  @override
  List<Object?> get props => [dataPoints];
}
