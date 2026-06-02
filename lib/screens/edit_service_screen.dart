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
        title: const Text('Editar Serviço'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteService,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: _selectedClientId,
                      decoration: const InputDecoration(
                        labelText: 'Cliente *',
                        border: OutlineInputBorder(),
                      ),
                      items: _clients.map((client) {
                        return DropdownMenuItem<int>(
                          value: client.id,
                          child: Text(client.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClientId = value;
                        });
                      },
                      validator: (value) => value == null ? 'Selecione um cliente' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _equipmentController,
                      decoration: const InputDecoration(
                        labelText: 'Equipamento *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Equipamento é obrigatório';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _brandController,
                            decoration: const InputDecoration(
                              labelText: 'Marca',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _modelController,
                            decoration: const InputDecoration(
                              labelText: 'Modelo',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _reportedProblemController,
                      decoration: const InputDecoration(
                        labelText: 'Problema relatado',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _serviceDescriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição do Serviço *',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Descrição é obrigatória';
                        return null;
                      },
                    ),
                                        const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _valueController,
                            decoration: const InputDecoration(
                              labelText: 'Valor *',
                              border: OutlineInputBorder(),
                              prefixText: 'R\$ ',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Valor é obrigatório';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _status,
                            decoration: const InputDecoration(
                              labelText: 'Status *',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Em andamento',
                                child: Text(
                                  'Em andamento',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Concluído',
                                child: Text(
                                  'Concluído',
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveService,
                        child: const Text('Atualizar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}