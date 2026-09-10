import 'package:flutter/foundation.dart';
import '../models/attendance.dart';
import '../models/member.dart';
import '../models/membership_plan.dart';
import '../models/trainer.dart';
import '../services/attendance_service.dart';
import '../utils/formatters.dart';

enum AttendanceSortOption {
  nameAsc,
  nameDesc,
  recentCheckIn,
  membershipExpiring,
}

extension AttendanceSortOptionExtension on AttendanceSortOption {
  String get label {
    switch (this) {
      case AttendanceSortOption.nameAsc:
        return 'Name (A - Z)';
      case AttendanceSortOption.nameDesc:
        return 'Name (Z - A)';
      case AttendanceSortOption.recentCheckIn:
        return 'Recent Check-in';
      case AttendanceSortOption.membershipExpiring:
        return 'Membership (Expiring Soonest)';
    }
  }
}

class AttendanceMemberItem {
  final Member member;
  final MembershipPlan? plan;
  final Trainer? trainer;
  final Attendance? todayAttendance;
  final int attendedDays;
  final int totalCycleDays;
  final String lastCheckInText;
  final DateTime? lastCheckInDateTime;

  AttendanceMemberItem({
    required this.member,
    this.plan,
    this.trainer,
    this.todayAttendance,
    this.attendedDays = 0,
    this.totalCycleDays = 20,
    required this.lastCheckInText,
    this.lastCheckInDateTime,
  });

  bool get isCheckedIn =>
      todayAttendance != null &&
      todayAttendance!.checkIn != null &&
      todayAttendance!.checkOut == null;

  bool get isCompletedToday =>
      todayAttendance != null &&
      todayAttendance!.checkIn != null &&
      todayAttendance!.checkOut != null;

  bool get isNotCheckedIn =>
      todayAttendance == null || todayAttendance!.checkIn == null;

  String? get checkInTime => todayAttendance?.checkIn;
  String? get checkOutTime => todayAttendance?.checkOut;

  AttendanceMemberItem copyWith({
    Member? member,
    MembershipPlan? plan,
    Trainer? trainer,
    Attendance? todayAttendance,
    int? attendedDays,
    int? totalCycleDays,
    String? lastCheckInText,
    DateTime? lastCheckInDateTime,
  }) {
    return AttendanceMemberItem(
      member: member ?? this.member,
      plan: plan ?? this.plan,
      trainer: trainer ?? this.trainer,
      todayAttendance: todayAttendance ?? this.todayAttendance,
      attendedDays: attendedDays ?? this.attendedDays,
      totalCycleDays: totalCycleDays ?? this.totalCycleDays,
      lastCheckInText: lastCheckInText ?? this.lastCheckInText,
      lastCheckInDateTime: lastCheckInDateTime ?? this.lastCheckInDateTime,
    );
  }
}

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _service = AttendanceService.instance;

  List<AttendanceMemberItem> _items = [];
  List<MembershipPlan> _membershipPlans = [];
  List<Trainer> _trainers = [];
  DateTime _selectedDate = DateTime.now();

  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  int? _planFilter; // null means All
  String _statusFilter = 'All'; // All, Present, Absent, Expired
  AttendanceSortOption _sortOption = AttendanceSortOption.nameAsc;

  List<AttendanceMemberItem> get items => _items;
  List<MembershipPlan> get membershipPlans => _membershipPlans;
  List<Trainer> get trainers => _trainers;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  int? get planFilter => _planFilter;
  String get statusFilter => _statusFilter;
  AttendanceSortOption get sortOption => _sortOption;

  bool get hasActiveFilters =>
      _planFilter != null ||
      _statusFilter != 'All' ||
      _searchQuery.isNotEmpty;

  bool get isSorted => _sortOption != AttendanceSortOption.nameAsc;

  List<AttendanceMemberItem> get filteredItems {
    final list = _items.where((item) {
      final m = item.member;
      // 1. Search Query
      final matchesSearch =
          _searchQuery.isEmpty ||
          m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.mobileNumber.contains(_searchQuery) ||
          (m.email != null &&
              m.email!.toLowerCase().contains(_searchQuery.toLowerCase()));

      // 2. Plan Filter
      final matchesPlan =
          _planFilter == null || m.planId == _planFilter;

      // 3. Status Filter
      bool matchesStatus = true;
      if (_statusFilter == 'Present') {
        matchesStatus = !item.isNotCheckedIn;
      } else if (_statusFilter == 'Absent') {
        matchesStatus = item.isNotCheckedIn;
      } else if (_statusFilter == 'Expired') {
        final status = m.getMembershipStatus(
          planDurationDays: item.plan?.durationDays ?? 30,
        );
        matchesStatus = status.isExpired;
      }

      return matchesSearch && matchesPlan && matchesStatus;
    }).toList();

    // Sorting
    switch (_sortOption) {
      case AttendanceSortOption.nameAsc:
        list.sort((a, b) =>
            a.member.name.toLowerCase().compareTo(b.member.name.toLowerCase()));
        break;
      case AttendanceSortOption.nameDesc:
        list.sort((a, b) =>
            b.member.name.toLowerCase().compareTo(a.member.name.toLowerCase()));
        break;
      case AttendanceSortOption.recentCheckIn:
        list.sort((a, b) {
          final timeA = a.lastCheckInDateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          final timeB = b.lastCheckInDateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          return timeB.compareTo(timeA);
        });
        break;
      case AttendanceSortOption.membershipExpiring:
        list.sort((a, b) {
          final statusA = a.member.getMembershipStatus(
            planDurationDays: a.plan?.durationDays ?? 30,
          );
          final statusB = b.member.getMembershipStatus(
            planDurationDays: b.plan?.durationDays ?? 30,
          );
          return statusA.daysLeft.compareTo(statusB.daysLeft);
        });
        break;
    }

    return list;
  }

  Future<void> fetchAttendanceData({DateTime? date}) async {
    _isLoading = true;
    _errorMessage = null;
    if (date != null) {
      _selectedDate = date;
    }
    notifyListeners();

    try {
      final members = await _service.getAllMembers();
      _membershipPlans = await _service.getMembershipPlans();
      _trainers = await _service.getTrainers();

      final dateStr = _selectedDate.toIso8601String().split('T').first;
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      final isViewingToday = dateStr == todayStr;

      final dateAttendanceList = await _service.getAttendanceByDate(dateStr);
      final attendanceMap = <int, Attendance>{};
      for (var a in dateAttendanceList) {
        if (a.memberId != null) {
          attendanceMap[a.memberId!] = a;
        }
      }

      final List<AttendanceMemberItem> loadedItems = [];

      for (var member in members) {
        if (member.id == null) continue;

        // Find plan
        MembershipPlan? assignedPlan;
        if (member.planId != null) {
          assignedPlan = _membershipPlans.cast<MembershipPlan?>().firstWhere(
                (p) => p?.id == member.planId,
                orElse: () => null,
              );
        }

        // Find trainer
        Trainer? assignedTrainer;
        if (member.trainerId != null) {
          assignedTrainer = _trainers.cast<Trainer?>().firstWhere(
                (t) => t?.id == member.trainerId,
                orElse: () => null,
              );
        }

        final todayAtt = attendanceMap[member.id!];

        // Attended count
        final attendedCount =
            await _service.getAttendanceCountForMember(member.id!);

        // Compute relative last check-in string
        final latestAtt =
            await _service.getLatestAttendanceForMember(member.id!);

        DateTime? checkInDateTime;
        String relativeStr;

        if (todayAtt != null && todayAtt.checkIn != null && isViewingToday) {
          // Checked in today!
          final parsedTodayCheckIn = _parseTimeOnDate(todayAtt.checkIn!, _selectedDate);
          checkInDateTime = parsedTodayCheckIn;
          relativeStr = _formatRelativeTime(parsedTodayCheckIn);
        } else if (latestAtt != null && latestAtt.checkIn != null) {
          try {
            final attDate = DateTime.parse(latestAtt.date);
            final parsedLatest = _parseTimeOnDate(latestAtt.checkIn!, attDate);
            checkInDateTime = parsedLatest;
            relativeStr = _formatRelativeTime(parsedLatest);
          } catch (_) {
            relativeStr = latestAtt.date;
          }
        } else {
          relativeStr = 'Never';
        }

        final lastCheckInText =
            'Last check-in: $relativeStr ($attendedCount/20 days)';

        loadedItems.add(AttendanceMemberItem(
          member: member,
          plan: assignedPlan,
          trainer: assignedTrainer,
          todayAttendance: todayAtt,
          attendedDays: attendedCount,
          totalCycleDays: 20,
          lastCheckInText: lastCheckInText,
          lastCheckInDateTime: checkInDateTime,
        ));
      }

      _items = loadedItems;
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error fetching attendance data: $e\n$stackTrace');
      _isLoading = false;
      _errorMessage = 'Failed to load attendance data.';
      notifyListeners();
    }
  }

  DateTime _parseTimeOnDate(String timeStr, DateTime baseDate) {
    try {
      final parts = timeStr.trim().split(' ');
      final timeParts = parts[0].split(':');
      var hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      if (parts.length > 1) {
        final ampm = parts[1].toUpperCase();
        if (ampm == 'PM' && hour < 12) hour += 12;
        if (ampm == 'AM' && hour == 12) hour = 0;
      }
      return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
    } catch (_) {
      return baseDate;
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return mins <= 1 ? 'Just now' : '${mins}m ago';
    } else if (difference.inHours < 24 && dateTime.day == now.day) {
      final hrs = difference.inHours;
      return '${hrs}h ago';
    } else if (difference.inDays == 1 || (now.day - dateTime.day == 1 && difference.inDays < 2)) {
      return '1d ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return AppFormatters.formatDisplayDate(dateTime);
    }
  }

  Future<bool> checkInMember(int memberId, {String? checkInTime, DateTime? date}) async {
    try {
      final targetDate = date ?? _selectedDate;
      final timeStr = checkInTime ?? AppFormatters.formatTime(DateTime.now());
      final dateStr = targetDate.toIso8601String().split('T').first;

      final existingIndex =
          _items.indexWhere((item) => item.member.id == memberId);
      Attendance? existingAtt;
      if (existingIndex != -1) {
        existingAtt = _items[existingIndex].todayAttendance;
      }

      // If already marked for the day (both IN and OUT exist), no update allowed!
      if (existingAtt != null &&
          existingAtt.checkIn != null &&
          existingAtt.checkOut != null) {
        return false;
      }

      // If already checked in, no re-check-in allowed!
      if (existingAtt != null && existingAtt.checkIn != null) {
        return false;
      }

      final newAttendance = Attendance(
        id: existingAtt?.id,
        memberId: memberId,
        date: dateStr,
        checkIn: timeStr,
        checkOut: existingAtt?.checkOut,
        status: 'Present',
      );

      final recordId = await _service.markAttendance(newAttendance);
      final savedAtt = Attendance(
        id: recordId,
        memberId: memberId,
        date: dateStr,
        checkIn: timeStr,
        checkOut: existingAtt?.checkOut,
        status: 'Present',
      );

      if (existingIndex != -1) {
        final item = _items[existingIndex];
        final newAttendedDays = existingAtt == null ? item.attendedDays + 1 : item.attendedDays;
        _items[existingIndex] = item.copyWith(
          todayAttendance: savedAtt,
          attendedDays: newAttendedDays,
          lastCheckInText: 'Last check-in: Just now ($newAttendedDays/20 days)',
          lastCheckInDateTime: DateTime.now(),
        );
        notifyListeners();
      }

      return true;
    } catch (e, stackTrace) {
      debugPrint('Error marking check-in in AttendanceProvider: $e\n$stackTrace');
      return false;
    }
  }

  Future<bool> checkOutMember(int memberId, {String? checkOutTime, DateTime? date}) async {
    try {
      final targetDate = date ?? _selectedDate;
      final timeStr = checkOutTime ?? AppFormatters.formatTime(DateTime.now());
      final dateStr = targetDate.toIso8601String().split('T').first;

      final existingIndex =
          _items.indexWhere((item) => item.member.id == memberId);
      if (existingIndex == -1) return false;

      final item = _items[existingIndex];
      final existingAtt = item.todayAttendance;

      // Must have checked in first
      if (existingAtt == null || existingAtt.checkIn == null) {
        return false;
      }

      // If already checked out, attendance is completed for the day - no update allowed!
      if (existingAtt.checkOut != null) {
        return false;
      }

      final updatedAttendance = Attendance(
        id: existingAtt.id,
        memberId: memberId,
        date: dateStr,
        checkIn: existingAtt.checkIn,
        checkOut: timeStr,
        status: 'Present',
      );

      final recordId = await _service.markAttendance(updatedAttendance);
      final savedAtt = Attendance(
        id: recordId,
        memberId: memberId,
        date: dateStr,
        checkIn: updatedAttendance.checkIn,
        checkOut: timeStr,
        status: 'Present',
      );

      _items[existingIndex] = item.copyWith(
        todayAttendance: savedAtt,
      );
      notifyListeners();

      return true;
    } catch (e, stackTrace) {
      debugPrint('Error marking check-out in AttendanceProvider: $e\n$stackTrace');
      return false;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setPlanFilter(int? planId) {
    _planFilter = planId;
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setSortOption(AttendanceSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    fetchAttendanceData(date: date);
  }

  void resetFilters() {
    _searchQuery = '';
    _planFilter = null;
    _statusFilter = 'All';
    _sortOption = AttendanceSortOption.nameAsc;
    notifyListeners();
  }
}
