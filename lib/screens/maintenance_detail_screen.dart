import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/maintenance_model.dart';
import '../services/database_service.dart';
import 'add_maintenance_screen.dart';

class MaintenanceDetailScreen extends StatelessWidget {
  final MaintenanceRecord maintenance;

  const MaintenanceDetailScreen({
    super.key,
    required this.maintenance,
  });

  Future<void> _deleteMaintenance(BuildContext context, DatabaseService dbService) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir esta manutenção?'),
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

    if (confirm == true && maintenance.id != null) {
      await dbService.deleteMaintenanceRecord(maintenance.id!);
      if (context.mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Manutenção excluída com sucesso')),
        );
      }
    }
  }

  Future<void> _editMaintenance(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddMaintenanceScreen(maintenance: maintenance),
    );
    
    if (result == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final NumberFormat numberFormat = NumberFormat('#,###');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Manutenção'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editMaintenance(context),
            tooltip: 'Editar',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteMaintenance(context, dbService),
            tooltip: 'Excluir',
            color: Colors.red,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card principal com título e valor
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.build,
                          size: 32,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            maintenance.title ?? 'Manutenção',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (maintenance.cost != null)
                          Text(
                            currencyFormat.format(maintenance.cost),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Informações principais
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informações Principais',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Data',
                      maintenance.serviceDate != null
                          ? DateFormat('dd/MM/yyyy').format(maintenance.serviceDate!)
                          : 'Não informado',
                    ),
                    if (maintenance.km != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.speed,
                        'Quilometragem',
                        '${numberFormat.format(maintenance.km!.toInt())} km',
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.person,
                      'Mecânico/Oficina',
                      maintenance.mechanicName ?? 'Não informado',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Descrição do problema
            if (maintenance.problemDescription != null &&
                maintenance.problemDescription!.isNotEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.description, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Descrição do Problema',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        maintenance.problemDescription!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Peças substituídas
            if (maintenance.replacedParts.isNotEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.build_circle, color: Colors.blue[400]),
                          const SizedBox(width: 8),
                          const Text(
                            'Peças Substituídas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: maintenance.replacedParts.map((part) {
                          return Chip(
                            label: Text(part),
                            backgroundColor: Colors.blue[900]?.withOpacity(0.3),
                            labelStyle: const TextStyle(color: Colors.white),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Observações
            if (maintenance.notes != null && maintenance.notes!.isNotEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.note, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            'Observações',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        maintenance.notes!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

