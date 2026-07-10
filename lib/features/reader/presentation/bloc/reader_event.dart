import 'package:mihonx/features/reader/domain/reader_preferences.dart';

sealed class ReaderEvent {
  const ReaderEvent();
}

final class ReaderStarted extends ReaderEvent {
  const ReaderStarted();
}

final class ReaderPageChanged extends ReaderEvent {
  const ReaderPageChanged(this.page);
  final int page;
}

final class ReaderOverlayToggled extends ReaderEvent {
  const ReaderOverlayToggled();
}

final class ReaderModeChanged extends ReaderEvent {
  const ReaderModeChanged(this.mode);
  final ReadingMode mode;
}

final class ReaderNextChapter extends ReaderEvent {
  const ReaderNextChapter();
}

final class ReaderPrevChapter extends ReaderEvent {
  const ReaderPrevChapter();
}
