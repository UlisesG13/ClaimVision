
class DateFormatEs {
  DateFormatEs._();

  static const List<String> _meses = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  static String fechaHora(DateTime fecha) {
    final f = fecha.toLocal();
    final dia = f.day;
    final mes = _meses[f.month - 1];
    final hh = f.hour.toString().padLeft(2, '0');
    final mm = f.minute.toString().padLeft(2, '0');
    return '$dia $mes ${f.year} · $hh:$mm';
  }

  /// "10 Oct 2025"
  static String fecha(DateTime fecha) {
    final f = fecha.toLocal();
    return '${f.day} ${_meses[f.month - 1]} ${f.year}';
  }
}
