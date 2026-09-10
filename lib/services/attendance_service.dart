import '../database/database_helper.dart';
import '../models/attendance.dart';
import '../models/member.dart';
import '../models/membership_plan.dart';
import '../models/trainer.dart';

class AttendanceService {
  AttendanceService._();

  static final AttendanceService instance = AttendanceService._();

  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Member>> getAllMembers() async {
    return await _db.getAllMembers();
  }

  Future<List<MembershipPlan>> getMembershipPlans() async {
    return await _db.getAllPlans();
  }

  Future<List<Trainer>> getTrainers() async {
    return await _db.getAllTrainers();
  }

  Future<List<Attendance>> getAttendanceByDate(String date) async {
    return await _db.getAttendanceByDate(date);
  }

  Future<int> getAttendanceCountForMember(int memberId) async {
    return await _db.getAttendanceCountForMember(memberId);
  }

  Future<Attendance?> getLatestAttendanceForMember(int memberId) async {
    return await _db.getLatestAttendanceForMember(memberId);
  }

  Future<int> markAttendance(Attendance attendance) async {
    return await _db.markAttendance(attendance);
  }

  Future<int> updateAttendance(Attendance attendance) async {
    return await _db.updateAttendance(attendance);
  }

  Future<int> deleteAttendance(int id) async {
    return await _db.deleteAttendance(id);
  }
}
