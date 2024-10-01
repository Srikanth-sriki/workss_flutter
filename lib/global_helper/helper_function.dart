String timeAgo(DateTime updatedAt) {
  DateTime now = DateTime.now();
  Duration difference = now.difference(updatedAt);

  if (difference.inDays > 0) {
    int days = difference.inDays;
    return "${days}d ago";
  } else if (difference.inHours > 0) {
    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);
    return "${hours}h ${minutes}m ago";
  } else if (difference.inMinutes > 0) {
    int minutes = difference.inMinutes;
    int seconds = difference.inSeconds.remainder(60);
    return "${minutes}m ${seconds}s ago";
  } else {
    int seconds = difference.inSeconds;
    return "${seconds}s ago";
  }
}

String capitalizeFirstLetter(String input) {
  if (input.isEmpty) {
    return input;
  }
  return input[0].toUpperCase() + input.substring(1).toLowerCase();
}

String capitalizeEachWord(String input) {
  return input.split(' ').map((word) => capitalizeFirstLetter(word)).join(' ');
}
