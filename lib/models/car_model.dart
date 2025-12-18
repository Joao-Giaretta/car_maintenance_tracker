import 'package:mongo_dart/mongo_dart.dart';

class Car {
  String? id;
  String nickname;
  String manufacturer;
  String model;
  int year;

  Car({
    this.id,
    required this.nickname,
    required this.manufacturer,
    required this.model,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'nickname': nickname,
      'manufacturer': manufacturer,
      'model': model,
      'year': year,
    };
    return map;
  }

  factory Car.fromMap(Map<String, dynamic> map) {
    String? idValue;
    if (map['id'] != null) {
      idValue = map['id'].toString();
    } else if (map['_id'] != null) {
      if (map['_id'] is ObjectId) {
        idValue = (map['_id'] as ObjectId).toHexString();
      } else {
        idValue = map['_id'].toString();
      }
    }

    return Car(
      id: idValue,
      nickname: map['nickname'] ?? '',
      manufacturer: map['manufacturer'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? 0,
    );
  }

  String get fullName => '$manufacturer $model ($year)';
}

