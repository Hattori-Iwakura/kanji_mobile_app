import '../domain/entities/system_health.dart';

/// Model for DatabaseHealth with JSON serialization
class DatabaseHealthModel extends DatabaseHealth {
  const DatabaseHealthModel({
    required super.status,
    required super.isConnected,
  });

  factory DatabaseHealthModel.fromJson(Map<String, dynamic> json) {
    return DatabaseHealthModel(
      status: json['status'] as String? ?? 'unknown',
      isConnected: json['isConnected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'isConnected': isConnected};
  }
}

/// Model for MemoryHealth with JSON serialization
class MemoryHealthModel extends MemoryHealth {
  const MemoryHealthModel({
    required super.heapUsed,
    required super.heapTotal,
    required super.external,
    required super.rss,
  });

  factory MemoryHealthModel.fromJson(Map<String, dynamic> json) {
    return MemoryHealthModel(
      heapUsed: json['heapUsed'] as int? ?? 0,
      heapTotal: json['heapTotal'] as int? ?? 0,
      external: json['external'] as int? ?? 0,
      rss: json['rss'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heapUsed': heapUsed,
      'heapTotal': heapTotal,
      'external': external,
      'rss': rss,
    };
  }
}

/// Model for SystemHealth with JSON serialization
class SystemHealthModel extends SystemHealth {
  const SystemHealthModel({
    required super.status,
    required super.database,
    required super.memory,
    required super.uptime,
  });

  factory SystemHealthModel.fromJson(Map<String, dynamic> json) {
    return SystemHealthModel(
      status: json['status'] as String? ?? 'unknown',
      database: DatabaseHealthModel.fromJson(
        json['database'] as Map<String, dynamic>? ?? {},
      ),
      memory: MemoryHealthModel.fromJson(
        json['memory'] as Map<String, dynamic>? ?? {},
      ),
      uptime: json['uptime'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'database': (database as DatabaseHealthModel).toJson(),
      'memory': (memory as MemoryHealthModel).toJson(),
      'uptime': uptime,
    };
  }
}
