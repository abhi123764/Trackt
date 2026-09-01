import '../database/database_helper.dart';
import '../models/attendance.dart';
import '../models/member.dart';
import '../models/membership_plan.dart';
import '../models/trainer.dart';

class MemberService {
  MemberService._();

  static final MemberService instance = MemberService._();

  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Member>> getAllMembers() async {
    return await _db.getAllMembers();
  }

  Future<List<Member>> searchMembers(String query) async {
    if (query.trim().isEmpty) {
      return await _db.getAllMembers();
    }
    return await _db.searchMembers(query.trim());
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

  Future<int> markAttendance(Attendance attendance) async {
    return await _db.markAttendance(attendance);
  }

  Future<int> updateAttendance(Attendance attendance) async {
    return await _db.updateAttendance(attendance);
  }

  Future<int> addMember(Member member) async {
    return await _db.insertMember(member);
  }

  Future<int> updateMember(Member member) async {
    return await _db.updateMember(member);
  }

  Future<int> deleteMember(int id) async {
    return await _db.deleteMember(id);
  }
}
