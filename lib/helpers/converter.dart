double coordsToMeters(double coords) {
  return coords * (10 / 73.5);
}

/// Convert meters to time (sec)
double metersToTime(double meters, {double speed = 1.4}) {
  return meters / speed;
}

String remainTime(double time,
    {textHours = 'год.',
    textMminutes = 'хв.',
    textLessThanMinute = 'до 1 хв.'}) {
  final hours = (time / 3600).floor();
  final minutes = ((time % 3600) / 60).floor();
  final seconds = (time % 60).floor();

  if (hours > 0) {
    return '$hours$textHours ${minutes > 0 ? '$minutes$textMminutes' : ''}';
  } else if (minutes > 0) {
    // rounded minutes by seconds
    return seconds > 30
        ? '${minutes + 1}$textMminutes'
        : '$minutes$textMminutes';
  } else {
    return '$textLessThanMinute';
  }
}
