/// Utilitários de data. As datas da API são só dia (sem hora), no fuso local.
abstract final class RotaDate {
  /// Hoje à meia-noite. Pode ser trocado nos testes para fixar o "hoje".
  static DateTime Function() now = DateTime.now;

  static DateTime today() {
    final current = now();
    return DateTime(current.year, current.month, current.day);
  }

  static DateTime addDays(DateTime date, int days) => DateTime(date.year, date.month, date.day + days);

  /// Converte para YYYY-MM-DD.
  static String toIso(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  /// Lê YYYY-MM-DD como data local à meia-noite.
  static DateTime parseIso(String value) {
    final parts = value.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }

  /// Indica se a data é hoje ou no futuro.
  static bool isUpcoming(DateTime date) => !date.isBefore(today());
}
