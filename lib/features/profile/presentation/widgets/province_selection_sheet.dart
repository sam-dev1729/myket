import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/geo_repository.dart';
import '../../data/models/geo_models.dart';

/// A bottom sheet that lets the user search and pick a province.
///
/// Requires [countryId] to filter provinces. Pops with the selected [Province]
/// or `null` on cancel.
class ProvinceSelectionSheet extends ConsumerStatefulWidget {
  final String countryId;

  const ProvinceSelectionSheet({super.key, required this.countryId});

  @override
  ConsumerState<ProvinceSelectionSheet> createState() => _ProvinceSelectionSheetState();
}

class _ProvinceSelectionSheetState extends ConsumerState<ProvinceSelectionSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  late Future<List<Province>> _provincesFuture;

  @override
  void initState() {
    super.initState();
    _provincesFuture = ref.read(geoRepositoryProvider).getProvinces(countryId: widget.countryId);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(AppConstants.searchDebounceDuration, () {
      setState(() {
        _provincesFuture = ref
            .read(geoRepositoryProvider)
            .getProvinces(countryId: widget.countryId, search: query);
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
              l10n.selectProvinceTitle,
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
                hintText: l10n.searchHint,
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
            child: FutureBuilder<List<Province>>(
              future: _provincesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('${l10n.genericErrorPrefix}: ${snapshot.error}'));
                }
                final provinces = snapshot.data ?? [];
                if (provinces.isEmpty) {
                  return Center(child: Text(l10n.noItemsFound));
                }
                return ListView.builder(
                  itemCount: provinces.length,
                  itemBuilder: (_, i) {
                    final p = provinces[i];
                    return ListTile(title: Text(p.name), onTap: () => Navigator.pop(context, p));
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
