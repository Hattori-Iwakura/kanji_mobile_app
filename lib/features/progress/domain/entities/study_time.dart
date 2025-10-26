import 'package:equatable/equatable.dart';

/// Entity representing study time tracking
class StudyTime extends Equatable {
  final int totalTime; // in minutes
  final String period; // '7d', '30d', '90d', '1y'

  const StudyTime({required this.totalTime, required this.period});

  @override
  List<Object?> get props => [totalTime, period];
}
