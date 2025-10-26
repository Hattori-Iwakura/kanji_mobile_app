import '../domain/entities/system_metrics.dart';

/// Model for CpuMetrics with JSON serialization
class CpuMetricsModel extends CpuMetrics {
  const CpuMetricsModel({required super.usage, required super.count});

  factory CpuMetricsModel.fromJson(Map<String, dynamic> json) {
    return CpuMetricsModel(
      usage: (json['usage'] as num?)?.toDouble() ?? 0.0,
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'usage': usage, 'count': count};
  }
}

/// Model for MemoryMetrics with JSON serialization
class MemoryMetricsModel extends MemoryMetrics {
  const MemoryMetricsModel({
    required super.used,
    required super.total,
    required super.percentage,
  });

  factory MemoryMetricsModel.fromJson(Map<String, dynamic> json) {
    return MemoryMetricsModel(
      used: json['used'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'used': used, 'total': total, 'percentage': percentage};
  }
}

/// Model for RequestMetrics with JSON serialization
class RequestMetricsModel extends RequestMetrics {
  const RequestMetricsModel({
    required super.total,
    required super.successful,
    required super.failed,
    required super.averageResponseTime,
  });

  factory RequestMetricsModel.fromJson(Map<String, dynamic> json) {
    return RequestMetricsModel(
      total: json['total'] as int? ?? 0,
      successful: json['successful'] as int? ?? 0,
      failed: json['failed'] as int? ?? 0,
      averageResponseTime:
          (json['averageResponseTime'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'successful': successful,
      'failed': failed,
      'averageResponseTime': averageResponseTime,
    };
  }
}

/// Model for SystemMetrics with JSON serialization
class SystemMetricsModel extends SystemMetrics {
  const SystemMetricsModel({
    required super.cpu,
    required super.memory,
    required super.requests,
  });

  factory SystemMetricsModel.fromJson(Map<String, dynamic> json) {
    return SystemMetricsModel(
      cpu: CpuMetricsModel.fromJson(json['cpu'] as Map<String, dynamic>? ?? {}),
      memory: MemoryMetricsModel.fromJson(
        json['memory'] as Map<String, dynamic>? ?? {},
      ),
      requests: RequestMetricsModel.fromJson(
        json['requests'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cpu': (cpu as CpuMetricsModel).toJson(),
      'memory': (memory as MemoryMetricsModel).toJson(),
      'requests': (requests as RequestMetricsModel).toJson(),
    };
  }
}
