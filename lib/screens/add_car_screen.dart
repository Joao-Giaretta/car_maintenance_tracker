import 'package:flutter/material.dart';
import '../models/car_model.dart';
import '../services/database_service.dart';

class AddCarScreen extends StatefulWidget {
  final Car? car;

  const AddCarScreen({super.key, this.car});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.car != null) {
      _nicknameController.text = widget.car!.nickname;
      _manufacturerController.text = widget.car!.manufacturer;
      _modelController.text = widget.car!.model;
      _yearController.text = widget.car!.year.toString();
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _saveCar() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _dbService.connect();
        
        final car = Car(
          id: widget.car?.id,
          nickname: _nicknameController.text.trim(),
          manufacturer: _manufacturerController.text.trim(),
          model: _modelController.text.trim(),
          year: int.parse(_yearController.text.trim()),
        );

        if (widget.car == null) {
          await _dbService.addCar(car);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Carro adicionado com sucesso!')),
            );
          }
        } else {
          await _dbService.updateCar(car);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Carro atualizado com sucesso!')),
            );
          }
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.car == null ? 'Adicionar Carro' : 'Editar Carro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Apelido do Carro',
                  hintText: 'Ex: Meu Carro, Carro da Família',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira um apelido para o carro';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _manufacturerController,
                decoration: const InputDecoration(
                  labelText: 'Fabricante',
                  hintText: 'Ex: Toyota, Volkswagen, Ford',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira o fabricante';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  hintText: 'Ex: Corolla, Gol, Fiesta',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira o modelo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Ano',
                  hintText: 'Ex: 2020',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira o ano';
                  }
                  final year = int.tryParse(value.trim());
                  if (year == null) {
                    return 'Por favor, insira um ano válido';
                  }
                  if (year < 1900 || year > DateTime.now().year + 1) {
                    return 'Por favor, insira um ano válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveCar,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.car == null ? 'Adicionar Carro' : 'Salvar Alterações',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

