import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/geo_repository.dart';
import '../../data/models/geo_models.dart';

/// A bottom sheet that lets the user search and pick a city.
///
/// If [provinceId] is provided, only cities within that province are loaded.
/// Pops with the selected [City] as the result, or `null` on cancel.
class CitySelectionSheet extends ConsumerStatefulWidget {
  final String? provinceId;

  const CitySelectionSheet({super.key, this.provinceId});

  @override
  ConsumerState<CitySelectionSheet> createState() => _CitySelectionSheetState();
}

class _CitySelectionSheetState extends ConsumerState<CitySelectionSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  late Future<List<City>> _citiesFuture;

  @override
  void initState() {
    super.initState();
    _citiesFuture = ref.read(geoRepositoryProvider).getCities(provinceId: widget.provinceId);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Triggers a debounced server search.
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(AppConstants.searchDebounceDuration, () {
      setState(() {
        _citiesFuture = ref
            .read(geoRepositoryProvider)
            .getCities(provinceId: widget.provinceId, search: query);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.of(context).size.height * AppConstants.bottomSheetHeightFactor,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.largeCardRadius)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.textTertiaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
            child: Text(
              l10n.citySelectionTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: l10n.searchCityHint,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: context.surfaceVariantColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Expanded(
            child: FutureBuilder<List<City>>(
              future: _citiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('${l10n.genericErrorPrefix}: ${snapshot.error}'));
                }
                final cities = snapshot.data ?? [];
                if (cities.isEmpty) {
                  return Center(child: Text(l10n.noCitiesFound));
                }
                return ListView.builder(
                  itemCount: cities.length,
                  itemBuilder: (_, i) {
                    final city = cities[i];
                    return ListTile(
                      title: Text(city.name),
                      onTap: () => Navigator.pop(context, city),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
