/// Domain entity for the {{feature_name.titleCase()}} feature.
///
/// Presentation-facing model; keep data-layer types (drift rows, DTOs) out of it.
class {{feature_name.pascalCase()}}Entity {
  const {{feature_name.pascalCase()}}Entity({required this.id});

  /// Stable identifier for this entity.
  final int id;
}
