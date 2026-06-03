import 'package:flutter/material.dart';
import '../models/client.dart';
import '../repositories/client_repository.dart';
import '../widgets/client_card.dart';
import 'add_client_screen.dart';
import 'client_details_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final ClientRepository _clientRepo = ClientRepository();

  List<Client> _clients = [];
  List<Client> _filteredClients = [];

  bool _isLoading = true;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    final clients = await _clientRepo.getClients();

    setState(() {
      _clients = clients;
      _filteredClients = clients;
      _isLoading = false;
    });
  }

  void _filterClients(String value) {
    setState(() {
      _searchText = value;

      _filteredClients = _clients.where((client) {
        return client.name
            .toLowerCase()
            .contains(value.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalClients = _clients.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clientes',
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
                  const AddClientScreen(),
            ),
          );

          _loadClients();
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Novo'),
      ),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadClients,
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
                          Color(0xFF2563EB),
                          Color(0xFF1D4ED8),
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
                          'Cadastro de Clientes',
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
                          '$totalClients clientes cadastrados',
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

                  Container(
                    padding:
                        const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.blue
                          .withOpacity(.10),
                      borderRadius:
                          BorderRadius
                              .circular(18),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.people,
                          color: Colors.blue,
                          size: 30,
                        ),
                        const SizedBox(
                            height: 8),
                        Text(
                          totalClients
                              .toString(),
                          style:
                              const TextStyle(
                            fontSize: 24,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Colors.blue,
                          ),
                        ),
                        const Text(
                          'Clientes',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    decoration:
                        InputDecoration(
                      hintText:
                          'Buscar cliente...',
                      prefixIcon:
                          const Icon(
                              Icons.search),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                                    18),
                      ),
                    ),
                    onChanged:
                        _filterClients,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    '${_filteredClients.length} resultado(s)',
                    style: TextStyle(
                      color: Colors
                          .grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (_filteredClients
                      .isEmpty)
                    const Padding(
                      padding:
                          EdgeInsets.all(
                              40),
                      child: Center(
                        child: Text(
                          'Nenhum cliente encontrado',
                        ),
                      ),
                    ),

                  ..._filteredClients.map(
                    (client) => ClientCard(
                      client: client,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ClientDetailsScreen(
                              client:
                                  client,
                            ),
                          ),
                        );

                        _loadClients();
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}