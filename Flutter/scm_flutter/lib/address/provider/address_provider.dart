
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/address/data/address_repository.dart';
import 'package:scm_flutter/auth/helperProvider.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository(ref.watch(apiClientProvider));
});

/// All countries rarely change — cache them for the app session, mirroring
/// how the Angular components each called `countryService.getAll()` once
/// in `ngOnInit`.
final countriesProvider = FutureProvider((ref) {
  return ref.watch(addressRepositoryProvider).getCountries();
});