import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/client.dart';
import '../models/service.dart';
import '../repositories/client_repository.dart';
import '../repositories/service_repository.dart';
import '../widgets/service_card.dart';
import 'add_client_screen.dart';
import 'edit_service_screen.dart';

class ClientDetailsScreen extends StatefulWidget {
  final Client client;

  const ClientDetailsScreen({super.key, required this.client});

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  final ServiceRepository _serviceRepo = ServiceRepository();
  final ClientRepository _clientRepo = ClientRepository();
  late Client _client;
  List<Service> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _client = widget.client;
    _loadData();
  }

  Future<void> _loadData() async {
    final services = await _serviceRepo.getServicesByClientId(_client.id!);
    final updatedClient = await _clientRepo.getClientById(_client.id!);
    setState(() {
      _services = services;
      if (updatedClient != null) {
        _client = updatedClient;
      }
      _isLoading = false;
    });
  }

  void _deleteClient() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Cliente'),
        content: const Text('Tem certeza que deseja excluir este cliente e todos os seus serviços?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              await _clientRepo.deleteClient(_client.id!);
              navigator.pop(); // Fechar dialog
              navigator.pop(); // Voltar para tela anterior
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Cliente excluído com sucesso!')),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    int totalServices = _services.length;
    int completedServices = _services.where((s) => s.status == 'Concluído').length;
    int inProgressServices = _services.where((s) => s.status == 'Em andamento').length;
    double totalValue = _services.fold(0, (sum, item) => sum + item.value);

    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddClientScreen(client: _client)),
              );
              _loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteClient,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _client.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16),
                    const SizedBox(width: 8),
                    Text(_client.phone ?? 'Sem telefone cadastrado'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.email, size: 16),
                    const SizedBox(width: 8),
                    Text(_client.email ?? 'Sem email cadastrado'),
                  ],
                ),
                const Divider(height: 32),
                const Text(
                  'Resumo Financeiro',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Total de serviços: $totalServices'),
                Text('Concluídos: $completedServices'),
                Text('Em andamento: $inProgressServices'),
                const SizedBox(height: 8),
                Text(
                  'Faturamento total: ${currencyFormat.format(totalValue)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Histórico de Serviços',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: _services.isEmpty
                ? const Center(child: Text('Nenhum serviço registrado.'))
                : ListView.builder(
                    itemCount: _services.length,
                    itemBuilder: (context, index) {
                      final service = _services[index];
                      return ServiceCard(
                        service: service,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditServiceScreen(service: service),
                            ),
                          );
                          _loadData();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
