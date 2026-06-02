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
        title: const Text('Novo Serviço'),
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
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Valor é obrigatório';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _status,
                            decoration: const InputDecoration(
                              labelText: 'Status *',
                              border: OutlineInputBorder(),
                            ),
                            items: ['Em andamento', 'Concluído'].map((status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
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
                        child: const Text('Salvar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
