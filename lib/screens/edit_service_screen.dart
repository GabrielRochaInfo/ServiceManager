import 'package:flutter/material.dart';
import '../models/client.dart';
import '../models/service.dart';
import '../repositories/client_repository.dart';
import '../repositories/service_repository.dart';

class EditServiceScreen extends StatefulWidget {
  final Service service;

  const EditServiceScreen({super.key, required this.service});

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final ClientRepository _clientRepo = ClientRepository();
  final ServiceRepository _serviceRepo = ServiceRepository();

  List<Client> _clients = [];
  int? _selectedClientId;
  
  late TextEditingController _equipmentController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _reportedProblemController;
  late TextEditingController _serviceDescriptionController;
  late TextEditingController _valueController;
  
  late String _status;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedClientId = widget.service.clientId;
    _status = widget.service.status;
    
    _equipmentController = TextEditingController(text: widget.service.equipment);
    _brandController = TextEditingController(text: widget.service.brand ?? '');
    _modelController = TextEditingController(text: widget.service.model ?? '');
    _reportedProblemController = TextEditingController(text: widget.service.reportedProblem ?? '');
    _serviceDescriptionController = TextEditingController(text: widget.service.serviceDescription);
    _valueController = TextEditingController(text: widget.service.value.toString());
    
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

      final updatedService = Service(
        id: widget.service.id,
        clientId: _selectedClientId!,
        equipment: _equipmentController.text.trim(),
        brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        model: _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
        reportedProblem: _reportedProblemController.text.trim().isEmpty ? null : _reportedProblemController.text.trim(),
        serviceDescription: _serviceDescriptionController.text.trim(),
        value: value,
        status: _status,
        createdAt: widget.service.createdAt, // mantem a data original
      );

      await _serviceRepo.updateService(updatedService);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Serviço atualizado com sucesso!')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _deleteService() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Serviço'),
        content: const Text('Tem certeza que deseja excluir este serviço?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              await _serviceRepo.deleteService(widget.service.id!);
              navigator.pop(); // Fechar dialog
              navigator.pop(); // Voltar para tela anterior
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Serviço excluído com sucesso!')),
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
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Editar Serviço',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: _deleteService,
        ),
      ],
    ),
    body: _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
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
                    borderRadius:
                        BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.build_circle,
                        color: Colors.white,
                        size: 42,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Editar Serviço',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Atualize as informações da ordem de serviço',
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
                          value: _selectedClientId,
                          decoration:
                              const InputDecoration(
                            labelText: 'Cliente',
                            prefixIcon:
                                Icon(Icons.person),
                          ),
                          items: _clients.map((client) {
                            return DropdownMenuItem<int>(
                              value: client.id,
                              child:
                                  Text(client.name),
                            );
                          }).toList(),
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
                            const SizedBox(width: 12),
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
                            labelText: 'Valor',
                            prefixText: 'R\$ ',
                            prefixIcon:
                                Icon(Icons.attach_money),
                          ),
                        ),

                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: _status,
                          decoration:
                              const InputDecoration(
                            labelText: 'Status',
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
                              child:
                                  Text('Concluído'),
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
                    onPressed: _saveService,
                    icon:
                        const Icon(Icons.save),
                    label: const Text(
                      'Atualizar Serviço',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
  );
}
}