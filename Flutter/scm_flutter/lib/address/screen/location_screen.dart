import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/address/provider/address_provider.dart';
import 'package:scm_flutter/entity/address_model.dart';

class LocationSelection {
  const LocationSelection({
    this.countryId,
    this.countryName,
    this.divisionId,
    this.divisionName,
    this.districtId,
    this.districtName,
    this.policeStationId,
    this.policeStationName,
  });

  final int? countryId;
  final String? countryName;
  final int? divisionId;
  final String? divisionName;
  final int? districtId;
  final String? districtName;
  final int? policeStationId;
  final String? policeStationName;

  bool get isComplete => policeStationId != null;
}

/// Reusable Country -> Division -> District -> Police Station cascade.
/// Mirrors the identical dropdown-cascade block repeated in add-customer,
/// customer-profile, and book-parcel (origin + destination) in Angular.
class LocationCascade extends ConsumerStatefulWidget {
  const LocationCascade({
    super.key,
    required this.onChanged,
    this.countryLabel = 'Country',
    this.divisionLabel = 'Division',
    this.districtLabel = 'District',
    this.policeStationLabel = 'Police Station',
  });

  final ValueChanged<LocationSelection> onChanged;
  final String countryLabel;
  final String divisionLabel;
  final String districtLabel;
  final String policeStationLabel;

  @override
  ConsumerState<LocationCascade> createState() => _LocationCascadeState();
}

class _LocationCascadeState extends ConsumerState<LocationCascade> {
  List<AddressItem> _divisions = [];
  List<AddressItem> _districts = [];
  List<AddressItem> _policeStations = [];

  AddressItem? _country;
  AddressItem? _division;
  AddressItem? _district;
  AddressItem? _policeStation;

  bool _loadingDivisions = false;
  bool _loadingDistricts = false;
  bool _loadingPoliceStations = false;

  void _emit() {
    widget.onChanged(
      LocationSelection(
        countryId: _country?.id,
        countryName: _country?.name,
        divisionId: _division?.id,
        divisionName: _division?.name,
        districtId: _district?.id,
        districtName: _district?.name,
        policeStationId: _policeStation?.id,
        policeStationName: _policeStation?.name,
      ),
    );
  }

  Future<void> _onCountryChanged(AddressItem? country) async {
    setState(() {
      _country = country;
      _division = null;
      _district = null;
      _policeStation = null;
      _divisions = [];
      _districts = [];
      _policeStations = [];
    });
    _emit();
    if (country == null) return;

    setState(() => _loadingDivisions = true);
    try {
      final list = await ref
          .read(addressRepositoryProvider)
          .getDivisionsByCountry(country.id);
      if (mounted) setState(() => _divisions = list);
    } finally {
      if (mounted) setState(() => _loadingDivisions = false);
    }
  }

  Future<void> _onDivisionChanged(AddressItem? division) async {
    setState(() {
      _division = division;
      _district = null;
      _policeStation = null;
      _districts = [];
      _policeStations = [];
    });
    _emit();
    if (division == null) return;

    setState(() => _loadingDistricts = true);
    try {
      final list = await ref
          .read(addressRepositoryProvider)
          .getDistrictsByDivision(division.id);
      if (mounted) setState(() => _districts = list);
    } finally {
      if (mounted) setState(() => _loadingDistricts = false);
    }
  }

  Future<void> _onDistrictChanged(AddressItem? district) async {
    setState(() {
      _district = district;
      _policeStation = null;
      _policeStations = [];
    });
    _emit();
    if (district == null) return;

    setState(() => _loadingPoliceStations = true);
    try {
      final list = await ref
          .read(addressRepositoryProvider)
          .getPoliceStationsByDistrict(district.id);
      if (mounted) setState(() => _policeStations = list);
    } finally {
      if (mounted) setState(() => _loadingPoliceStations = false);
    }
  }

  void _onPoliceStationChanged(AddressItem? ps) {
    setState(() => _policeStation = ps);
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final countriesAsync = ref.watch(countriesProvider);

    return Column(
      children: [
        countriesAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Failed to load countries from backend: $e',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
          data: (countries) => _Dropdown<AddressItem>(
            label: widget.countryLabel,
            icon: Icons.flag_outlined,
            value: _country,
            items: countries,
            itemLabel: (c) => c.name,
            onChanged: _onCountryChanged,
          ),
        ),
        const SizedBox(height: 12),
        _Dropdown<AddressItem>(
          label: widget.divisionLabel,
          icon: Icons.signpost_outlined,
          value: _division,
          items: _divisions,
          itemLabel: (d) => d.name,
          enabled: _divisions.isNotEmpty,
          loading: _loadingDivisions,
          onChanged: _onDivisionChanged,
        ),
        const SizedBox(height: 12),
        _Dropdown<AddressItem>(
          label: widget.districtLabel,
          icon: Icons.map_outlined,
          value: _district,
          items: _districts,
          itemLabel: (d) => d.name,
          enabled: _districts.isNotEmpty,
          loading: _loadingDistricts,
          onChanged: _onDistrictChanged,
        ),
        const SizedBox(height: 12),
        _Dropdown<AddressItem>(
          label: widget.policeStationLabel,
          icon: Icons.local_police_outlined,
          value: _policeStation,
          items: _policeStations,
          itemLabel: (p) => p.name,
          enabled: _policeStations.isNotEmpty,
          loading: _loadingPoliceStations,
          onChanged: _onPoliceStationChanged,
        ),
      ],
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.enabled = true,
    this.loading = false,
  });

  final String label;
  final IconData icon;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: loading
            ? const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        )
            : null,
      ),
      hint: Text('Select $label'),
      items: items
          .map((e) => DropdownMenuItem<T>(value: e, child: Text(itemLabel(e))))
          .toList(),
      onChanged: enabled ? onChanged : null,
    );
  }
}