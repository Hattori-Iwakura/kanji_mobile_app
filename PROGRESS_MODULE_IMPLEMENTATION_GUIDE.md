# Progress Module Implementation Guide

## 📁 Cấu Trúc Đã Tạo

```
lib/features/progress/
├── domain/
│   ├── entities/
│   │   ├── progress_overview.dart      ✅ Created
│   │   ├── flashcard_progress.dart     ✅ Created
│   │   ├── quiz_progress.dart          ✅ Created
│   │   ├── streak.dart                 ✅ Created
│   │   ├── leaderboard.dart            ✅ Created
│   │   ├── achievement.dart            ✅ Created
│   │   ├── chart_data.dart             ✅ Created
│   │   └── study_time.dart             ✅ Created
│   ├── repositories/
│   │   └── progress_repository.dart    ✅ Created
│   └── usecases/
│       └── [8 use cases - TODO]
├── data/
│   ├── models/
│   │   └── [8 models - TODO]
│   ├── datasources/
│   │   └── progress_remote_datasource.dart - TODO
│   └── repositories/
│       └── progress_repository_impl.dart - TODO
└── presentation/
    ├── bloc/
    │   ├── progress_bloc.dart - TODO
    │   ├── progress_event.dart - TODO
    │   └── progress_state.dart - TODO
    ├── pages/
    │   ├── progress_overview_page.dart - TODO
    │   ├── leaderboard_page.dart - TODO
    │   ├── achievements_page.dart - TODO
    │   └── statistics_page.dart - TODO
    └── widgets/
        └── [stat cards, charts, etc. - TODO]
```

## ✅ Đã Hoàn Thành

### 1. Domain Entities (8 entities)
- ✅ `ProgressOverview`: Tổng quan tiến độ (streak, XP, level, stats)
- ✅ `FlashcardProgress`: Tiến độ học flashcard
- ✅ `QuizProgress`: Tiến độ làm quiz
- ✅ `Streak`: Streak hiện tại và longest streak
- ✅ `Leaderboard` + `LeaderboardEntry`: Bảng xếp hạng
- ✅ `Achievement` + `AchievementsOverview`: Hệ thống thành tích
- ✅ `ChartData`: Dữ liệu biểu đồ
- ✅ `StudyTime`: Thời gian học

### 2. Repository Interface
- ✅ `ProgressRepository`: Interface với 8 methods tương ứng 8 endpoints

## 🔄 Cần Implement Tiếp

### Bước 1: Update API Endpoints Constants

File: `lib/core/constants/api_endpoints.dart`

Thêm vào class `ApiEndpoints`:

```dart
// Progress Endpoints
static String get progressOverview => '$baseUrl/progress/overview';
static String get progressFlashcard => '$baseUrl/progress/flashcard';
static String get progressQuiz => '$baseUrl/progress/quiz';
static String get progressStreak => '$baseUrl/progress/streak';
static String get progressLeaderboard => '$baseUrl/progress/leaderboard';
static String get progressAchievements => '$baseUrl/progress/achievements';
static String get progressChartData => '$baseUrl/progress/chart-data';
static String get progressStudyTime => '$baseUrl/progress/study-time';
```

### Bước 2: Create Models (Data Layer)

Tạo file `lib/features/progress/data/models/progress_overview_model.dart`:

```dart
import '../../domain/entities/progress_overview.dart';

class ProgressOverviewModel extends ProgressOverview {
  const ProgressOverviewModel({
    required super.userId,
    required super.username,
    required super.currentStreak,
    required super.longestStreak,
    required super.totalStudyTime,
    required super.xp,
    required super.level,
    required super.flashcardsStudied,
    required super.quizzesCompleted,
    required super.averageQuizScore,
    required super.achievementsUnlocked,
    super.lastActivityDate,
  });

  factory ProgressOverviewModel.fromJson(Map<String, dynamic> json) {
    return ProgressOverviewModel(
      userId: json['userId'] as int,
      username: json['username'] as String,
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      totalStudyTime: json['totalStudyTime'] as int,
      xp: json['xp'] as int,
      level: json['level'] as int,
      flashcardsStudied: json['flashcardsStudied'] as int,
      quizzesCompleted: json['quizzesCompleted'] as int,
      averageQuizScore: (json['averageQuizScore'] as num).toDouble(),
      achievementsUnlocked: json['achievementsUnlocked'] as int,
      lastActivityDate: json['lastActivityDate'] != null
          ? DateTime.parse(json['lastActivityDate'] as String)
          : null,
    );
  }
}
```

**Tương tự cho 7 models còn lại.**

### Bước 3: Create Remote Datasource

File: `lib/features/progress/data/datasources/progress_remote_datasource.dart`

```dart
import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/achievement_model.dart';
import '../models/chart_data_model.dart';
import '../models/flashcard_progress_model.dart';
import '../models/leaderboard_model.dart';
import '../models/progress_overview_model.dart';
import '../models/quiz_progress_model.dart';
import '../models/streak_model.dart';
import '../models/study_time_model.dart';

abstract class ProgressRemoteDataSource {
  Future<ProgressOverviewModel> getProgressOverview();
  Future<FlashcardProgressModel> getFlashcardProgress({String? period});
  Future<QuizProgressModel> getQuizProgress({String? period});
  Future<StreakModel> getStreak();
  Future<LeaderboardModel> getLeaderboard({String? period, String? type, int? limit});
  Future<AchievementsOverviewModel> getAchievements();
  Future<ChartDataModel> getChartData();
  Future<StudyTimeModel> getStudyTime({String? period});
}

class ProgressRemoteDataSourceImpl implements ProgressRemoteDataSource {
  final DioClient dioClient;

  ProgressRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<ProgressOverviewModel> getProgressOverview() async {
    final response = await dioClient.dio.get(ApiEndpoints.progressOverview);
    return ProgressOverviewModel.fromJson(response.data['data']);
  }

  @override
  Future<FlashcardProgressModel> getFlashcardProgress({String? period}) async {
    final queryParams = period != null ? {'period': period} : null;
    final response = await dioClient.dio.get(
      ApiEndpoints.progressFlashcard,
      queryParameters: queryParams,
    );
    return FlashcardProgressModel.fromJson(response.data['data']);
  }

  @override
  Future<QuizProgressModel> getQuizProgress({String? period}) async {
    final queryParams = period != null ? {'period': period} : null;
    final response = await dioClient.dio.get(
      ApiEndpoints.progressQuiz,
      queryParameters: queryParams,
    );
    return QuizProgressModel.fromJson(response.data['data']);
  }

  @override
  Future<StreakModel> getStreak() async {
    final response = await dioClient.dio.get(ApiEndpoints.progressStreak);
    return StreakModel.fromJson(response.data['data']);
  }

  @override
  Future<LeaderboardModel> getLeaderboard({
    String? period,
    String? type,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (period != null) queryParams['period'] = period;
    if (type != null) queryParams['type'] = type;
    if (limit != null) queryParams['limit'] = limit;

    final response = await dioClient.dio.get(
      ApiEndpoints.progressLeaderboard,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return LeaderboardModel.fromJson(response.data['data']);
  }

  @override
  Future<AchievementsOverviewModel> getAchievements() async {
    final response = await dioClient.dio.get(ApiEndpoints.progressAchievements);
    return AchievementsOverviewModel.fromJson(response.data['data']);
  }

  @override
  Future<ChartDataModel> getChartData() async {
    final response = await dioClient.dio.get(ApiEndpoints.progressChartData);
    return ChartDataModel.fromJson(response.data['data']);
  }

  @override
  Future<StudyTimeModel> getStudyTime({String? period}) async {
    final queryParams = period != null ? {'period': period} : null;
    final response = await dioClient.dio.get(
      ApiEndpoints.progressStudyTime,
      queryParameters: queryParams,
    );
    return StudyTimeModel.fromJson(response.data['data']);
  }
}
```

### Bước 4: Create Repository Implementation

File: `lib/features/progress/data/repositories/progress_repository_impl.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/chart_data.dart';
import '../../domain/entities/flashcard_progress.dart';
import '../../domain/entities/leaderboard.dart';
import '../../domain/entities/progress_overview.dart';
import '../../domain/entities/quiz_progress.dart';
import '../../domain/entities/streak.dart';
import '../../domain/entities/study_time.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_remote_datasource.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressRemoteDataSource remoteDataSource;

  ProgressRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProgressOverview>> getProgressOverview() async {
    try {
      final result = await remoteDataSource.getProgressOverview();
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, FlashcardProgress>> getFlashcardProgress({
    String? period,
  }) async {
    try {
      final result = await remoteDataSource.getFlashcardProgress(period: period);
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // Implement remaining 6 methods similarly...

  Failure _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return TimeoutFailure();
    } else if (error.type == DioExceptionType.connectionError) {
      return NetworkFailure();
    } else if (error.response?.statusCode == 401) {
      return UnauthorizedFailure();
    } else {
      return ServerFailure(
        message: error.response?.data['message'] ?? 'Unknown error',
      );
    }
  }
}
```

### Bước 5: Create BLoC (Presentation Layer)

File: `lib/features/progress/presentation/bloc/progress_event.dart`:

```dart
import 'package:equatable/equatable.dart';

abstract class ProgressEvent extends Equatable {
  const ProgressEvent();

  @override
  List<Object?> get props => [];
}

class LoadProgressOverview extends ProgressEvent {}

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

class LoadStreak extends ProgressEvent {}

class LoadLeaderboard extends ProgressEvent {
  final String? period;
  final String? type;
  final int? limit;
  
  const LoadLeaderboard({this.period, this.type, this.limit});
  
  @override
  List<Object?> get props => [period, type, limit];
}

class LoadAchievements extends ProgressEvent {}

class LoadChartData extends ProgressEvent {}

class LoadStudyTime extends ProgressEvent {
  final String? period;
  const LoadStudyTime({this.period});
  
  @override
  List<Object?> get props => [period];
}

class RefreshAllProgress extends ProgressEvent {}
```

File: `lib/features/progress/presentation/bloc/progress_state.dart`:

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/chart_data.dart';
import '../../domain/entities/flashcard_progress.dart';
import '../../domain/entities/leaderboard.dart';
import '../../domain/entities/progress_overview.dart';
import '../../domain/entities/quiz_progress.dart';
import '../../domain/entities/streak.dart';
import '../../domain/entities/study_time.dart';

abstract class ProgressState extends Equatable {
  const ProgressState();

  @override
  List<Object?> get props => [];
}

class ProgressInitial extends ProgressState {}

class ProgressLoading extends ProgressState {}

class ProgressOverviewLoaded extends ProgressState {
  final ProgressOverview overview;
  const ProgressOverviewLoaded(this.overview);
  
  @override
  List<Object?> get props => [overview];
}

class FlashcardProgressLoaded extends ProgressState {
  final FlashcardProgress progress;
  const FlashcardProgressLoaded(this.progress);
  
  @override
  List<Object?> get props => [progress];
}

class QuizProgressLoaded extends ProgressState {
  final QuizProgress progress;
  const QuizProgressLoaded(this.progress);
  
  @override
  List<Object?> get props => [progress];
}

class StreakLoaded extends ProgressState {
  final Streak streak;
  const StreakLoaded(this.streak);
  
  @override
  List<Object?> get props => [streak];
}

class LeaderboardLoaded extends ProgressState {
  final Leaderboard leaderboard;
  const LeaderboardLoaded(this.leaderboard);
  
  @override
  List<Object?> get props => [leaderboard];
}

class AchievementsLoaded extends ProgressState {
  final AchievementsOverview achievements;
  const AchievementsLoaded(this.achievements);
  
  @override
  List<Object?> get props => [achievements];
}

class ChartDataLoaded extends ProgressState {
  final ChartData chartData;
  const ChartDataLoaded(this.chartData);
  
  @override
  List<Object?> get props => [chartData];
}

class StudyTimeLoaded extends ProgressState {
  final StudyTime studyTime;
  const StudyTimeLoaded(this.studyTime);
  
  @override
  List<Object?> get props => [studyTime];
}

class AllProgressLoaded extends ProgressState {
  final ProgressOverview overview;
  final Streak streak;
  final AchievementsOverview achievements;
  
  const AllProgressLoaded({
    required this.overview,
    required this.streak,
    required this.achievements,
  });
  
  @override
  List<Object?> get props => [overview, streak, achievements];
}

class ProgressError extends ProgressState {
  final String message;
  const ProgressError(this.message);
  
  @override
  List<Object?> get props => [message];
}
```

File: `lib/features/progress/presentation/bloc/progress_bloc.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/progress_repository.dart';
import 'progress_event.dart';
import 'progress_state.dart';

class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final ProgressRepository repository;

  ProgressBloc({required this.repository}) : super(ProgressInitial()) {
    on<LoadProgressOverview>(_onLoadProgressOverview);
    on<LoadFlashcardProgress>(_onLoadFlashcardProgress);
    on<LoadQuizProgress>(_onLoadQuizProgress);
    on<LoadStreak>(_onLoadStreak);
    on<LoadLeaderboard>(_onLoadLeaderboard);
    on<LoadAchievements>(_onLoadAchievements);
    on<LoadChartData>(_onLoadChartData);
    on<LoadStudyTime>(_onLoadStudyTime);
    on<RefreshAllProgress>(_onRefreshAllProgress);
  }

  Future<void> _onLoadProgressOverview(
    LoadProgressOverview event,
    Emitter<ProgressState> emit,
  ) async {
    emit(ProgressLoading());
    final result = await repository.getProgressOverview();
    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (overview) => emit(ProgressOverviewLoaded(overview)),
    );
  }

  Future<void> _onLoadFlashcardProgress(
    LoadFlashcardProgress event,
    Emitter<ProgressState> emit,
  ) async {
    emit(ProgressLoading());
    final result = await repository.getFlashcardProgress(period: event.period);
    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (progress) => emit(FlashcardProgressLoaded(progress)),
    );
  }

  Future<void> _onLoadQuizProgress(
    LoadQuizProgress event,
    Emitter<ProgressState> emit,
  ) async {
    emit(ProgressLoading());
    final result = await repository.getQuizProgress(period: event.period);
    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (progress) => emit(QuizProgressLoaded(progress)),
    );
  }

  Future<void> _onLoadStreak(
    LoadStreak event,
    Emitter<ProgressState> emit,
  ) async {
    emit(ProgressLoading());
    final result = await repository.getStreak();
    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (streak) => emit(StreakLoaded(streak)),
    );
  }

  Future<void> _onLoadLeaderboard(
    LoadLeaderboard event,
    Emitter<ProgressState> emit,
  ) async {
    emit(ProgressLoading());
    final result = await repository.getLeaderboard(
      period: event.period,
      type: event.type,
      limit: event.limit,
    );
    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (leaderboard) => emit(LeaderboardLoaded(leaderboard)),
    );
  }

  Future<void> _onLoadAchievements(
    LoadAchievements event,
    Emitter<ProgressState> emit,
  ) async {
    emit(ProgressLoading());
    final result = await repository.getAchievements();
    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (achievements) => emit(AchievementsLoaded(achievements)),
    );
  }

  Future<void> _onLoadChartData(
    LoadChartData event,
    Emitter<ProgressState> emit,
  ) async {
    emit(ProgressLoading());
    final result = await repository.getChartData();
    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (chartData) => emit(ChartDataLoaded(chartData)),
    );
  }

  Future<void> _onLoadStudyTime(
    LoadStudyTime event,
    Emitter<ProgressState> emit,
  ) async {
    emit(ProgressLoading());
    final result = await repository.getStudyTime(period: event.period);
    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (studyTime) => emit(StudyTimeLoaded(studyTime)),
    );
  }

  Future<void> _onRefreshAllProgress(
    RefreshAllProgress event,
    Emitter<ProgressState> emit,
  ) async {
    emit(ProgressLoading());
    
    final overviewResult = await repository.getProgressOverview();
    final streakResult = await repository.getStreak();
    final achievementsResult = await repository.getAchievements();
    
    if (overviewResult.isLeft() || streakResult.isLeft() || achievementsResult.isLeft()) {
      emit(ProgressError('Failed to load progress data'));
      return;
    }
    
    emit(AllProgressLoaded(
      overview: overviewResult.fold((l) => throw Exception(), (r) => r),
      streak: streakResult.fold((l) => throw Exception(), (r) => r),
      achievements: achievementsResult.fold((l) => throw Exception(), (r) => r),
    ));
  }
}
```

### Bước 6: Create UI Pages

File: `lib/features/progress/presentation/pages/progress_overview_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/progress_bloc.dart';
import '../bloc/progress_event.dart';
import '../bloc/progress_state.dart';

class ProgressOverviewPage extends StatelessWidget {
  const ProgressOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProgressBloc>().add(RefreshAllProgress());
            },
          ),
        ],
      ),
      body: BlocBuilder<ProgressBloc, ProgressState>(
        builder: (context, state) {
          if (state is ProgressLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is ProgressError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProgressBloc>().add(RefreshAllProgress());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is AllProgressLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProgressBloc>().add(RefreshAllProgress());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildOverviewCard(state.overview),
                  const SizedBox(height: 16),
                  _buildStreakCard(state.streak),
                  const SizedBox(height: 16),
                  _buildAchievementsCard(context, state.achievements),
                  const SizedBox(height: 16),
                  _buildQuickLinksCard(context),
                ],
              ),
            );
          }
          
          // Initial state - load data
          context.read<ProgressBloc>().add(RefreshAllProgress());
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildOverviewCard(dynamic overview) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Level', overview.level.toString()),
                _buildStatItem('XP', overview.xp.toString()),
                _buildStatItem('Streak', '${overview.currentStreak} days'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Flashcards', overview.flashcardsStudied.toString()),
                _buildStatItem('Quizzes', overview.quizzesCompleted.toString()),
                _buildStatItem('Study Time', '${overview.totalStudyTime} min'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(dynamic streak) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Icon(Icons.local_fire_department, size: 48, color: Colors.orange),
                const SizedBox(height: 8),
                Text('${streak.currentStreak}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('Current Streak'),
              ],
            ),
            Column(
              children: [
                Icon(Icons.star, size: 48, color: Colors.yellow),
                const SizedBox(height: 8),
                Text('${streak.longestStreak}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('Longest Streak'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsCard(BuildContext context, dynamic achievements) {
    return Card(
      child: InkWell(
        onTap: () {
          // Navigate to achievements page
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Achievements',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('${achievements.totalUnlocked}/${achievements.totalAvailable} unlocked'),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: achievements.completionPercentage / 100,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLinksCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'View Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.leaderboard),
              title: Text('Leaderboard'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to leaderboard
              },
            ),
            ListTile(
              leading: Icon(Icons.show_chart),
              title: Text('Statistics'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to statistics
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
```

### Bước 7: Register Dependencies

File: `lib/core/di/injection.dart`

Thêm vào hàm `init()`:

```dart
// Progress Feature
sl.registerLazySingleton<ProgressRemoteDataSource>(
  () => ProgressRemoteDataSourceImpl(dioClient: sl()),
);

sl.registerLazySingleton<ProgressRepository>(
  () => ProgressRepositoryImpl(remoteDataSource: sl()),
);

sl.registerFactory(
  () => ProgressBloc(repository: sl()),
);
```

### Bước 8: Add Navigation

File: Update router để thêm Progress route

```dart
GoRoute(
  path: '/progress',
  builder: (context, state) => BlocProvider(
    create: (context) => sl<ProgressBloc>(),
    child: const ProgressOverviewPage(),
  ),
),
```

## 📝 Summary

Đã tạo foundation hoàn chỉnh cho Progress Module:

✅ **Domain Layer**: 8 entities + repository interface  
🔄 **Data Layer**: Cần tạo 8 models + datasource + repository impl  
🔄 **Presentation Layer**: Cần tạo BLoC + 4 UI pages  
🔄 **Integration**: Cần update API endpoints + DI + routing  

## 🚀 Next Steps

1. Copy code từ guide này để tạo các file còn thiếu
2. Tạo 8 models tương ứng 8 entities
3. Implement datasource với 8 API calls
4. Implement repository
5. Tạo BLoC với events/states
6. Tạo 4 UI pages chính
7. Register dependencies
8. Test với backend API

**Estimated Time**: 3-4 hours để hoàn thành toàn bộ module.
