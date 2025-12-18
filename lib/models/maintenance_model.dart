import 'package:mongo_dart/mongo_dart.dart';

class MaintenanceRecord {
  String? id;
  String? carId;
  DateTime? serviceDate;
  String? title;
  String? problemDescription;
  List<String> replacedParts;
  double? cost;
  String? mechanicName;
  String? notes;
  double? km;

  MaintenanceRecord({
    this.id,
    this.carId,
    required this.serviceDate,
    this.title,
    required this.problemDescription,
    required this.replacedParts,
    required this.cost,
    required this.mechanicName,
    this.notes,
    this.km,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'carId': carId,
      'serviceDate': serviceDate?.toIso8601String(),
      'title': title,
      'problemDescription': problemDescription,
      'replacedParts': replacedParts,
      'cost': cost,
      'mechanicName': mechanicName,
      'notes': notes,
      'km': km,
    };
    // Não inclui o ID no toMap, o MongoDB usa _id automaticamente
    return map;
  }

  factory MaintenanceRecord.fromMap(Map<String, dynamic> map) {
    String? idValue;
    if (map['id'] != null) {
      idValue = map['id'].toString();
    } else if (map['_id'] != null) {
      // Se _id é um ObjectId, converte para string hexadecimal
      if (map['_id'] is ObjectId) {
        idValue = (map['_id'] as ObjectId).toHexString();
      } else {
        idValue = map['_id'].toString();
      }
    }
    
    return MaintenanceRecord(
      id: idValue,
      carId: map['carId'],
      serviceDate: DateTime.parse(map['serviceDate']),
      title: map['title'],
      problemDescription: map['problemDescription'],
      replacedParts: List<String>.from(map['replacedParts']),
      cost: map['cost']?.toDouble(),
      mechanicName: map['mechanicName'],
      notes: map['notes'],
      km: map['km']?.toDouble(),
    );
  }
}