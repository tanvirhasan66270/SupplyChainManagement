import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/address_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class AddressRepository {
  AddressRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  Future<List<AddressItem>> getCountries() async {
    final res = await _dio.get(ApiConstants.country);
    if (res.data is List) {
      return (res.data as List)
          .map((e) => AddressItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<AddressItem>> getDivisionsByCountry(int countryId) async {
    final res = await _dio.get(ApiConstants.divisionsByCountry(countryId));
    if (res.data is List) {
      return (res.data as List)
          .map((e) => AddressItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<AddressItem>> getDistrictsByDivision(int divisionId) async {
    final res = await _dio.get(ApiConstants.districtsByDivision(divisionId));
    if (res.data is List) {
      return (res.data as List)
          .map((e) => AddressItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<AddressItem>> getPoliceStationsByDistrict(int districtId) async {
    final res = await _dio.get(ApiConstants.policeStationsByDistrict(districtId));
    if (res.data is List) {
      return (res.data as List)
          .map((e) => AddressItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}