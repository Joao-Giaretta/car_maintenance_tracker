import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/maintenance_model.dart';
import '../models/car_model.dart';


class DatabaseService {
  Db? _db;
  DbCollection? _maintenanceCollection;
  DbCollection? _carsCollection;
  bool _isConnected = false;

  Future<void> connect() async {
    if (_isConnected && _db != null) {
      return;
    }
    // A string de conexão NUNCA deve ficar hardcoded no código.
    // Configure a variável de ambiente MONGODB_CONNECTION_STRING no arquivo .env
    final connectionString = dotenv.env['MONGODB_CONNECTION_STRING'];

    if (connectionString == null || connectionString.isEmpty) {
      throw Exception(
        'Variável de ambiente MONGODB_CONNECTION_STRING não configurada. '
        'Crie o arquivo .env (baseado em .env.example) e defina a string de conexão do MongoDB.',
      );
    }

    _db = await Db.create(connectionString);
    await _db!.open();
    _maintenanceCollection = _db!.collection('maintenance_records');
    _carsCollection = _db!.collection('cars');
    _isConnected = true;
  }

  Future<void> disconnect() async {
    if (_db != null) {
      await _db!.close();
      _isConnected = false;
      _db = null;
      _maintenanceCollection = null;
      _carsCollection = null;
    }
  }

  Future<String> addMaintenanceRecord(MaintenanceRecord record) async {
    await connect();
    var result = await _maintenanceCollection!.insert(record.toMap());
    return result['_id'].toString();
  }

  Future<List<MaintenanceRecord>> getMaintenanceRecords(String carId) async {
    await connect();
    final cursor = await _maintenanceCollection!
        .find(where.eq('carId', carId).sortBy('serviceDate', descending: true))
        .toList();
    return cursor.map((doc) => MaintenanceRecord.fromMap(doc)).toList();
  }

  Future<List<MaintenanceRecord>> getMaintenanceRecordsPaginated(String carId, int limit, int skip) async {
    await connect();
    final cursor = await _maintenanceCollection!
        .find(where.eq('carId', carId).sortBy('serviceDate', descending: true).limit(limit).skip(skip))
        .toList();
    return cursor.map((doc) => MaintenanceRecord.fromMap(doc)).toList();
  }

  Future<void> updateMaintenanceRecord(MaintenanceRecord record) async {
    await connect();
    if (record.id == null || record.id!.isEmpty) {
      throw Exception('ID da manutenção não pode ser nulo ou vazio');
    }
    // Garante que o ID seja uma string válida
    final idString = record.id is String ? record.id! : record.id!.toString();
    await _maintenanceCollection!.update(
      where.id(ObjectId.fromHexString(idString)),
      record.toMap(),
    );
  }

  Future<void> deleteMaintenanceRecord(String id) async {
    await connect();
    await _maintenanceCollection!.remove(where.id(ObjectId.fromHexString(id)));
  }
  
  Future<MaintenanceRecord?> getLastMaintenanceRecord(String carId) async {
    await connect();
    var records = await _maintenanceCollection!
        .find(where.eq('carId', carId).sortBy('serviceDate', descending: true).limit(1))
        .toList();
    
    if (records.isNotEmpty) {
      return MaintenanceRecord.fromMap(records.first);
    }
    return null;
  }

  // Car operations
  Future<String> addCar(Car car) async {
    await connect();
    var result = await _carsCollection!.insert(car.toMap());
    return result['_id'].toString();
  }

  Future<List<Car>> getCars() async {
    await connect();
    final cursor = await _carsCollection!.find().toList();
    return cursor.map((doc) => Car.fromMap(doc)).toList();
  }

  Future<void> updateCar(Car car) async {
    await connect();
    if (car.id == null || car.id!.isEmpty) {
      throw Exception('ID do carro não pode ser nulo ou vazio');
    }
    final idString = car.id is String ? car.id! : car.id!.toString();
    await _carsCollection!.update(
      where.id(ObjectId.fromHexString(idString)),
      car.toMap(),
    );
  }

  Future<void> deleteCar(String id) async {
    await connect();
    await _carsCollection!.remove(where.id(ObjectId.fromHexString(id)));
  }

  Future<Car?> getCarById(String id) async {
    await connect();
    var result = await _carsCollection!.findOne(where.id(ObjectId.fromHexString(id)));
    if (result != null) {
      return Car.fromMap(result);
    }
    return null;
  }
}
  
