import '../domain/entities/publish_statistics.dart';

/// Model for PublishStatistics with JSON serialization
class PublishStatisticsModel extends PublishStatistics {
  const PublishStatisticsModel({
    required super.totalRequests,
    required super.pendingRequests,
    required super.approvedRequests,
    required super.rejectedRequests,
  });

  factory PublishStatisticsModel.fromJson(Map<String, dynamic> json) {
    return PublishStatisticsModel(
      totalRequests: json['totalRequests'] as int? ?? 0,
      pendingRequests: json['pendingRequests'] as int? ?? 0,
      approvedRequests: json['approvedRequests'] as int? ?? 0,
      rejectedRequests: json['rejectedRequests'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRequests': totalRequests,
      'pendingRequests': pendingRequests,
      'approvedRequests': approvedRequests,
      'rejectedRequests': rejectedRequests,
    };
  }
}
