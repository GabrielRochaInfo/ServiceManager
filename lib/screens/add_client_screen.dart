import 'package:flutter/material.dart';
import '../models/client.dart';
import '../repositories/client_repository.dart';

class AddClientScreen extends StatefulWidget {
  final Client? client;

  const AddClientScreen({super.key, this.client});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final ClientRepository _clientRepo = ClientRepository();

  bool get isEditing => widget.client != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.client!.name;
      _phoneController.text = widget.client!.phone ?? '';
      _emailController.text = widget.client!.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveClient() async {
    if (_formKey.currentState!.validate()) {
      final client = Client(
        id: isEditing ? widget.client!.id : null,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      );

      if (isEditing) {
        await _clientRepo.updateClient(client);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cliente atualizado com sucesso!')),
          );
        }
      } else {
        await _clientRepo.insertClient(client);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cliente cadastrado com sucesso!')),
          );
        }
      }
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        isEditing ? 'Editar Cliente' : 'Novo Cliente',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF2563EB),
                  Color(0xFF1D4ED8),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  isEditing
                      ? 'Editar Cliente'
                      : 'Cadastrar Cliente',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Gerencie seus clientes com facilidade',
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
                  TextFormField(
                    controller:
                        _nameController,
                    decoration:
                        const InputDecoration(
                      labelText: 'Nome',
                      prefixIcon:
                          Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Informe o nome';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller:
                        _phoneController,
                    keyboardType:
                        TextInputType.phone,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Telefone',
                      prefixIcon:
                          Icon(Icons.phone),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller:
                        _emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    decoration:
                        const InputDecoration(
                      labelText: 'Email',
                      prefixIcon:
                          Icon(Icons.email),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _saveClient,
              icon: const Icon(Icons.save),
              label: Text(
                isEditing
                    ? 'Atualizar Cliente'
                    : 'Salvar Cliente',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
