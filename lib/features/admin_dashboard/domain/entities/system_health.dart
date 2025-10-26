import 'package:equatable/equatable.dart';

/// Entity representing system health status
class SystemHealth extends Equatable {
  final String status;
  final DatabaseHealth database;
  final MemoryHealth memory;
  final int uptime;

  const SystemHealth({
    required this.status,
    required this.database,
    required this.memory,
    required this.uptime,
  });

  @override
  List<Object?> get props => [status, database, memory, uptime];
}

/// Database health information
class DatabaseHealth extends Equatable {
  final String status;
  final bool isConnected;

  const DatabaseHealth({required this.status, required this.isConnected});

  @override
  List<Object?> get props => [status, isConnected];
}

/// Memory health information
class MemoryHealth extends Equatable {
  final int heapUsed;
  final int heapTotal;
  final int external;
  final int rss;

  const MemoryHealth({
    required this.heapUsed,
    required this.heapTotal,
    required this.external,
    required this.rss,
  });

  @override
  List<Object?> get props => [heapUsed, heapTotal, external, rss];
}
