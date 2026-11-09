import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class GeneticTestTab extends StatelessWidget {
  const GeneticTestTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.geneticTab,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}