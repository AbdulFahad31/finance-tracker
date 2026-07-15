import 'package:hive/hive.dart';

class HiveService {
  HiveService();

  static const String boxName = 'finance_box';

  Future<Box> openBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }
}
