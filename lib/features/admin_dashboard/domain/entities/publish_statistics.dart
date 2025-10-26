import 'package:equatable/equatable.dart';

/// Entity representing publish request statistics
class PublishStatistics extends Equatable {
  final int totalRequests;
  final int pendingRequests;
  final int approvedRequests;
  final int rejectedRequests;

  const PublishStatistics({
    required this.totalRequests,
    required this.pendingRequests,
    required this.approvedRequests,
    required this.rejectedRequests,
  });

  @override
  List<Object?> get props => [
    totalRequests,
    pendingRequests,
    approvedRequests,
    rejectedRequests,
  ];
}
