import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/address_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class AddressRepository {
  AddressRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  /// Fetch all countries dynamically from backend API (GET /api/country)
  Future<List<AddressItem>> getCountries() async {
    final res = await _dio.get(ApiConstants.country);
    if (res.data is List) {
      return (res.data as List)
          .map((e) => AddressItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Fetch divisions by country ID dynamically from backend API (GET /api/division/country/{countryId})
  Future<List<AddressItem>> getDivisionsByCountry(int countryId) async {
    final res = await _dio.get(ApiConstants.divisionsByCountry(countryId));
    if (res.data is List) {
      return (res.data as List)
          .map((e) => AddressItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Fetch districts by division ID dynamically from backend API (GET /api/district/division/{divisionId})
  Future<List<AddressItem>> getDistrictsByDivision(int divisionId) async {
    final res = await _dio.get(ApiConstants.districtsByDivision(divisionId));
    if (res.data is List) {
      return (res.data as List)
          .map((e) => AddressItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Fetch police stations by district ID dynamically from backend API (GET /api/policestation/district/{districtId})
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