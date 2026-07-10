sealed class UpdatesEvent {
  const UpdatesEvent();
}

final class UpdatesSubscribed extends UpdatesEvent {
  const UpdatesSubscribed();
}

final class UpdatesRefreshed extends UpdatesEvent {
  const UpdatesRefreshed();
}
