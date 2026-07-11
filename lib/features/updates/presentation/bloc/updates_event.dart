/// Base type for events handled by [UpdatesBloc].
sealed class UpdatesEvent {
  const UpdatesEvent();
}

/// Opens the live subscription to the updates stream (fired on page mount).
final class UpdatesSubscribed extends UpdatesEvent {
  const UpdatesSubscribed();
}

/// Requests a full library sync to fetch new chapters (pull-to-refresh / button).
final class UpdatesRefreshed extends UpdatesEvent {
  const UpdatesRefreshed();
}
