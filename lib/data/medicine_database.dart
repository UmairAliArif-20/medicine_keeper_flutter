import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Simple SQLite helper for medicines.
class MedicineDatabase {
  MedicineDatabase._();

  static final MedicineDatabase instance = MedicineDatabase._();
  static const String _tableMedicines = 'medicines';
  static const String _columnId = 'id';
  static const String _columnName = 'name';
  static const String _columnTimeMinutes = 'time_minutes';
  static const String _columnIsTaken = 'is_taken';
  static const String _columnImagePath = 'image_path';
  Database? _db;

  Future<Database> _getDatabase() async {
    if (_db != null) {
      return _db!;
    }

    String folder = await getDatabasesPath();
    String path = join(folder, 'medicine_ledger.db');

    _db = await openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );

    return _db!;
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $_tableMedicines ('
      '$_columnId INTEGER PRIMARY KEY AUTOINCREMENT, '
      '$_columnName TEXT NOT NULL, '
      '$_columnTimeMinutes INTEGER NOT NULL, '
      '$_columnIsTaken INTEGER NOT NULL'
      ', $_columnImagePath TEXT'
      ')',
    );
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $_tableMedicines ADD COLUMN $_columnImagePath TEXT',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getMedicines() async {
    Database db = await _getDatabase();
    List<Map<String, Object?>> rows = await db.query(
      _tableMedicines,
      orderBy: '$_columnTimeMinutes ASC',
    );

    List<Map<String, dynamic>> medicines = <Map<String, dynamic>>[];
    for (Map<String, Object?> row in rows) {
      medicines.add(_rowToMedicine(row));
    }

    return medicines;
  }

  Future<int> addMedicine(Map<String, dynamic> medicine) async {
    Database db = await _getDatabase();
    Map<String, Object?> row = _medicineToRow(medicine);
    return db.insert(_tableMedicines, row);
  }

  Future<void> updateMedicine(Map<String, dynamic> medicine) async {
    Database db = await _getDatabase();
    int id = medicine[_columnId] as int;
    Map<String, Object?> row = _medicineToRow(medicine);

    await db.update(
      _tableMedicines,
      row,
      where: '$_columnId = ?',
      whereArgs: <Object>[id],
    );
  }

  Future<void> deleteMedicine(int id) async {
    Database db = await _getDatabase();
    await db.delete(
      _tableMedicines,
      where: '$_columnId = ?',
      whereArgs: <Object>[id],
    );
  }

  Future<void> setMedicineTaken(int id, bool isTaken) async {
    Database db = await _getDatabase();
    await db.update(
      _tableMedicines,
      <String, Object?>{_columnIsTaken: isTaken ? 1 : 0},
      where: '$_columnId = ?',
      whereArgs: <Object>[id],
    );
  }

  Map<String, dynamic> _rowToMedicine(Map<String, Object?> row) {
    return <String, dynamic>{
      'id': row[_columnId] as int,
      'name': row[_columnName] as String,
      'timeMinutes': row[_columnTimeMinutes] as int,
      'isTaken': (row[_columnIsTaken] as int) == 1,
      'imagePath': row[_columnImagePath] as String?,
    };
  }

  Map<String, Object?> _medicineToRow(Map<String, dynamic> medicine) {
    bool isTaken = medicine['isTaken'] as bool;
    return <String, Object?>{
      _columnName: medicine['name'],
      _columnTimeMinutes: medicine['timeMinutes'],
      _columnIsTaken: isTaken ? 1 : 0,
      _columnImagePath: medicine['imagePath'],
    };
  }
}
