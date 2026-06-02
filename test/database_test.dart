import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:service_manager/models/client.dart';
import 'package:service_manager/models/service.dart';
import 'package:service_manager/repositories/client_repository.dart';
import 'package:service_manager/repositories/service_repository.dart';

void main() {
  late ClientRepository clientRepo;
  late ServiceRepository serviceRepo;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    
    // For tests, use an in-memory database to avoid polluting the file system
    // Wait, DatabaseHelper uses getDatabasesPath() hardcoded.
    // I will just test using the actual file but clear it.
    String path = join(await getDatabasesPath(), 'service_manager.db');
    await deleteDatabase(path);
  });

  setUp(() async {
    clientRepo = ClientRepository();
    serviceRepo = ServiceRepository();
  });

  test('Verificar SQLite e Repositories (Cadastro, Edição, Exclusão)', () async {
    // 1. Cadastro de cliente funciona
    final client = Client(
      name: 'João Silva',
      phone: '11999999999',
      email: 'joao@email.com',
    );
    final clientId = await clientRepo.insertClient(client);
    expect(clientId, isPositive);

    // Verificar se salvou corretamente
    final clients = await clientRepo.getClients();
    expect(clients.length, 1);
    expect(clients.first.name, 'João Silva');

    // 2. Cadastro de serviço funciona
    final service = Service(
    clientId: clientId,
    equipment: 'Notebook Dell',
    brand: 'Dell',
    model: 'Inspiron',
    reportedProblem: 'Tela quebrada',
    serviceDescription: 'Troca de tela',
    value: 450.0,
    status: 'Em andamento',
    createdAt: DateTime.now().toIso8601String(),
    );
    final serviceId = await serviceRepo.insertService(service);
    expect(serviceId, isPositive);

    // Verificar se serviço salvou corretamente
    final services = await serviceRepo.getServices();
    expect(services.length, 1);
    expect(services.first.equipment, 'Notebook Dell');

    // 3. Edição funciona
    final updatedService = Service(
    id: serviceId,
    clientId: clientId,
    equipment: 'Notebook Dell',
    brand: 'Dell',
    model: 'Inspiron',
    reportedProblem: 'Tela quebrada',
    serviceDescription: 'Troca de tela e limpeza',
    value: 500.0,
    status: 'Concluído',
    createdAt: service.createdAt,
    );
    await serviceRepo.updateService(updatedService);

    final updatedServices = await serviceRepo.getServices();
    expect(updatedServices.first.status, 'Concluído');
    expect(updatedServices.first.value, 500.0);

    // 4. Histórico do cliente funciona
    final clientServices = await serviceRepo.getServicesByClientId(clientId);
    expect(clientServices.length, 1);
    expect(clientServices.first.status, 'Concluído');

    // 5. Exclusão de cliente deve deletar os serviços em cascata
    await clientRepo.deleteClient(clientId);
    final clientsAfterDelete = await clientRepo.getClients();
    expect(clientsAfterDelete.isEmpty, true);

    // Verificar se o serviço foi excluído em cascata pelo SQLite
    final servicesAfterDelete = await serviceRepo.getServices();
    expect(servicesAfterDelete.isEmpty, true, reason: 'ON DELETE CASCADE deve remover os serviços do cliente excluído');
  });
}
