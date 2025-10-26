import 'package:equatable/equatable.dart';

/// DTO for reviewing a publish request
class ReviewPublishRequestDto extends Equatable {
  final String status; // 'APPROVED' or 'REJECTED'
  final String? rejectionReason;

  const ReviewPublishRequestDto({required this.status, this.rejectionReason});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'status': status};

    if (rejectionReason != null) {
      json['rejectionReason'] = rejectionReason;
    }

    return json;
  }

  @override
  List<Object?> get props => [status, rejectionReason];
}
