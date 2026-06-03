import 'package:flutter/material.dart';
import '../models/service.dart';
import '../repositories/service_repository.dart';
import '../widgets/service_card.dart';
import 'add_service_screen.dart';
import 'edit_service_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final ServiceRepository _serviceRepo = ServiceRepository();

  List<Service> _services = [];
  List<Service> _filteredServices = [];

  bool _isLoading = true;

  String _statusFilter = 'Todos';
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    final services =
        await _serviceRepo.getServices(statusFilter: _statusFilter);

    setState(() {
      _services = services;
      _applyFilters();
      _isLoading = false;
    });
  }

  void _applyFilters() {
    _filteredServices = _services.where((service) {
      final equipment =
          service.equipment.toLowerCase();

      final description =
          service.serviceDescription.toLowerCase();

      final search =
          _searchText.toLowerCase();

      return equipment.contains(search) ||
          description.contains(search);
    }).toList();
  }

  Widget _buildChip(String label) {
    final selected = _statusFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() {
            _statusFilter = label;
            _isLoading = true;
          });

          _loadServices();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalServices = _services.length;

    final completedServices = _services
        .where((s) => s.status == 'Concluído')
        .length;

    final pendingServices = _services
        .where((s) => s.status == 'Em andamento')
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Serviços',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddServiceScreen(),
            ),
          );

          _loadServices();
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadServices,
              child: ListView(
                padding:
                    const EdgeInsets.all(16),
                children: [
                  Container(
                    padding:
                        const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient:
                          const LinearGradient(
                        colors: [
                          Color(0xFFFF9800),
                          Color(0xFFFF6F00),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(
                              24),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        const Text(
                          'Central de Serviços',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                            height: 6),
                        Text(
                          '$totalServices serviços cadastrados',
                          style:
                              const TextStyle(
                            color:
                                Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total',
                          totalServices
                              .toString(),
                          Icons.build,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Concluídos',
                          completedServices
                              .toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Andamento',
                          pendingServices
                              .toString(),
                          Icons.schedule,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    decoration:
                        InputDecoration(
                      hintText:
                          'Buscar equipamento...',
                      prefixIcon:
                          const Icon(
                              Icons.search),
                      filled: true,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                                    18),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchText =
                            value;
                        _applyFilters();
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  SingleChildScrollView(
                    scrollDirection:
                        Axis.horizontal,
                    child: Row(
                      children: [
                        _buildChip('Todos'),
                        _buildChip(
                            'Em andamento'),
                        _buildChip(
                            'Concluído'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    '${_filteredServices.length} resultado(s)',
                    style: TextStyle(
                      color: Colors
                          .grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (_filteredServices
                      .isEmpty)
                    const Padding(
                      padding:
                          EdgeInsets.all(
                              40),
                      child: Center(
                        child: Text(
                          'Nenhum serviço encontrado',
                        ),
                      ),
                    ),

                  ..._filteredServices.map(
                    (service) => ServiceCard(
                      service: service,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditServiceScreen(
                              service:
                                  service,
                            ),
                          ),
                        );

                        _loadServices();
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style:
                const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}