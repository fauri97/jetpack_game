import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    return await init();
  }

  static Future<Database> init() async {
    final path = join(await getDatabasesPath(), 'game_data.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Highscores (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            value INTEGER NOT NULL
          );
        ''');
      },
    );
  }

  /// Adiciona uma nova pontuação ao histórico
  static Future<void> addScore(int score) async {
    final dbClient = await db;
    await dbClient.insert('Highscores', {'value': score});
  }

  /// Retorna a lista das 5 maiores pontuações (Top 5)
  static Future<List<int>> getTopScores([int limit = 5]) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'Highscores',
      orderBy: 'value DESC',
      limit: limit,
    );
    return result.map((row) => row['value'] as int).toList();
  }

  /// Retorna a maior pontuação já registrada
  static Future<int> getHighscore() async {
    final dbClient = await db;
    final result = await dbClient.rawQuery(
      'SELECT MAX(value) as max FROM Highscores',
    );
    return result.first['max'] != null ? result.first['max'] as int : 0;
  }
}
