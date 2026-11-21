import '../../../../l10n/app_localizations.dart';
import '../../data/models/lab_test_models.dart';
import 'health_status.dart';

/// Splits an AI advice string into displayable bullet lines.
List<String> splitAdviceLines(String? advice) {
  if (advice == null) return const [];
  return advice
      .split(RegExp(r'[\r\n]+'))
      .map((line) => line.replaceFirst(RegExp(r'^\s*[-•*]\s*'), '').trim())
      .where((line) => line.isNotEmpty)
      .toList();
}

/// Builds the opening assistant message, summarizing the current status.
String buildAssistantGreeting({
  required HealthOverview? overview,
  required AppLocalizations l10n,
}) {
  final status = healthStatusLabel(overview?.overallStatus, l10n);
  return '${l10n.aiGreeting}\n\n${l10n.aiGreetingStatus(status)}';
}

/// Builds a deterministic, data-aware answer for [question].
///
/// This is a local assistant: it only uses the health overview already loaded
/// by the app and never sends the question anywhere.
String buildAssistantReply({
  required String question,
  required HealthOverview? overview,
  required AppLocalizations l10n,
}) {
  final normalized = _normalize(question);
  if (normalized.isEmpty) return l10n.aiFallbackAnswer;

  final markers = overview?.keyMarkers ?? const <HealthKeyMarker>[];

  final matched = _matchMarker(normalized, markers);
  if (matched != null) {
    final range = (matched.refMin != null || matched.refMax != null)
        ? '${matched.refMin ?? '-'} - ${matched.refMax ?? '-'}'
        : '-';
    return l10n.aiMarkerAnswer(
      matched.name ?? matched.code ?? '-',
      matched.value ?? '-',
      matched.unit ?? '',
      range,
      healthStatusLabel(matched.status, l10n),
    );
  }

  if (_containsAny(normalized, ['وضعیت', 'سلامت', 'نتیجه', 'چطور', 'خوبم', 'status', 'overall'])) {
    final abnormal = markers.where((m) => healthStatusSeverity(m.status) > 1).length;
    return l10n.aiOverallAnswer(
      healthStatusLabel(overview?.overallStatus, l10n),
      abnormal,
    );
  }

  final advice = overview?.advice;
  if (_containsAny(normalized, ['توصیه', 'رژیم', 'تغذیه', 'چیکار', 'باید', 'advice', 'diet'])) {
    final lines = splitAdviceLines(advice);
    if (lines.isNotEmpty) {
      return '${l10n.aiAdviceIntro}\n${lines.map((line) => '• $line').join('\n')}';
    }
  }

  final nameList = markers
      .map((marker) => marker.name ?? marker.code)
      .whereType<String>()
      .take(5)
      .join('، ');
  return l10n.aiFallbackAnswerWithMarkers(nameList.isEmpty ? l10n.noData : nameList);
}

/// Normalizes Persian/Arabic characters and lowercases the text.
String _normalize(String value) {
  return value
      .toLowerCase()
      .replaceAll('ي', 'ی')
      .replaceAll('ك', 'ک')
      .replaceAll('‌', ' ')
      .trim();
}

/// Simple bilingual keywords mapped to English marker names.
const Map<String, String> _synonyms = {
  'قند': 'glucose',
  'شکر': 'glucose',
  'کلسترول': 'cholesterol',
  'هموگلوبین': 'hemoglobin',
  'ویتامین': 'vitamin',
  'تیروئید': 'tsh',
  'کبد': 'alt',
  'کلیه': 'creatinine',
  'کراتینین': 'creatinine',
  'اوره': 'bun',
  'پلاکت': 'platelet',
  'گلبول': 'wbc',
  'آهن': 'ferritin',
  'کلسیم': 'calcium',
};

/// Finds the marker mentioned in [question], if any.
HealthKeyMarker? _matchMarker(
  String normalizedQuestion,
  List<HealthKeyMarker> markers,
) {
  final queryTerms = <String>{...normalizedQuestion.split(RegExp(r'\s+'))};
  for (final entry in _synonyms.entries) {
    if (normalizedQuestion.contains(entry.key)) queryTerms.add(entry.value);
  }

  for (final marker in markers) {
    final name = _normalize(marker.name ?? '');
    final code = _normalize(marker.code ?? '');
    if (name.isEmpty && code.isEmpty) continue;
    for (final term in queryTerms) {
      if (term.length < 3) continue;
      if (name.contains(term) || code.contains(term) || term.contains(name) || term.contains(code)) {
        return marker;
      }
    }
  }
  return null;
}

bool _containsAny(String text, List<String> needles) {
  for (final needle in needles) {
    if (text.contains(needle)) return true;
  }
  return false;
}
