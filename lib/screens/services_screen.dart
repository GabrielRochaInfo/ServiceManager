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
  bool _isLoading = true;
  String _statusFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    final services = await _serviceRepo.getServices(statusFilter: _statusFilter);
    setState(() {
      _services = services;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _statusFilter,
                dropdownColor: Theme.of(context).colorScheme.surface,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                items: <String>['Todos', 'Em andamento', 'Concluído']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _statusFilter = newValue;
                      _isLoading = true;
                    });
                    _loadServices();
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _services.isEmpty
              ? const Center(child: Text('Nenhum serviço encontrado.'))
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
                        _loadServices();
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddServiceScreen()),
          );
          _loadServices();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
