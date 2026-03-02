import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarDb {
  static late Isar _instance;

  static Isar get instance => _instance;

  static Future<void> init(List<CollectionSchema<dynamic>> schemas) async {
    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      schemas,
      directory: dir.path,
    );
  }
}
