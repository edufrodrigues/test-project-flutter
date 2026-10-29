import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../utils/storage.dart';
import 'data.dart';
import 'models.dart';
import 'scenario.dart';

/*
 * API falsa. Tudo fica em memória (e no storage do dispositivo), com atraso
 * artificial e falhas controladas pelo cenário atual.
 */

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Recurso não encontrado.']);
}

/// Mensagem para mostrar na tela a partir de um erro da API.
String errorMessage(Object error) => error is ApiException ? error.message : 'Erro inesperado.';

/// Notifica quando os dados voltam ao estado inicial ([reset]), para as telas recarregarem.
class FakeApi extends ChangeNotifier {
  FakeApi({required this.store, required this.scenario, this.latencyOverride, Random? random})
    : _random = random ?? Random() {
    _experiences = seedExperiences();
    _bookings = _readBookings() ?? seedBookings(_experiences);
    _profile = _readProfile() ?? seedProfile;
  }

  final KeyValueStore store;
  final ScenarioController scenario;
  final Random _random;

  /// Nos testes, troca o atraso de cada cenário por um valor fixo.
  final Duration? latencyOverride;

  late List<Experience> _experiences;
  late List<Booking> _bookings;
  late Profile _profile;

  /// Simula uma requisição: aplica atraso e falha conforme o cenário.
  Future<T> _request<T>(T Function(Scenario scenario) resolve, {bool mutation = false}) async {
    final current = scenario.value;
    await Future<void>.delayed(latencyOverride ?? current.latency);
    if (current == Scenario.erro || (mutation && current == Scenario.erroEnvio)) {
      throw const ApiException('Falha simulada de conexão com o servidor.');
    }
    return resolve(current);
  }

  Future<List<Experience>> listExperiences() {
    return _request((scenario) => scenario == Scenario.vazio ? <Experience>[] : List.unmodifiable(_experiences));
  }

  Future<Experience> getExperience(String id) {
    return _request((scenario) {
      if (scenario == Scenario.vazio) throw const NotFoundException('Experiência não encontrada.');
      return _findExperience(id);
    });
  }

  Future<List<Booking>> listBookings() {
    return _request((scenario) => scenario == Scenario.vazio ? <Booking>[] : List.of(_bookings));
  }

  Future<Booking> getBooking(String id) => _request((_) => _findBooking(id));

  Future<Booking> createBooking(BookingInput input) {
    return _request((_) {
      final experience = _findExperience(input.experienceId);
      final booking = Booking(
        id: _generateCode(),
        experienceId: experience.id,
        experienceTitle: experience.title,
        location: experience.location,
        art: experience.art,
        date: input.date,
        guests: input.guests,
        total: experience.price * input.guests,
        name: input.name,
        email: input.email,
        phone: input.phone,
        notes: input.notes,
        status: BookingStatus.confirmada,
        createdAt: DateTime.now(),
      );
      _saveBookings([booking, ..._bookings]);
      return booking;
    }, mutation: true);
  }

  Future<Booking> cancelBooking(String id) {
    return _request((_) {
      final updated = _findBooking(id).copyWith(status: BookingStatus.cancelada);
      _saveBookings([for (final item in _bookings) item.id == id ? updated : item]);
      return updated;
    }, mutation: true);
  }

  Future<Profile> getProfile() => _request((_) => _profile);

  Future<Profile> updateProfile(Profile next) {
    return _request((_) {
      _profile = next;
      store.write(StorageKeys.profile, jsonEncode(next.toJson()));
      return _profile;
    }, mutation: true);
  }

  /// Volta os dados ao estado inicial. Usado pelo painel de cenários e pelos testes.
  void reset() {
    _experiences = seedExperiences();
    _saveBookings(seedBookings(_experiences));
    _profile = seedProfile;
    store.write(StorageKeys.profile, jsonEncode(seedProfile.toJson()));
    notifyListeners();
  }

  Experience _findExperience(String id) {
    for (final experience in _experiences) {
      if (experience.id == id) return experience;
    }
    throw const NotFoundException('Experiência não encontrada.');
  }

  Booking _findBooking(String id) {
    for (final booking in _bookings) {
      if (booking.id == id) return booking;
    }
    throw const NotFoundException('Reserva não encontrada.');
  }

  String _generateCode() {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final code = List.generate(4, (_) => alphabet[_random.nextInt(alphabet.length)]).join();
    return 'RT-$code';
  }

  void _saveBookings(List<Booking> next) {
    _bookings = next;
    store.write(StorageKeys.bookings, jsonEncode([for (final booking in next) booking.toJson()]));
  }

  List<Booking>? _readBookings() {
    final raw = store.read(StorageKeys.bookings);
    if (raw == null) return null;
    try {
      return [for (final item in jsonDecode(raw) as List) Booking.fromJson(item as Map<String, dynamic>)];
    } catch (_) {
      // Dado corrompido ou de outra versão: volta para os dados de exemplo.
      return null;
    }
  }

  Profile? _readProfile() {
    final raw = store.read(StorageKeys.profile);
    if (raw == null) return null;
    try {
      return Profile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
