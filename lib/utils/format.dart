import 'package:intl/intl.dart';

import '../api/models.dart';

/// Formatação em pt-BR. Exige `initializeDateFormatting('pt_BR')` no início do app.
abstract final class RotaFormat {
  static final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
  static final _longDate = DateFormat("EEEE, d 'de' MMMM 'de' y", 'pt_BR');
  static final _shortDate = DateFormat("EEE, dd 'de' MMM", 'pt_BR');

  /// Ex.: "R$ 489,00".
  static String currency(num value) => _currency.format(value);

  /// Ex.: "sábado, 14 de novembro de 2026".
  static String longDate(DateTime date) => _longDate.format(date);

  /// Ex.: "sáb., 14 de nov.".
  static String shortDate(DateTime date) => _shortDate.format(date);

  static String duration(int hours) => hours == 1 ? '1 hora' : '$hours horas';

  static String guests(int guests) => guests == 1 ? '1 pessoa' : '$guests pessoas';

  static String category(Category category) => switch (category) {
    Category.aventura => 'Aventura',
    Category.natureza => 'Natureza',
    Category.gastronomia => 'Gastronomia',
    Category.cultura => 'Cultura',
  };
}
