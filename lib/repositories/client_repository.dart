import '../database/database_helper.dart';
import '../models/client.dart';

class ClientRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertClient(Client client) async {
    final db = await _dbHelper.database;
    return await db.insert('clients', client.toMap());
  }

  Future<List<Client>> getClients() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('clients', orderBy: 'name ASC');
    return List.generate(maps.length, (i) {
      return Client.fromMap(maps[i]);
    });
  }

  Future<int> updateClient(Client client) async {
    final db = await _dbHelper.database;
    return await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> deleteClient(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Client?> getClientById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Client.fromMap(maps.first);
    }
    return null;
  }
}
