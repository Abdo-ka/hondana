/// Base type for everything the {{feature_name.titleCase()}} UI dispatches to
/// `{{feature_name.pascalCase()}}Bloc`.
sealed class {{feature_name.pascalCase()}}Event {
  const {{feature_name.pascalCase()}}Event();
}

/// Loads the {{feature_name.titleCase()}} data (typically on first build).
final class {{feature_name.pascalCase()}}Started extends {{feature_name.pascalCase()}}Event {
  const {{feature_name.pascalCase()}}Started();
}
