import '../database/database_helper.dart';
import '../models/trainer.dart';

class TrainerService {
  TrainerService._();

  static final TrainerService instance = TrainerService._();

  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Trainer>> getAllTrainers() async {
    return await _db.getAllTrainers();
  }

  Future<Trainer?> getTrainerById(int id) async {
    return await _db.getTrainerById(id);
  }

  Future<int> addTrainer(Trainer trainer) async {
    return await _db.insertTrainer(trainer);
  }

  Future<int> updateTrainer(Trainer trainer) async {
    return await _db.updateTrainer(trainer);
  }

  Future<int> deleteTrainer(int id) async {
    return await _db.deleteTrainer(id);
  }
}
