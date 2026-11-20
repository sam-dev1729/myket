import 'package:flutter_test/flutter_test.dart';
import 'package:myket/core/theme/app_theme.dart';
import 'package:myket/features/lab_test/presentation/widgets/human_body_view.dart';
import 'package:myket/l10n/app_localizations_fa.dart';

void main() {
  final l10n = AppLocalizationsFa();

  group('bodyOrganName', () {
    test('returns the localized name for every known organ', () {
      for (final organ in kOrgans) {
        expect(
          bodyOrganName(l10n, organ.id),
          isNotEmpty,
          reason: 'missing label for ${organ.id}',
        );
        expect(
          bodyOrganName(l10n, organ.id),
          isNot(organ.id),
          reason: '${organ.id} should not fall back to its raw id',
        );
      }
    });

    test('falls back to the raw id for unknown organs', () {
      expect(bodyOrganName(l10n, 'unknown'), 'unknown');
    });
  });

  group('bodyStatusName', () {
    test('returns a distinct localized label for each status', () {
      final labels = OrganStatus.values.map((s) => bodyStatusName(l10n, s)).toSet();
      expect(labels.length, OrganStatus.values.length);
    });
  });

  group('HumanBodyView helpers', () {
    test('colorOf maps every status to a theme status color', () {
      expect(HumanBodyView.colorOf(OrganStatus.normal), AppTheme.success);
      expect(HumanBodyView.colorOf(OrganStatus.attention), AppTheme.warning);
      expect(HumanBodyView.colorOf(OrganStatus.abnormal), AppTheme.error);
    });

    test('iconOf maps every status to a distinct icon', () {
      final icons = OrganStatus.values.map(HumanBodyView.iconOf).toSet();
      expect(icons.length, OrganStatus.values.length);
    });
  });

  group('kOrgans', () {
    test('contains unique ids', () {
      final ids = kOrgans.map((o) => o.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every organ has at least one anchor inside the viewBox', () {
      for (final organ in kOrgans) {
        expect(organ.anchors, isNotEmpty, reason: '${organ.id} has no anchors');
        for (final anchor in organ.anchors) {
          expect(kBodyViewBox.contains(anchor), isTrue, reason: '${organ.id} anchor outside viewBox');
        }
      }
    });
  });
}
