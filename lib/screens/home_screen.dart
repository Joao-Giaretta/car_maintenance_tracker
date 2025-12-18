import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../models/maintenance_model.dart';
import '../models/car_model.dart';
import '../services/database_service.dart';
import 'add_maintenance_screen.dart';
import 'maintenance_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final Car car;

  const HomeScreen({super.key, required this.car});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  final ImagePicker _picker = ImagePicker();
  MaintenanceRecord? _lastMaintenance;
  String _carImagePath = '';
  int _daysSinceLastMaintenance = 0;
  double _totalSpent = 0.0;
  int _maintenanceCount = 0;
  List<MaintenanceRecord> _maintenanceHistory = [];
  bool _isLoadingMore = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    setState(() {
      _isLoading = true;
    });
    
    await _dbService.connect();
    await _loadLastMaintenance();
    await _loadMaintenanceStats();
    await _loadMaintenanceHistory();
    await _loadCarImage();
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadLastMaintenance() async {
    if (widget.car.id == null) return;
    final record = await _dbService.getLastMaintenanceRecord(widget.car.id!);
    setState(() {
      _lastMaintenance = record;
      if (record != null) {
        _daysSinceLastMaintenance = DateTime.now().difference(record.serviceDate!).inDays;
      }
    });
  }

  Future<void> _loadMaintenanceStats() async {
    if (widget.car.id == null) return;
    final records = await _dbService.getMaintenanceRecords(widget.car.id!);
    double total = 0.0;
    for (var record in records) {
      if (record.cost != null) {
        total += record.cost!;
      }
    }
    setState(() {
      _totalSpent = total;
      _maintenanceCount = records.length;
    });
  }

  Future<void> _loadMaintenanceHistory() async {
    if (widget.car.id == null) return;
    final records = await _dbService.getMaintenanceRecordsPaginated(widget.car.id!, 5, 0);
    setState(() {
      _maintenanceHistory = records;
    });
  }

  Future<void> _loadMoreMaintenance() async {
    if (widget.car.id == null) return;
    if (_isLoadingMore || _maintenanceHistory.length >= _maintenanceCount) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    final newRecords = await _dbService.getMaintenanceRecordsPaginated(
      widget.car.id!,
      5,
      _maintenanceHistory.length,
    );

    setState(() {
      _maintenanceHistory.addAll(newRecords);
      _isLoadingMore = false;
    });
  }

  Future<void> _loadCarImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('car_image_${widget.car.id}');
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _carImagePath = imagePath;
      });
    }
  }

  Future<void> _saveCarImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('car_image_${widget.car.id}', path);
    setState(() {
      _carImagePath = path;
    });
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Picture'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await _saveCarImage(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: $e')),
        );
      }
    }
  }

  Future<void> _addNewMaintenance() async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddMaintenanceScreen(carId: widget.car.id),
    );
    
    if (result == true) {
      await _loadLastMaintenance();
      await _loadMaintenanceStats();
      await _loadMaintenanceHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.car.nickname),
            Text(
              widget.car.fullName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading information...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            // Imagem do carro centralizada em moldura redonda
            Center(
              child: GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[800],
                    border: Border.all(color: Colors.grey[600]!, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _carImagePath.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.directions_car, size: 60, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to add photo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : Image.file(
                            File(_carImagePath),
                            fit: BoxFit.contain,
                            width: 200,
                            height: 200,
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Card: Dias desde a última manutenção
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Days since last maintenance',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_daysSinceLastMaintenance',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_lastMaintenance != null) ...[
                        const SizedBox(height: 12),
                        Divider(color: Colors.grey[700]),
                        const SizedBox(height: 8),
                        Text(
                          'Last Maintenance',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('yyyy-MM-dd').format(_lastMaintenance!.serviceDate!),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_lastMaintenance!.problemDescription != null &&
                            _lastMaintenance!.problemDescription!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            _lastMaintenance!.problemDescription!,
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Cards: Total gasto e Quantidade de manutenções
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Card: Total Gasto
                  Expanded(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.attach_money,
                                  size: 20,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Total Spent',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              NumberFormat.currency(locale: 'en_US', symbol: '\$').format(_totalSpent),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Card: Quantidade de Manutenções
                  Expanded(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.build,
                                  size: 20,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Maintenances',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_maintenanceCount',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Histórico de Manutenções
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho do histórico
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$_maintenanceCount records',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Lista de manutenções
                  if (_maintenanceHistory.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'No maintenance records',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    )
                  else
                    ..._maintenanceHistory.map((maintenance) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MaintenanceDetailScreen(
                                    maintenance: maintenance,
                                  ),
                                ),
                              );
                              if (result == true) {
                                await _loadLastMaintenance();
                                await _loadMaintenanceStats();
                                await _loadMaintenanceHistory();
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.build,
                                        size: 24,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          maintenance.title ?? 'Maintenance',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (maintenance.cost != null)
                                        Text(
                                          NumberFormat.currency(
                                            locale: 'en_US',
                                            symbol: '\$',
                                          ).format(maintenance.cost),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      if (maintenance.serviceDate != null) ...[
                                        Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateFormat('yyyy-MM-dd')
                                              .format(maintenance.serviceDate!),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                      if (maintenance.km != null) ...[
                                        const SizedBox(width: 16),
                                        Icon(
                                          Icons.speed,
                                          size: 16,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${NumberFormat('#,###').format(maintenance.km!.toInt())} km',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
                  // Botão carregar mais
                  if (_maintenanceHistory.length < _maintenanceCount)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Center(
                        child: TextButton(
                          onPressed: _isLoadingMore ? null : _loadMoreMaintenance,
                          child: _isLoadingMore
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Load more'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton(
              onPressed: _addNewMaintenance,
              child: const Icon(Icons.add),
            ),
    );
  }
}
  
    
