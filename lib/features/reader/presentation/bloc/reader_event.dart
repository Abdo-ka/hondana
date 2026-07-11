import 'package:mihonx/features/reader/domain/reader_preferences.dart';

sealed class ReaderEvent {
  const ReaderEvent();
}

final class ReaderStarted extends ReaderEvent {
  const ReaderStarted();
}

/// Seek within the current chapter (slider) — page index, chapter-relative.
final class ReaderPageChanged extends ReaderEvent {
  const ReaderPageChanged(this.page);
  final int page;
}

/// The visible entry in the continuous item list changed (scroll/swipe).
final class ReaderItemChanged extends ReaderEvent {
  const ReaderItemChanged(this.index);
  final int index;
}

final class ReaderOverlayToggled extends ReaderEvent {
  const ReaderOverlayToggled();
}

/// Per-series reading mode (Mihon viewer_flags); null = follow the app
/// default from Settings > Reader.
final class ReaderModeChanged extends ReaderEvent {
  const ReaderModeChanged(this.mode);
  final ReadingMode? mode;
}

final class ReaderNextChapter extends ReaderEvent {
  const ReaderNextChapter();
}

final class ReaderPrevChapter extends ReaderEvent {
  const ReaderPrevChapter();
}
