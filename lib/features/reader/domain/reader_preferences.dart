import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ReadingMode {
  leftToRight,
  rightToLeft,
  vertical,
  webtoon;

  bool get isPaged => this != ReadingMode.webtoon;
  bool get isHorizontal =>
      this == ReadingMode.leftToRight || this == ReadingMode.rightToLeft;
  bool get isReversed => this == ReadingMode.rightToLeft;
}

@lazySingleton
class ReaderPreferences {
  ReaderPreferences(this._prefs);

  final SharedPreferences _prefs;
  static const _kMode = 'reader.mode';

  ReadingMode get readingMode =>
      ReadingMode.values[_prefs.getInt(_kMode) ?? ReadingMode.rightToLeft.index];

  Future<void> setReadingMode(ReadingMode m) => _prefs.setInt(_kMode, m.index);
}
