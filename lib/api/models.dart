import 'package:flutter/painting.dart';

import '../utils/date.dart';

enum Category { aventura, natureza, gastronomia, cultura }

/// Cenas disponíveis para a ilustração de cada experiência.
enum ArtScene { montanha, mar, cidade, vinhedo }

/// Paleta da ilustração desenhada em código (`ExperienceArt`).
class ArtPalette {
  const ArtPalette({
    required this.scene,
    required this.skyTop,
    required this.skyBottom,
    required this.far,
    required this.near,
    required this.sun,
  });

  final ArtScene scene;
  final Color skyTop;
  final Color skyBottom;
  final Color far;
  final Color near;
  final Color sun;

  factory ArtPalette.fromJson(Map<String, dynamic> json) => ArtPalette(
    scene: ArtScene.values.byName(json['scene'] as String),
    skyTop: _parseColor(json['skyTop'] as String),
    skyBottom: _parseColor(json['skyBottom'] as String),
    far: _parseColor(json['far'] as String),
    near: _parseColor(json['near'] as String),
    sun: _parseColor(json['sun'] as String),
  );

  Map<String, dynamic> toJson() => {
    'scene': scene.name,
    'skyTop': _hex(skyTop),
    'skyBottom': _hex(skyBottom),
    'far': _hex(far),
    'near': _hex(near),
    'sun': _hex(sun),
  };

  static Color _parseColor(String hex) => Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));

  static String _hex(Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}

class Experience {
  const Experience({
    required this.id,
    required this.title,
    required this.city,
    required this.state,
    required this.category,
    required this.summary,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviewsCount,
    required this.durationHours,
    required this.maxGuests,
    required this.meetingPoint,
    required this.highlights,
    required this.includes,
    required this.availableDates,
    required this.art,
  });

  final String id;
  final String title;
  final String city;
  final String state;
  final Category category;
  final String summary;
  final String description;

  /// Preço por pessoa, em reais.
  final int price;
  final double rating;
  final int reviewsCount;
  final int durationHours;
  final int maxGuests;
  final String meetingPoint;
  final List<String> highlights;
  final List<String> includes;
  final List<DateTime> availableDates;
  final ArtPalette art;

  String get location => '$city, $state';
}

enum BookingStatus { confirmada, cancelada }

class Booking {
  const Booking({
    required this.id,
    required this.experienceId,
    required this.experienceTitle,
    required this.location,
    required this.art,
    required this.date,
    required this.guests,
    required this.total,
    required this.name,
    required this.email,
    required this.phone,
    required this.notes,
    required this.status,
    required this.createdAt,
  });

  /// Código da reserva, ex.: RT-7Q2K.
  final String id;
  final String experienceId;
  final String experienceTitle;
  final String location;
  final ArtPalette art;
  final DateTime date;
  final int guests;
  final int total;
  final String name;
  final String email;
  final String phone;
  final String notes;
  final BookingStatus status;
  final DateTime createdAt;

  Booking copyWith({BookingStatus? status}) => Booking(
    id: id,
    experienceId: experienceId,
    experienceTitle: experienceTitle,
    location: location,
    art: art,
    date: date,
    guests: guests,
    total: total,
    name: name,
    email: email,
    phone: phone,
    notes: notes,
    status: status ?? this.status,
    createdAt: createdAt,
  );

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'] as String,
    experienceId: json['experienceId'] as String,
    experienceTitle: json['experienceTitle'] as String,
    location: json['location'] as String,
    art: ArtPalette.fromJson(json['art'] as Map<String, dynamic>),
    date: RotaDate.parseIso(json['date'] as String),
    guests: json['guests'] as int,
    total: json['total'] as int,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    notes: json['notes'] as String,
    status: BookingStatus.values.byName(json['status'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'experienceId': experienceId,
    'experienceTitle': experienceTitle,
    'location': location,
    'art': art.toJson(),
    'date': RotaDate.toIso(date),
    'guests': guests,
    'total': total,
    'name': name,
    'email': email,
    'phone': phone,
    'notes': notes,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };
}

class BookingInput {
  const BookingInput({
    required this.experienceId,
    required this.date,
    required this.guests,
    required this.name,
    required this.email,
    required this.phone,
    required this.notes,
  });

  final String experienceId;
  final DateTime date;
  final int guests;
  final String name;
  final String email;
  final String phone;
  final String notes;
}

class Profile {
  const Profile({
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.memberSince,
  });

  final String name;
  final String email;
  final String phone;
  final String city;
  final String memberSince;

  Profile copyWith({String? name, String? email, String? phone, String? city}) => Profile(
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    city: city ?? this.city,
    memberSince: memberSince,
  );

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    city: json['city'] as String,
    memberSince: json['memberSince'] as String,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'city': city,
    'memberSince': memberSince,
  };

  @override
  bool operator ==(Object other) =>
      other is Profile &&
      other.name == name &&
      other.email == email &&
      other.phone == phone &&
      other.city == city &&
      other.memberSince == memberSince;

  @override
  int get hashCode => Object.hash(name, email, phone, city, memberSince);
}
