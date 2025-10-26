import '../../domain/entities/chart_data.dart';

class ChartDataModel extends ChartData {
  const ChartDataModel({required super.data});

  factory ChartDataModel.fromJson(Map<String, dynamic> json) {
    return ChartDataModel(data: json as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() {
    return data;
  }
}
