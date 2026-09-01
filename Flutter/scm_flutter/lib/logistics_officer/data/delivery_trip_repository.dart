import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/delivery_trip_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class DeliveryTripRepository {
  DeliveryTripRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  // (GET /api/delivery-trips)
  Future<List<DeliveryTripResponseModel>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.deliveryTrips);
      final List data = response.data ?? [];
      return data.map((e) => DeliveryTripResponseModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load delivery trips: $e');
    }
  }

  // (GET /api/delivery-trips/{id})
  Future<DeliveryTripResponseModel> getById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.deliveryTripById(id));
      return DeliveryTripResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get delivery trip by id: $e');
    }
  }

  // (POST /api/delivery-trips)
  Future<DeliveryTripResponseModel> create(DeliveryTripRequestModel request) async {
    try {
      final response = await _dio.post(ApiConstants.deliveryTrips, data: request.toJson());
      return DeliveryTripResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create delivery trip: $e');
    }
  }

  //  (PUT /api/delivery-trips/{id})
  Future<DeliveryTripResponseModel> update(int id, DeliveryTripRequestModel request) async {
    try {
      final response = await _dio.put(ApiConstants.deliveryTripById(id), data: request.toJson());
      return DeliveryTripResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update delivery trip: $e');
    }
  }

  //  (PATCH /api/delivery-trips/{id}/status)
  Future<DeliveryTripResponseModel> changeStatus(
      int id, String status, MultipartFile? signature, MultipartFile? photo) async {
    try {
      FormData formData = FormData.fromMap({
        'status': status,
        'signature': ?signature,
        'photo': ?photo,
      });

      final response = await _dio.patch(
        ApiConstants.updateDeliveryTripStatus(id),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return DeliveryTripResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to change trip status: $e');
    }
  }

  //  (DELETE /api/delivery-trips/{id})
  Future<void> delete(int id) async {
    try {
      await _dio.delete(ApiConstants.deliveryTripById(id));
    } catch (e) {
      throw Exception('Failed to delete delivery trip: $e');
    }
  }
}