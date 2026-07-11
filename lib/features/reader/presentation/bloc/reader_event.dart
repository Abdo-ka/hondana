import 'package:hondana/features/reader/domain/reader_preferences.dart';

/// Base type for everything the reader UI dispatches to [ReaderBloc].
sealed class ReaderEvent {
  const ReaderEvent();
}

/// Fired once when the reader opens — kicks off the initial chapter load.
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

/// Show/hide the reader menu overlay (tapped the menu zone or the app bar).
final class ReaderOverlayToggled extends ReaderEvent {
  const ReaderOverlayToggled();
}

/// Per-series reading mode (Mihon viewer_flags); null = follow the app
/// default from Settings > Reader.
final class ReaderModeChanged extends ReaderEvent {
  const ReaderModeChanged(this.mode);
  final ReadingMode? mode;
}

/// Jump to the next chapter (bottom-bar button); honors skip-read/duplicate.
final class ReaderNextChapter extends ReaderEvent {
  const ReaderNextChapter();
}

/// Jump to the previous chapter (bottom-bar button); always allowed to go back.
final class ReaderPrevChapter extends ReaderEvent {
  const ReaderPrevChapter();
}
