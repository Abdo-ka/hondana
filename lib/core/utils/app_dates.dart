import 'package:easy_localization/easy_localization.dart';

import 'package:hondana/core/config/app_settings.dart';
import 'package:hondana/core/di/di_container.dart';

/// Formats [date] for display per the Appearance settings (Mihon parity):
/// "Today"/"Yesterday" when relative timestamps are on and the date is within
/// the last two days, otherwise the user's date-format pattern — locale short
/// date when the pattern is '' (the "Default" choice).
String formatAppDate(DateTime? date) {
  if (date == null) return 'updates.unknown_date'.tr();
  final settings = getIt<AppSettings>();
  if (settings.relativeTimestamps) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    if (day == today) return 'updates.today'.tr();
    if (day == today.subtract(const Duration(days: 1))) {
      return 'updates.yesterday'.tr();
    }
  }
  final pattern = settings.dateFormat;
  return pattern.isEmpty
      ? DateFormat.yMd().format(date)
      : DateFormat(pattern).format(date);
}
