import 'package:flutter/foundation.dart';
import '../models/trainer.dart';
import '../services/trainer_service.dart';

class TrainerProvider extends ChangeNotifier {
  final TrainerService _trainerService = TrainerService.instance;

  List<Trainer> _trainers = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<Trainer> get trainers => _trainers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Trainer> get filteredTrainers {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _trainers;
    return _trainers.where((t) {
      return t.name.toLowerCase().contains(q) ||
          (t.qualification?.toLowerCase().contains(q) ?? false) ||
          (t.email?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  double get totalPayouts => _trainers.fold(0.0, (sum, t) => sum + t.salary);

  Future<void> fetchTrainers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _trainers = await _trainerService.getAllTrainers();
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error fetching trainers: $e\n$stackTrace');
      _isLoading = false;
      _errorMessage = 'Failed to load trainers.';
      notifyListeners();
    }
  }

  Future<bool> addTrainer({
    required String name,
    required int age,
    String? gender,
    String? dob,
    String? bloodGroup,
    String? mobileNumber,
    String? email,
    String? address,
    String? profilePhotoPath,
    String? idProofPath,
    String? qualification,
    String? certificatePhotoPath,
    String? experience,
    String? shiftStart,
    String? shiftEnd,
    required String joiningDate,
    double salary = 0,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final trainer = Trainer(
        name: name.trim(),
        age: age,
        gender: gender,
        dob: dob?.trim().isEmpty ?? true ? null : dob!.trim(),
        bloodGroup: bloodGroup,
        mobileNumber: mobileNumber?.trim().isEmpty ?? true ? null : mobileNumber!.trim(),
        email: email?.trim().isEmpty ?? true ? null : email!.trim(),
        address: address?.trim().isEmpty ?? true ? null : address!.trim(),
        profilePhotoPath: profilePhotoPath,
        idProofPath: idProofPath,
        qualification: qualification?.trim().isEmpty ?? true ? null : qualification!.trim(),
        certificatePhotoPath: certificatePhotoPath,
        experience: experience?.trim().isEmpty ?? true ? null : experience!.trim(),
        shiftStart: shiftStart?.trim().isEmpty ?? true ? null : shiftStart!.trim(),
        shiftEnd: shiftEnd?.trim().isEmpty ?? true ? null : shiftEnd!.trim(),
        joiningDate: joiningDate.trim().isEmpty
            ? DateTime.now().toIso8601String().split('T').first
            : joiningDate.trim(),
        salary: salary,
      );

      await _trainerService.addTrainer(trainer);
      await fetchTrainers();
      return true;
    } catch (e, stackTrace) {
      debugPrint('Error adding trainer: $e\n$stackTrace');
      _errorMessage = 'Failed to add trainer: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTrainer(Trainer trainer) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _trainerService.updateTrainer(trainer);
      await fetchTrainers();
      return true;
    } catch (e, stackTrace) {
      debugPrint('Error updating trainer: $e\n$stackTrace');
      _errorMessage = 'Failed to update trainer.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTrainer(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _trainerService.deleteTrainer(id);
      await fetchTrainers();
      return true;
    } catch (e, stackTrace) {
      debugPrint('Error deleting trainer: $e\n$stackTrace');
      _errorMessage = 'Failed to delete trainer.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
