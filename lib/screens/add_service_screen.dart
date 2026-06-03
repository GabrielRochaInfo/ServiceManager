import 'package:flutter/material.dart';
import '../models/client.dart';
import '../models/service.dart';
import '../repositories/client_repository.dart';
import '../repositories/service_repository.dart';

class AddServiceScreen extends StatefulWidget {
  final int? initialClientId;

  const AddServiceScreen({super.key, this.initialClientId});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final ClientRepository _clientRepo = ClientRepository();
  final ServiceRepository _serviceRepo = ServiceRepository();

  List<Client> _clients = [];
  int? _selectedClientId;
  
  final _equipmentController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _reportedProblemController = TextEditingController();
  final _serviceDescriptionController = TextEditingController();
  final _valueController = TextEditingController();
  
  String _status = 'Em andamento';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedClientId = widget.initialClientId;
    _loadClients();
  }

  Future<void> _loadClients() async {
    final clients = await _clientRepo.getClients();
    setState(() {
      _clients = clients;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _equipmentController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _reportedProblemController.dispose();
    _serviceDescriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _saveService() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedClientId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione um cliente.')),
        );
        return;
      }

      final double? value = double.tryParse(_valueController.text.replaceAll(',', '.'));
      if (value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Valor inválido.')),
        );
        return;
      }

      final service = Service(
        clientId: _selectedClientId!,
        equipment: _equipmentController.text.trim(),
        brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        model: _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
        reportedProblem: _reportedProblemController.text.trim().isEmpty ? null : _reportedProblemController.text.trim(),
        serviceDescription: _serviceDescriptionController.text.trim(),
        value: value,
        status: _status,
        createdAt: DateTime.now().toIso8601String(),
      );

      await _serviceRepo.insertService(service);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Serviço cadastrado com sucesso!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Novo Serviço',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF9800),
                        Color(0xFFF57C00),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.home_repair_service,
                        color: Colors.white,
                        size: 40,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Cadastrar Serviço',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Registre uma nova ordem de serviço',
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        DropdownButtonFormField<int>(
                          initialValue:
                              _selectedClientId,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Cliente',
                            prefixIcon:
                                Icon(Icons.person),
                          ),
                          items: _clients.map(
                            (client) {
                              return DropdownMenuItem<
                                  int>(
                                value: client.id,
                                child:
                                    Text(client.name),
                              );
                            },
                          ).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedClientId =
                                  value;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller:
                              _equipmentController,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Equipamento',
                            prefixIcon:
                                Icon(Icons.devices),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller:
                                    _brandController,
                                decoration:
                                    const InputDecoration(
                                  labelText:
                                      'Marca',
                                  prefixIcon:
                                      Icon(Icons.sell),
                                ),
                              ),
                            ),
                            const SizedBox(
                                width: 12),
                            Expanded(
                              child: TextFormField(
                                controller:
                                    _modelController,
                                decoration:
                                    const InputDecoration(
                                  labelText:
                                      'Modelo',
                                  prefixIcon:
                                      Icon(Icons.memory),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller:
                              _reportedProblemController,
                          maxLines: 3,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Problema Relatado',
                            prefixIcon:
                                Icon(Icons.warning),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller:
                              _serviceDescriptionController,
                          maxLines: 4,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Descrição do Serviço',
                            prefixIcon:
                                Icon(Icons.description),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller:
                              _valueController,
                          keyboardType:
                              TextInputType.number,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Valor',
                            prefixText:
                                'R\$ ',
                            prefixIcon:
                                Icon(Icons.attach_money),
                          ),
                        ),

                        const SizedBox(height: 16),

                        DropdownButtonFormField<
                            String>(
                          initialValue: _status,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Status',
                            prefixIcon:
                                Icon(Icons.flag),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value:
                                  'Em andamento',
                              child: Text(
                                  'Em andamento'),
                            ),
                            DropdownMenuItem(
                              value: 'Concluído',
                              child: Text(
                                  'Concluído'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _status = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    icon:
                        const Icon(Icons.save),
                    label: const Text(
                      'Salvar Serviço',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    onPressed: _saveService,
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
  );
}
}
