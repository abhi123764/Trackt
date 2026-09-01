import 'package:flutter/foundation.dart';

import '../models/attendance.dart';
import '../models/member.dart';
import '../models/membership_plan.dart';
import '../models/trainer.dart';
import '../services/member_service.dart';

enum MemberSortOption { nameAsc, nameDesc, joinDateNewest, joinDateOldest }

extension MemberSortOptionExtension on MemberSortOption {
  String get label {
    switch (this) {
      case MemberSortOption.nameAsc:
        return 'Name (A - Z)';
      case MemberSortOption.nameDesc:
        return 'Name (Z - A)';
      case MemberSortOption.joinDateNewest:
        return 'Join Date (Newest First)';
      case MemberSortOption.joinDateOldest:
        return 'Join Date (Oldest First)';
    }
  }
}

class MemberProvider extends ChangeNotifier {
  final MemberService _memberService = MemberService.instance;

  List<Member> _members = [];
  List<MembershipPlan> _membershipPlans = [];
  List<Trainer> _trainers = [];
  Map<int, Attendance> _todayAttendance = {};
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _statusFilter = 'All';
  String _genderFilter = 'All';
  int? _planFilter;
  MemberSortOption _sortOption = MemberSortOption.nameAsc;

  List<Member> get members => _members;
  List<MembershipPlan> get membershipPlans => _membershipPlans;
  List<Trainer> get trainers => _trainers;
  Map<int, Attendance> get todayAttendance => _todayAttendance;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String get genderFilter => _genderFilter;
  int? get planFilter => _planFilter;
  MemberSortOption get sortOption => _sortOption;

  Attendance? getTodayAttendance(int memberId) => _todayAttendance[memberId];

  bool get hasActiveFilters =>
      _statusFilter != 'All' ||
      _genderFilter != 'All' ||
      _planFilter != null ||
      _sortOption != MemberSortOption.nameAsc;

  List<Member> get filteredMembers {
    final list = _members.where((m) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.mobileNumber.contains(_searchQuery) ||
          (m.email != null &&
              m.email!.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesStatus =
          _statusFilter == 'All' ||
          m.status.toLowerCase() == _statusFilter.toLowerCase();
      final matchesGender =
          _genderFilter == 'All' ||
          (m.gender != null &&
              m.gender!.toLowerCase() == _genderFilter.toLowerCase());
      final matchesPlan = _planFilter == null || m.planId == _planFilter;

      return matchesSearch && matchesStatus && matchesGender && matchesPlan;
    }).toList();

    switch (_sortOption) {
      case MemberSortOption.nameAsc:
        list.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case MemberSortOption.nameDesc:
        list.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;
      case MemberSortOption.joinDateNewest:
        list.sort((a, b) => b.joinDate.compareTo(a.joinDate));
        break;
      case MemberSortOption.joinDateOldest:
        list.sort((a, b) => a.joinDate.compareTo(b.joinDate));
        break;
    }

    return list;
  }

  Future<void> fetchMembers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _membershipPlans = await _memberService.getMembershipPlans();
      _trainers = await _memberService.getTrainers();

      final todayStr = DateTime.now().toIso8601String().split('T').first;
      final attList = await _memberService.getAttendanceByDate(todayStr);
      _todayAttendance = {
        for (var a in attList)
          if (a.memberId != null) a.memberId!: a,
      };

      if (_searchQuery.trim().isNotEmpty) {
        _members = await _memberService.searchMembers(_searchQuery);
      } else {
        _members = await _memberService.getAllMembers();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error fetching members data: $e\n$stackTrace');
      _isLoading = false;
      _errorMessage = 'Failed to load members.';
      notifyListeners();
    }
  }

  Future<bool> checkInMember(int memberId, String checkInTime) async {
    try {
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      final existing = _todayAttendance[memberId];

      if (existing != null && existing.id != null) {
        final updated = Attendance(
          id: existing.id,
          memberId: memberId,
          trainerId: existing.trainerId,
          date: todayStr,
          checkIn: checkInTime,
          checkOut: null,
          status: 'Present',
        );
        await _memberService.updateAttendance(updated);
        _todayAttendance[memberId] = updated;
      } else {
        final att = Attendance(
          memberId: memberId,
          date: todayStr,
          checkIn: checkInTime,
          status: 'Present',
        );
        final id = await _memberService.markAttendance(att);
        _todayAttendance[memberId] = Attendance(
          id: id,
          memberId: memberId,
          date: todayStr,
          checkIn: checkInTime,
          status: 'Present',
        );
      }
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      debugPrint('Error checking in member: $e\n$stackTrace');
      return false;
    }
  }

  Future<bool> checkOutMember(int memberId, String checkOutTime) async {
    try {
      final existing = _todayAttendance[memberId];
      if (existing != null && existing.id != null) {
        final updated = Attendance(
          id: existing.id,
          memberId: memberId,
          trainerId: existing.trainerId,
          date: existing.date,
          checkIn: existing.checkIn,
          checkOut: checkOutTime,
          status: existing.status,
        );
        await _memberService.updateAttendance(updated);
        _todayAttendance[memberId] = updated;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      debugPrint('Error checking out member: $e\n$stackTrace');
      return false;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchMembers();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setGenderFilter(String filter) {
    _genderFilter = filter;
    notifyListeners();
  }

  void setPlanFilter(int? planId) {
    _planFilter = planId;
    notifyListeners();
  }

  void setSortOption(MemberSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void resetFilters() {
    _statusFilter = 'All';
    _genderFilter = 'All';
    _planFilter = null;
    _sortOption = MemberSortOption.nameAsc;
    notifyListeners();
  }

  Future<bool> addMember({
    required String name,
    required String mobileNumber,
    String? email,
    String? gender,
    String? bloodGroup,
    String? dob,
    String? address,
    String? profilePhotoPath,
    String? idProofPath,
    String? medicalReportsPath,
    String? height,
    String? weight,
    String? targetWeight,
    String? bmi,
    String? activityLevel,
    String? fitnessGoal,
    String? emotionalHealth,
    String? medicalConditions,
    int? dietPlanId,
    int? planId,
    int? trainerId,
    String? preferredTime,
    String status = 'Active',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final member = Member(
        name: name.trim(),
        mobileNumber: mobileNumber.trim(),
        email: email?.trim().isEmpty ?? true ? null : email!.trim(),
        gender: gender,
        bloodGroup: bloodGroup,
        dob: dob,
        address: address?.trim().isEmpty ?? true ? null : address!.trim(),
        profilePhotoPath: profilePhotoPath,
        idProofPath: idProofPath,
        medicalReportsPath: medicalReportsPath,
        height: height != null ? double.tryParse(height) : null,
        weight: weight != null ? double.tryParse(weight) : null,
        targetWeight: targetWeight != null
            ? double.tryParse(targetWeight)
            : null,
        bmi: bmi != null ? double.tryParse(bmi) : null,
        activityLevel: activityLevel,
        fitnessGoal: fitnessGoal,
        emotionalHealth: emotionalHealth,
        medicalConditions: medicalConditions,
        dietPlanId: dietPlanId,
        planId: planId,
        trainerId: trainerId,
        preferredTime: preferredTime,
        status: status,
        joinDate: DateTime.now().toIso8601String().split('T').first,
      );

      await _memberService.addMember(member);
      await fetchMembers();
      return true;
    } catch (e, stackTrace) {
      debugPrint('Error adding member: $e\n$stackTrace');
      _errorMessage = 'Failed to add member: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMember(Member member) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _memberService.updateMember(member);
      await fetchMembers();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update member.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMember(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _memberService.deleteMember(id);
      await fetchMembers();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete member.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
