/// Publication status of a manga, matching Mihon's SManga status constants.
enum MangaStatus {
  /// Status not reported by the source.
  unknown,
  ongoing,
  completed,

  /// Licensed elsewhere; source no longer distributes it.
  licensed,

  /// Original publication finished, but scanlation/upload may continue.
  publishingFinished,
  cancelled,
  onHiatus,
}
