import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BancoCombustivel {
  BancoCombustivel._();

  static final BancoCombustivel instancia = BancoCombustivel._();

  Database? _banco;

  Future<Database> get banco async {
    _banco ??= await _abrir();
    return _banco!;
  }

  Future<Database> _abrir() async {
    final pasta = await getDatabasesPath();
    final caminho = join(pasta, 'combustivel.db');

    return openDatabase(
      caminho,
      version: 1,
      onCreate: (db, versao) async {
        await db.execute('''
          CREATE TABLE veiculos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            marca TEXT NOT NULL,
            codigo_marca TEXT NOT NULL,
            modelo TEXT NOT NULL,
            ano INTEGER NOT NULL,
            cilindrada REAL NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE abastecimentos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            veiculo_id INTEGER NOT NULL,
            combustivel TEXT NOT NULL,
            preco_litro REAL NOT NULL,
            quilometragem REAL NOT NULL,
            litros REAL NOT NULL,
            data TEXT NOT NULL,
            FOREIGN KEY (veiculo_id) REFERENCES veiculos (id)
          )
        ''');
      },
    );
  }
}
