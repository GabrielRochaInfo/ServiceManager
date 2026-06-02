import '../database/database_helper.dart';
import '../models/service.dart';

class ServiceRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertService(Service service) async {
    final db = await _dbHelper.database;
    return await db.insert('services', service.toMap());
  }

  Future<List<Service>> getServices({String? statusFilter}) async {
    final db = await _dbHelper.database;
    String? whereClause;
    List<dynamic>? whereArgs;

    if (statusFilter != null && statusFilter != 'Todos') {
      whereClause = 'status = ?';
      whereArgs = [statusFilter];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'services',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) {
      return Service.fromMap(maps[i]);
    });
  }

  Future<List<Service>> getServicesByClientId(int clientId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'services',
      where: 'clientId = ?',
      whereArgs: [clientId],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) {
      return Service.fromMap(maps[i]);
    });
  }

  Future<int> updateService(Service service) async {
    final db = await _dbHelper.database;
    return await db.update(
      'services',
      service.toMap(),
      where: 'id = ?',
      whereArgs: [service.id],
    );
  }

  Future<int> deleteService(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'services',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
