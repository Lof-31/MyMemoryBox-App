/// Number of calendar days from [from] to [to], ignoring the time of day.
///
/// Computed in UTC so that daylight saving transitions (23 h or 25 h days)
/// don't shift the result by one.
int daysBetween(DateTime from, DateTime to) {
  final a = DateTime.utc(from.year, from.month, from.day);
  final b = DateTime.utc(to.year, to.month, to.day);
  return b.difference(a).inDays;
}
