import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../repositories/client_repository.dart';
import '../repositories/service_repository.dart';
import '../models/client.dart';
import '../models/service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ClientRepository _clientRepo = ClientRepository();
  final ServiceRepository _serviceRepo = ServiceRepository();

  bool _isLoading = true;

  List<Client> _clients = [];
  List<Service> _services = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final clients = await _clientRepo.getClients();
    final services = await _serviceRepo.getServices();

    setState(() {
      _clients = clients;
      _services = services;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    final totalRevenue = _services.fold<double>(
      0,
      (sum, item) => sum + item.value,
    );

    final completedServices = _services
        .where((s) => s.status == 'Concluído')
        .length;

    final pendingServices = _services
        .where((s) => s.status == 'Em andamento')
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Manager'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF2563EB),
                          Color(0xFF1D4ED8),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(24),
                    ),
                    child: const Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bem-vindo 👋',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Service Manager',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Gerencie clientes e serviços de forma simples.',
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Visão Geral',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Clientes',
                          value:
                              _clients.length.toString(),
                          icon: Icons.people,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Serviços',
                          value:
                              _services.length.toString(),
                          icon: Icons.build,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Concluídos',
                          value: completedServices
                              .toString(),
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Pendentes',
                          value: pendingServices
                              .toString(),
                          icon: Icons.pending_actions,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding:
                        const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(24),
                      color: const Color.fromARGB(255, 153, 247, 160),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Faturamento Total',
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currency.format(
                              totalRevenue),
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Últimos Serviços',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (_services.isEmpty)
                    const Card(
                      child: Padding(
                        padding:
                            EdgeInsets.all(20),
                        child: Text(
                          'Nenhum serviço cadastrado.',
                        ),
                      ),
                    ),

                  ..._services
                      .take(5)
                      .map(
                        (service) => Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Icon(
                                service.status ==
                                        'Concluído'
                                    ? Icons
                                        .check_circle
                                    : Icons.build,
                              ),
                            ),
                            title: Text(
                              service.equipment,
                            ),
                            subtitle: Text(
                              service
                                  .serviceDescription,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                            ),
                            trailing: Text(
                              currency.format(
                                  service.value),
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(22),
        color: color.withOpacity(.10),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title),
        ],
      ),
    );
  }
}