import 'package:equatable/equatable.dart';

abstract class ProgressEvent extends Equatable {
  const ProgressEvent();

  @override
  List<Object?> get props => [];
}

// Load all progress data
class LoadProgressOverview extends ProgressEvent {
  const LoadProgressOverview();
}

// Load specific progress sections
class LoadFlashcardProgress extends ProgressEvent {
  final String? period;

  const LoadFlashcardProgress({this.period});

  @override
  List<Object?> get props => [period];
}

class LoadQuizProgress extends ProgressEvent {
  final String? period;

  const LoadQuizProgress({this.period});

  @override
  List<Object?> get props => [period];
}

class LoadStreak extends ProgressEvent {
  const LoadStreak();
}

class LoadLeaderboard extends ProgressEvent {
  final String? period;
  final String? type;
  final int? limit;

  const LoadLeaderboard({this.period, this.type, this.limit});

  @override
  List<Object?> get props => [period, type, limit];
}

class LoadAchievements extends ProgressEvent {
  const LoadAchievements();
}

class LoadChartData extends ProgressEvent {
  const LoadChartData();
}

class LoadStudyTime extends ProgressEvent {
  final String? period;

  const LoadStudyTime({this.period});

  @override
  List<Object?> get props => [period];
}

// Refresh events
class RefreshProgress extends ProgressEvent {
  const RefreshProgress();
}
