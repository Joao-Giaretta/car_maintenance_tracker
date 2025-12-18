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
    // Configure as variáveis de ambiente MONGODB_CONNECTION_STRING e DATABASE_NAME no arquivo .env
    final baseConnectionString = dotenv.env['MONGODB_CONNECTION_STRING'];
    final databaseName = dotenv.env['DATABASE_NAME'];

    print('🔌 Attempting to connect to MongoDB...');
    print('Base connection string: ${baseConnectionString?.substring(0, baseConnectionString.length > 30 ? 30 : baseConnectionString.length)}...');
    print('Database name: $databaseName');

    if (baseConnectionString == null || baseConnectionString.isEmpty) {
      print('❌ MONGODB_CONNECTION_STRING is null or empty');
      throw Exception(
        'Environment variable MONGODB_CONNECTION_STRING is not configured. '
        'Create the .env file (based on .env.example) and define the base MongoDB connection string.',
      );
    }

    // Se DATABASE_NAME estiver definido e a string base não tiver um banco específico,
    // montamos a string final usando o nome do banco.
    String finalConnectionString = baseConnectionString;
    if (databaseName != null && databaseName.isNotEmpty) {
      // Verifica se a string já contém um nome de banco (parte após o host)
      final uriHasPath =
          baseConnectionString.split('/').length > 3 && !baseConnectionString.endsWith('/');

      if (!uriHasPath) {
        // Adiciona o nome do banco, respeitando se já termina com '/'
        if (baseConnectionString.endsWith('/')) {
          finalConnectionString = '$baseConnectionString$databaseName';
        } else {
          finalConnectionString = '$baseConnectionString/$databaseName';
        }
      }
    }

    try {
      _db = await Db.create(finalConnectionString);
      print('📦 Database object created, opening connection...');
      await _db!.open();
      print('✅ Successfully connected to MongoDB!');
      _maintenanceCollection = _db!.collection('maintenance_records');
      _carsCollection = _db!.collection('cars');
      _isConnected = true;
    } catch (e) {
      print('❌ Error connecting to MongoDB: $e');
      print('Connection string used: ${finalConnectionString.substring(0, finalConnectionString.length > 50 ? 50 : finalConnectionString.length)}...');
      rethrow;
    }
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
      throw Exception('Maintenance ID cannot be null or empty');
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
      throw Exception('Car ID cannot be null or empty');
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
  
