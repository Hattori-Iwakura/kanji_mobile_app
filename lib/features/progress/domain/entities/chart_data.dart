import 'package:equatable/equatable.dart';

/// Entity representing chart data for visualization
class ChartData extends Equatable {
  final Map<String, dynamic>
  data; // Flexible structure for different chart types

  const ChartData({required this.data});

  @override
  List<Object?> get props => [data];
}
