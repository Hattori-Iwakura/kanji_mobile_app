import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/user_model.dart';
import '../../domain/entities/update_user_dto.dart';

abstract class UserManagementRemoteDataSource {
  Future<List<UserModel>> getAllUsers({
    int? page,
    int? limit,
    String? search,
    String? role,
    String? status,
  });

  Future<UserModel> getUserById(int userId);

  Future<UserModel> updateUser(int userId, UpdateUserDto dto);

  Future<void> deleteUser(int userId);
}

class UserManagementRemoteDataSourceImpl
    implements UserManagementRemoteDataSource {
  final DioClient dioClient;

  UserManagementRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<UserModel>> getAllUsers({
    int? page,
    int? limit,
    String? search,
    String? role,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (search != null) queryParams['search'] = search;
    if (role != null) queryParams['role'] = role;
    if (status != null) queryParams['status'] = status;

    final response = await dioClient.dio.get(
      ApiEndpoints.adminUsers,
      queryParameters: queryParams,
    );

    final List<dynamic> usersJson = response.data['data'] as List<dynamic>;
    return usersJson
        .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<UserModel> getUserById(int userId) async {
    final response = await dioClient.dio.get(
      ApiEndpoints.adminUserDetail(userId),
    );

    return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> updateUser(int userId, UpdateUserDto dto) async {
    final response = await dioClient.dio.patch(
      ApiEndpoints.adminUserDetail(userId),
      data: dto.toJson(),
    );

    return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteUser(int userId) async {
    await dioClient.dio.delete(ApiEndpoints.adminUserDetail(userId));
  }
}
