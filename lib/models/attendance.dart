class Attendance {
  final int? id;
  final int? memberId;
  final int? trainerId;
  final String date;
  final String? checkIn;
  final String? checkOut;
  final String status;

  Attendance({
    this.id,
    this.memberId,
    this.trainerId,
    required this.date,
    this.checkIn,
    this.checkOut,
    this.status = 'Present',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'member_id': memberId,
      'trainer_id': trainerId,
      'date': date,
      'check_in': checkIn,
      'check_out': checkOut,
      'status': status,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      memberId: map['member_id'],
      trainerId: map['trainer_id'],
      date: map['date'],
      checkIn: map['check_in'],
      checkOut: map['check_out'],
      status: map['status'],
    );
  }
}