
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/address/data/address_repository.dart';
import 'package:scm_flutter/auth/helperProvider.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository(ref.watch(apiClientProvider));
});


final countriesProvider = FutureProvider((ref) {
  return ref.watch(addressRepositoryProvider).getCountries();
});