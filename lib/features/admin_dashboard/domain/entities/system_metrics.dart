import 'package:equatable/equatable.dart';

/// Entity representing system performance metrics
class SystemMetrics extends Equatable {
  final CpuMetrics cpu;
  final MemoryMetrics memory;
  final RequestMetrics requests;

  const SystemMetrics({
    required this.cpu,
    required this.memory,
    required this.requests,
  });

  @override
  List<Object?> get props => [cpu, memory, requests];
}

/// CPU usage metrics
class CpuMetrics extends Equatable {
  final double usage;
  final int count;

  const CpuMetrics({required this.usage, required this.count});

  @override
  List<Object?> get props => [usage, count];
}

/// Memory usage metrics
class MemoryMetrics extends Equatable {
  final int used;
  final int total;
  final double percentage;

  const MemoryMetrics({
    required this.used,
    required this.total,
    required this.percentage,
  });

  @override
  List<Object?> get props => [used, total, percentage];
}

/// Request metrics
class RequestMetrics extends Equatable {
  final int total;
  final int successful;
  final int failed;
  final double averageResponseTime;

  const RequestMetrics({
    required this.total,
    required this.successful,
    required this.failed,
    required this.averageResponseTime,
  });

  @override
  List<Object?> get props => [total, successful, failed, averageResponseTime];
}
