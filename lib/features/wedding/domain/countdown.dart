/// Time remaining until [target], clamped to [Duration.zero] once that moment
/// has passed. The comparison is timezone-agnostic because [DateTime.difference]
/// works on absolute instants.
Duration timeUntil(DateTime target, {DateTime? now}) {
  final from = now ?? DateTime.now().toUtc();
  final diff = target.difference(from);
  return diff.isNegative ? Duration.zero : diff;
}
