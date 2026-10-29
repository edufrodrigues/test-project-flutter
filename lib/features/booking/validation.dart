import 'package:flutter/services.dart';

/// Campos do formulário de reserva, na ordem em que aparecem na tela.
enum BookingField { date, guests, name, email, phone, notes, acceptedPolicy }

class BookingFormValues {
  const BookingFormValues({
    required this.name,
    required this.email,
    required this.phone,
    required this.date,
    required this.guests,
    required this.notes,
    required this.acceptedPolicy,
  });

  final String name;
  final String email;
  final String phone;
  final DateTime? date;
  final int? guests;
  final String notes;
  final bool acceptedPolicy;
}

final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

bool isValidEmail(String value) => _emailPattern.hasMatch(value.trim());

String onlyDigits(String value) => value.replaceAll(RegExp(r'\D'), '');

/// Aplica a máscara de telefone brasileiro: (11) 98765-4321.
String formatPhone(String value) {
  final digits = onlyDigits(value);
  final d = digits.length > 11 ? digits.substring(0, 11) : digits;
  if (d.length <= 2) return d.isEmpty ? '' : '($d';
  if (d.length <= 6) return '(${d.substring(0, 2)}) ${d.substring(2)}';
  if (d.length <= 10) return '(${d.substring(0, 2)}) ${d.substring(2, 6)}-${d.substring(6)}';
  return '(${d.substring(0, 2)}) ${d.substring(2, 7)}-${d.substring(7)}';
}

/// Formatter que aplica [formatPhone] enquanto a pessoa digita.
class PhoneInputFormatter extends TextInputFormatter {
  const PhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = onlyDigits(newValue.text);
    // Apagar um caractere da máscara (como ")" ou "-") também apaga o dígito anterior.
    if (newValue.text.length < oldValue.text.length && digits == onlyDigits(oldValue.text) && digits.isNotEmpty) {
      digits = digits.substring(0, digits.length - 1);
    }
    final formatted = formatPhone(digits);
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}

/// Valida o formulário e devolve a mensagem de erro de cada campo inválido.
Map<BookingField, String> validateBooking(BookingFormValues values, int maxGuests) {
  final errors = <BookingField, String>{};

  if (values.date == null) errors[BookingField.date] = 'Escolha uma data.';

  final guests = values.guests;
  if (guests == null || guests < 1 || guests > maxGuests) {
    errors[BookingField.guests] = 'Escolha entre 1 e $maxGuests pessoas.';
  }

  if (values.name.trim().length < 3) errors[BookingField.name] = 'Informe seu nome completo.';
  if (!isValidEmail(values.email)) errors[BookingField.email] = 'Informe um e-mail válido.';

  final phoneDigits = onlyDigits(values.phone).length;
  if (phoneDigits < 10 || phoneDigits > 11) errors[BookingField.phone] = 'Informe um telefone com DDD.';

  if (values.notes.length > 300) errors[BookingField.notes] = 'Use no máximo 300 caracteres.';
  if (!values.acceptedPolicy) {
    errors[BookingField.acceptedPolicy] = 'Você precisa aceitar a política de cancelamento.';
  }

  return errors;
}
