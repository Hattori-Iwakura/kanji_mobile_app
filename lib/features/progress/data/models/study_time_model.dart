import '../../domain/entities/study_time.dart';

class StudyTimeModel extends StudyTime {
  const StudyTimeModel({required super.totalTime, required super.period});

  factory StudyTimeModel.fromJson(Map<String, dynamic> json) {
    return StudyTimeModel(
      totalTime: json['totalTime'] as int? ?? 0,
      period: json['period'] as String? ?? '7d',
    );
  }

  Map<String, dynamic> toJson() {
    return {'totalTime': totalTime, 'period': period};
  }
}
