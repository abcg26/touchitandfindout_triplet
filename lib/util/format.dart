String two(int n) => n.toString().padLeft(2, '0');

String fmtDate(DateTime t) => '${t.year}-${two(t.month)}-${two(t.day)}';

String fmtTime(DateTime t) =>
    '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';

String fmtStamp(DateTime t) => '${fmtDate(t)} ${fmtTime(t)}';

/// Signed acceleration with three decimals, e.g. "+0.012 G".
String fmtG(double v) {
  var s = v.toStringAsFixed(3);
  if (s == '-0.000') s = '0.000';
  return '${s.startsWith('-') ? '' : '+'}$s G';
}
