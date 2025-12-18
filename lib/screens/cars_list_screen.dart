import 'package:flutter/material.dart';
import '../models/car_model.dart';
import '../services/database_service.dart';
import 'add_car_screen.dart';
import 'home_screen.dart';

class CarsListScreen extends StatefulWidget {
  const CarsListScreen({super.key});

  @override
  State<CarsListScreen> createState() => _CarsListScreenState();
}

class _CarsListScreenState extends State<CarsListScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Car> _cars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _dbService.connect();
    await _loadCars();
  }

  Future<void> _loadCars() async {
    setState(() {
      _isLoading = true;
    });
    final cars = await _dbService.getCars();
    setState(() {
      _cars = cars;
      _isLoading = false;
    });
  }

  Future<void> _deleteCar(Car car) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir o carro "${car.nickname}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && car.id != null) {
      await _dbService.deleteCar(car.id!);
      await _loadCars();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Carro excluído com sucesso')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Carros'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cars.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.directions_car, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhum carro cadastrado',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Toque no botão + para adicionar um carro',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _cars.length,
                  itemBuilder: (context, index) {
                    final car = _cars[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.directions_car, size: 40),
                        title: Text(
                          car.nickname,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${car.manufacturer} ${car.model} • ${car.year}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Excluir', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddCarScreen(car: car),
                                ),
                              ).then((_) => _loadCars());
                            } else if (value == 'delete') {
                              _deleteCar(car);
                            }
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(car: car),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCarScreen()),
          );
          await _loadCars();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

