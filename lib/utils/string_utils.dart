String getDurationString(Duration duration) {
  String result = '';
  int hours = duration.inHours;
  int minutes = duration.inMinutes - hours * Duration.minutesPerHour;
  int seconds = duration.inSeconds -
      hours * Duration.secondsPerHour -
      minutes * Duration.secondsPerMinute;
  if (duration.inHours > 0) result += hours.toString().padLeft(2, '0') + ':';
  result += minutes.toString() + ':' + seconds.toString().padLeft(2, '0');
  return result;
}
