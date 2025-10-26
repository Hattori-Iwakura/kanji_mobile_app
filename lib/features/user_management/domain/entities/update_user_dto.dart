class UpdateUserDto {
  final String? role;
  final String? status;
  final String? fullName;

  const UpdateUserDto({this.role, this.status, this.fullName});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (role != null) map['role'] = role;
    if (status != null) map['status'] = status;
    if (fullName != null) map['fullName'] = fullName;
    return map;
  }
}
