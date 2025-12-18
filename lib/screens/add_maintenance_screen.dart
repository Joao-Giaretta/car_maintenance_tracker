import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/maintenance_model.dart';
import '../services/database_service.dart';

class AddMaintenanceScreen extends StatefulWidget {
  final MaintenanceRecord? maintenance;
  final String? carId;

  const AddMaintenanceScreen({super.key, this.maintenance, this.carId});

  @override
  State<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends State<AddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _problemDescriptionController = TextEditingController();
  final _costController = TextEditingController();
  final _mechanicNameController = TextEditingController();
  final _kmController = TextEditingController();
  final _notesController = TextEditingController();
  final _replacedPartController = TextEditingController();
  
  final DatabaseService _dbService = DatabaseService();
  DateTime? _selectedDate;
  List<String> _replacedParts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.maintenance != null) {
      _selectedDate = widget.maintenance!.serviceDate;
      _titleController.text = widget.maintenance!.title ?? '';
      _problemDescriptionController.text = widget.maintenance!.problemDescription ?? '';
      _costController.text = widget.maintenance!.cost?.toStringAsFixed(2) ?? '';
      _mechanicNameController.text = widget.maintenance!.mechanicName ?? '';
      _kmController.text = widget.maintenance!.km?.toStringAsFixed(0) ?? '';
      _notesController.text = widget.maintenance!.notes ?? '';
      _replacedParts = List<String>.from(widget.maintenance!.replacedParts);
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _problemDescriptionController.dispose();
    _costController.dispose();
    _mechanicNameController.dispose();
    _kmController.dispose();
    _notesController.dispose();
    _replacedPartController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    // Obtém o contexto do MaterialApp usando rootNavigator
    final navigatorContext = Navigator.of(context, rootNavigator: true).context;
    
    final DateTime? picked = await showDatePicker(
      context: navigatorContext,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.blue[700]!,
              onPrimary: Colors.white,
              surface: Colors.grey[800]!,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addReplacedPart() {
    if (_replacedPartController.text.trim().isNotEmpty) {
      setState(() {
        _replacedParts.add(_replacedPartController.text.trim());
        _replacedPartController.clear();
      });
    }
  }

  void _removeReplacedPart(int index) {
    setState(() {
      _replacedParts.removeAt(index);
    });
  }

  Future<void> _saveMaintenance() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione uma data')),
        );
        return;
      }

      if (_replacedParts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, adicione pelo menos uma peça substituída')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final maintenance = MaintenanceRecord(
          carId: widget.carId ?? widget.maintenance?.carId,
          serviceDate: _selectedDate,
          title: _titleController.text.trim().isEmpty 
              ? null 
              : _titleController.text.trim(),
          problemDescription: _problemDescriptionController.text.trim(),
          replacedParts: _replacedParts,
          cost: double.parse(_costController.text.trim().replaceAll(',', '.')),
          mechanicName: _mechanicNameController.text.trim(),
          notes: _notesController.text.trim().isEmpty 
              ? null 
              : _notesController.text.trim(),
          km: _kmController.text.trim().isEmpty 
              ? null 
              : double.parse(_kmController.text.trim().replaceAll(',', '.')),
        );

        if (widget.maintenance == null) {
          await _dbService.addMaintenanceRecord(maintenance);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Manutenção adicionada com sucesso!')),
            );
          }
        } else {
          maintenance.id = widget.maintenance!.id;
          await _dbService.updateMaintenanceRecord(maintenance);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Manutenção atualizada com sucesso!')),
            );
          }
        }
        
        if (mounted) {
          Navigator.pop(context, true);
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cabeçalho
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.build, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.maintenance == null 
                          ? 'Adicionar Manutenção' 
                          : 'Editar Manutenção',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Formulário
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Data
                      Builder(
                        builder: (builderContext) => InkWell(
                          onTap: () => _selectDate(builderContext),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Data da Manutenção *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _selectedDate != null
                                  ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                                  : 'Selecione uma data',
                              style: TextStyle(
                                color: _selectedDate != null 
                                    ? Colors.black 
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Título
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título da Manutenção',
                          hintText: 'Ex: Troca de óleo, Revisão geral',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Descrição do problema
                      TextFormField(
                        controller: _problemDescriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição do Problema *',
                          hintText: 'Descreva o problema ou serviço realizado',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, descreva o problema';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Custo
                      TextFormField(
                        controller: _costController,
                        decoration: const InputDecoration(
                          labelText: 'Custo (R\$) *',
                          hintText: '0.00',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, insira o custo';
                          }
                          final cost = double.tryParse(value.trim().replaceAll(',', '.'));
                          if (cost == null || cost < 0) {
                            return 'Por favor, insira um valor válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // KM
                      TextFormField(
                        controller: _kmController,
                        decoration: const InputDecoration(
                          labelText: 'Quilometragem (km)',
                          hintText: 'Ex: 50000',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.speed),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final km = double.tryParse(value.trim().replaceAll(',', '.'));
                            if (km == null || km < 0) {
                              return 'Por favor, insira um valor válido';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Nome do mecânico
                      TextFormField(
                        controller: _mechanicNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome do Mecânico/Oficina *',
                          hintText: 'Ex: João Silva, Oficina XYZ',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, insira o nome do mecânico';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Peças substituídas
                      Text(
                        'Peças Substituídas *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _replacedPartController,
                              decoration: const InputDecoration(
                                hintText: 'Digite o nome da peça',
                                border: OutlineInputBorder(),
                              ),
                              onFieldSubmitted: (_) => _addReplacedPart(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            color: Colors.blue,
                            onPressed: _addReplacedPart,
                          ),
                        ],
                      ),
                      if (_replacedParts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Nenhuma peça adicionada',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else
                        ..._replacedParts.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Chip(
                              label: Text(entry.value),
                              backgroundColor: Colors.blue[900]?.withOpacity(0.3),
                              labelStyle: const TextStyle(color: Colors.white),
                              deleteIconColor: Colors.white70,
                              onDeleted: () => _removeReplacedPart(entry.key),
                            ),
                          );
                        }),
                      const SizedBox(height: 16),
                      // Observações
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Observações',
                          hintText: 'Observações adicionais (opcional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      // Botões
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading 
                                  ? null 
                                  : () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveMaintenance,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Salvar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

