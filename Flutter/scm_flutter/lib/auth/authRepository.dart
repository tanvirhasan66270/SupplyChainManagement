


import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/forgotPassword.dart';
import 'package:scm_flutter/entity/loginModel.dart';
import 'package:scm_flutter/entity/resetPassword.dart';
import 'package:scm_flutter/service/storageService.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class AuthRepository {

  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthRepository(this._apiClient, this._storageService);


  Dio get _dio => _apiClient.dio;


  Future<LoginResponse> login(LoginRequest dto) async {
    final res = await _dio.post(ApiConstants.login, data: dto.toJson());
    final loginRes = LoginResponse.fromJson(res.data as Map<String, dynamic>);
    await _storageService.saveSession(loginRes);
    return loginRes;
  }

  Future<void> logout() => _storageService.clearSession();

  Future<String> forgotPassword(ForgotPasswordRequest dto) async {
    final res = await _dio.post(
      ApiConstants.forgotPassword,
      data: dto.toJson(),
      options: Options(responseType: ResponseType.plain),
    );
    return res.data.toString();
  }

  Future<String> resetPassword(ResetPasswordRequest dto) async {
    final res = await _dio.post(
      ApiConstants.resetPassword,
      data: dto.toJson(),
      options: Options(responseType: ResponseType.plain),
    );
    return res.data.toString();
  }



  Future<String> verifyEmail(String token) async {
    final res = await _dio.get(
      ApiConstants.verifyEmail,
      queryParameters: {'token': token},
      options: Options(responseType: ResponseType.plain),
    );
    return res.data.toString();
  }



}