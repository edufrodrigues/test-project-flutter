import 'package:flutter_test/flutter_test.dart';
import 'package:rota/features/booking/validation.dart';

BookingFormValues _values({
  String name = 'Marina Costa',
  String email = 'marina@exemplo.com',
  String phone = '(11) 98765-4321',
  DateTime? date,
  int? guests = 2,
  String notes = '',
  bool acceptedPolicy = true,
}) {
  return BookingFormValues(
    name: name,
    email: email,
    phone: phone,
    date: date ?? DateTime(2030, 1, 10),
    guests: guests,
    notes: notes,
    acceptedPolicy: acceptedPolicy,
  );
}

void main() {
  group('formatPhone', () {
    test('aplica a máscara conforme a quantidade de dígitos', () {
      expect(formatPhone(''), '');
      expect(formatPhone('1'), '(1');
      expect(formatPhone('11'), '(11');
      expect(formatPhone('119'), '(11) 9');
      expect(formatPhone('1133334444'), '(11) 3333-4444');
      expect(formatPhone('11987654321'), '(11) 98765-4321');
    });

    test('ignora caracteres que não são dígitos e corta em 11 dígitos', () {
      expect(formatPhone('(11) 98765-4321 ramal 9'), '(11) 98765-4321');
      expect(formatPhone('abc'), '');
    });
  });

  group('PhoneInputFormatter', () {
    const formatter = PhoneInputFormatter();

    TextEditingValue edit(String oldText, String newText) =>
        formatter.formatEditUpdate(TextEditingValue(text: oldText), TextEditingValue(text: newText));

    test('formata enquanto digita', () {
      expect(edit('(11) 9876', '(11) 98765').text, '(11) 9876-5');
    });

    test('apagar um caractere da máscara apaga o dígito anterior', () {
      expect(edit('(11) 9876-5', '(11) 9876-').text, '(11) 9876');
    });
  });

  group('validateBooking', () {
    test('aceita um formulário completo', () {
      expect(validateBooking(_values(), 6), isEmpty);
    });

    test('aponta cada campo inválido com a mensagem certa', () {
      final errors = validateBooking(
        const BookingFormValues(
          name: 'Ma',
          email: 'marina@',
          phone: '1198',
          date: null,
          guests: 9,
          notes: '',
          acceptedPolicy: false,
        ),
        6,
      );

      expect(errors, {
        BookingField.date: 'Escolha uma data.',
        BookingField.guests: 'Escolha entre 1 e 6 pessoas.',
        BookingField.name: 'Informe seu nome completo.',
        BookingField.email: 'Informe um e-mail válido.',
        BookingField.phone: 'Informe um telefone com DDD.',
        BookingField.acceptedPolicy: 'Você precisa aceitar a política de cancelamento.',
      });
    });

    test('limita as observações a 300 caracteres', () {
      expect(validateBooking(_values(notes: 'a' * 300), 6), isEmpty);
      expect(validateBooking(_values(notes: 'a' * 301), 6)[BookingField.notes], 'Use no máximo 300 caracteres.');
    });

    test('aceita telefone fixo com 10 dígitos', () {
      expect(validateBooking(_values(phone: '(11) 3333-4444'), 6), isEmpty);
    });
  });
}
