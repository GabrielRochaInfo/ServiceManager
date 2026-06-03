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

  const ClientDetailsScreen({
    super.key,
    required this.client,
  });

  @override
  State<ClientDetailsScreen> createState() =>
      _ClientDetailsScreenState();
}

class _ClientDetailsScreenState
    extends State<ClientDetailsScreen> {
  final ServiceRepository _serviceRepo =
      ServiceRepository();

  final ClientRepository _clientRepo =
      ClientRepository();

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
    final services =
        await _serviceRepo.getServicesByClientId(
      _client.id!,
    );

    final updatedClient =
        await _clientRepo.getClientById(
      _client.id!,
    );

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
        content: const Text(
          'Tem certeza que deseja excluir este cliente e todos os seus serviços?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final navigator =
                  Navigator.of(context);

              final scaffoldMessenger =
                  ScaffoldMessenger.of(context);

              await _clientRepo.deleteClient(
                _client.id!,
              );

              navigator.pop();
              navigator.pop();

              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text(
                    'Cliente excluído com sucesso!',
                  ),
                ),
              );
            },
            child: const Text(
              'Excluir',
              style:
                  TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(.1),
          borderRadius:
              BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currencyFormat =
        NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    final totalServices =
        _services.length;

    final completedServices = _services
        .where(
          (s) => s.status == 'Concluído',
        )
        .length;

    final inProgressServices = _services
        .where(
          (s) =>
              s.status == 'Em andamento',
        )
        .length;

    final totalValue = _services.fold(
      0.0,
      (sum, item) => sum + item.value,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cliente',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddClientScreen(
                    client: _client,
                  ),
                ),
              );

              _loadData();
            },
          ),
          IconButton(
            icon:
                const Icon(Icons.delete),
            onPressed: _deleteClient,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding:
              const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 4,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  24,
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor:
                          Theme.of(context)
                              .colorScheme
                              .primary,
                      child: Text(
                        _client.name
                            .substring(0, 1)
                            .toUpperCase(),
                        style:
                            const TextStyle(
                          fontSize: 30,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 16),
                    Text(
                      _client.name,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                        height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                        ),
                        const SizedBox(
                            width: 8),
                        Expanded(
                          child: Text(
                            _client.phone ??
                                'Sem telefone cadastrado',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                        height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.email,
                        ),
                        const SizedBox(
                            width: 8),
                        Expanded(
                          child: Text(
                            _client.email ??
                                'Sem email cadastrado',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Resumo',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                _buildStatCard(
                  title: 'Serviços',
                  value:
                      totalServices.toString(),
                  icon:
                      Icons.build_circle,
                  color: Colors.blue,
                ),
                const SizedBox(
                    width: 12),
                _buildStatCard(
                  title: 'Concluídos',
                  value:
                      completedServices
                          .toString(),
                  icon:
                      Icons.check_circle,
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                _buildStatCard(
                  title:
                      'Em andamento',
                  value:
                      inProgressServices
                          .toString(),
                  icon:
                      Icons.pending_actions,
                  color: Colors.orange,
                ),
                const SizedBox(
                    width: 12),
                _buildStatCard(
                  title:
                      'Faturamento',
                  value:
                      currencyFormat
                          .format(
                    totalValue,
                  ),
                  icon:
                      Icons.attach_money,
                  color: Colors.teal,
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Histórico de Serviços',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            if (_services.isEmpty)
              Container(
                padding:
                    const EdgeInsets.all(
                  32,
                ),
                child: const Center(
                  child: Text(
                    'Nenhum serviço registrado.',
                  ),
                ),
              ),

            ..._services.map(
              (service) => ServiceCard(
                service: service,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditServiceScreen(
                        service: service,
                      ),
                    ),
                  );

                  _loadData();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}