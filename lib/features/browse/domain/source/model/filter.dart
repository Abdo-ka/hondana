/// Minimal source filter hierarchy (Mihon's Filter system, trimmed to the kinds
/// the UI needs now). Extend with Group/Sort variants when a real source needs
/// them.
sealed class Filter<T> {
  Filter(this.name, this.state);
  final String name;
  T state;
}

/// Non-interactive label / section header.
class HeaderFilter extends Filter<void> {
  // ignore: use_super_parameters — void state can't be a super parameter.
  HeaderFilter(String name) : super(name, null);
}

/// Free-text input (e.g. author).
class TextFilter extends Filter<String> {
  TextFilter(super.name, [super.state = '']);
}

/// Simple on/off.
class CheckBoxFilter extends Filter<bool> {
  CheckBoxFilter(super.name, [super.state = false]);
}

/// Three-way: 0 = ignore, 1 = include, 2 = exclude.
class TriStateFilter extends Filter<int> {
  TriStateFilter(super.name, [super.state = 0]);
  static const int ignore = 0;
  static const int include = 1;
  static const int exclude = 2;
}

/// Single choice from [values]; [state] is the selected index.
class SelectFilter extends Filter<int> {
  SelectFilter(super.name, this.values, [super.state = 0]);
  final List<String> values;
}

typedef FilterList = List<Filter<dynamic>>;
