import 'package:flutter/foundation.dart';
import '../models/medicine_model.dart';
import '../database/database_helper.dart';

class MedicineProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Medicine> _medicines = [];
  bool _isLoading = false;

  List<Medicine> get medicines => _medicines;
  bool get isLoading => _isLoading;

  Future<void> loadMedicines() async {
    _isLoading = true;
    notifyListeners();

    _medicines = await _dbHelper.getAllMedicines();

    _isLoading = false;
    notifyListeners();
  }
}
