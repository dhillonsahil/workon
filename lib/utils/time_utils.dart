String formatMinutes(int totalMinutes) {
  if (totalMinutes == 0) return "0 mins";

  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;

  final h = hours > 0 ? '$hours hr${hours == 1 ? '' : 's'}' : '';
  final m = minutes > 0 ? '$minutes min${minutes == 1 ? '' : 's'}' : '';

  return [h, m].where((s) => s.isNotEmpty).join(' ');
}

String formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

String formatMonthYear(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.year}';
}
