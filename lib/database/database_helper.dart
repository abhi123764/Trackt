import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/app_user.dart';
import '../models/membership_plan.dart';
import '../models/member.dart';
import '../models/trainer.dart';
import '../models/attendance.dart';
import '../models/payment.dart';
import '../models/expense.dart';
import '../models/diet_plan.dart';
import '../models/diet_meal.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('trackt.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    //USERS

    await db.execute('''
        CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        f_name TEXT NOT NULL,
        l_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        dob TEXT,
        mobile_number TEXT,
        password TEXT NOT NULL,
        theme_preference TEXT DEFAULT 'System',
        language_preference TEXT DEFAULT 'English',
        created_at TEXT NOT NULL
         )
''');

    //MEMBERSHIP PLANS

    await db.execute('''
        CREATE TABLE membership_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        duration_days INTEGER NOT NULL,
        price REAL NOT NULL
           ) 
        ''');

    //TRAINERS

    await db.execute('''
        CREATE TABLE trainers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT,
        dob TEXT,
        blood_group TEXT,
        mobile_number TEXT,
        email TEXT,
        address TEXT,
        profile_photo_path TEXT,
        id_proof_path TEXT,
        qualification TEXT,
        certificate_photo_path TEXT,
        experience TEXT,
        shift_start TEXT,
        shift_end TEXT,
        joining_date TEXT NOT NULL,
        salary REAL NOT NULL DEFAULT 0
        )
''');

    //DIET PLANS

    await db.execute('''
         CREATE TABLE diet_plans (
         id INTEGER PRIMARY KEY AUTOINCREMENT,
         name TEXT NOT NULL,
         category TEXT,
         calories REAL,
         protein_percentage REAL,
         carbs_percentage REAL,
         fat_percentage REAL,
         description TEXT,
         image_path TEXT
         )


    ''');

    //MEMBERS

    await db.execute(''' 
        CREATE TABLE members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        gender TEXT,
        blood_group TEXT,
        dob TEXT,
        mobile_number TEXT NOT NULL,
        email TEXT,
        address TEXT,
        profile_photo_path TEXT,
        idproof_path TEXT,
        medical_reports_path TEXT,
        height REAL,
        weight REAL,
        target_weight REAL,
        bmi REAL,
        activity_level TEXT,
        fitness_goal TEXT,
        emotional_health TEXT,
        medical_conditions TEXT,
        diet_plan_id INTEGER,
        plan_id INTEGER,
        trainer_id INTEGER,
        preferred_time TEXT,
        status TEXT NOT NULL DEFAULT 'Active',
        join_date TEXT NOT NULL,
        FOREIGN KEY (diet_plan_id)REFERENCES diet_plans (id)
          ON DELETE SET NULL
          ON UPDATE CASCADE,
        FOREIGN KEY (plan_id) REFERENCES membership_plans (id)
          ON DELETE SET NULL
          ON UPDATE CASCADE,
        FOREIGN KEY (trainer_id) REFERENCES trainers (id) 
          ON DELETE SET NULL
          ON UPDATE CASCADE
 
        )
        ''');

    //ATTENDANCE (members & trainers)

    await db.execute(''' 
        CREATE TABLE attendance(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        member_id INTEGER,
        trainer_id INTEGER,
        date TEXT NOT NULL,
        check_in TEXT,
        check_out TEXT,
        status TEXT NOT NULL DEFAULT 'Present',


    CHECK (
      (member_id IS NOT NULL AND trainer_id IS NULL)
      OR
      (member_id IS NULL AND trainer_id IS NOT NULL)
    ),
    
        FOREIGN KEY (trainer_id) REFERENCES trainers (id) 
             ON DELETE CASCADE ON UPDATE CASCADE,
          FOREIGN KEY (member_id) REFERENCES members (id) 
            ON DELETE CASCADE ON UPDATE CASCADE
        )
    ''');

    //PAYMENTS

    await db.execute('''
        CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        member_id INTEGER,
        plan_id INTEGER,
        amount REAL NOT NULL,
        payment_date TEXT NOT NULL,
        due_date TEXT,
        transaction_id TEXT,
        notes TEXT,
        payment_method TEXT NOT NULL DEFAULT 'Cash',
        status TEXT NOT NULL DEFAULT 'Paid',
        FOREIGN KEY (member_id) REFERENCES members (id) 
         ON DELETE SET NULL
         ON UPDATE CASCADE,
        FOREIGN KEY (plan_id) REFERENCES membership_plans (id)
          ON DELETE SET NULL
          ON UPDATE CASCADE
        )
         ''');

    //EXPENSES

    await db.execute(''' 
        CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        add_category TEXT,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        receipt_path TEXT
    
    )
    
    ''');

    //DIET PLAN MEALS

    await db.execute(''' 
    CREATE TABLE diet_meals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    plan_id INTEGER NOT NULL,
    meal_name TEXT NOT NULL,
     meal_type TEXT NOT NULL, 
    quantity TEXT,
    calories REAL,
    protein REAL,
    carbs REAL,
    fat REAL,
    image_path TEXT,
    FOREIGN KEY (plan_id) REFERENCES diet_plans(id)
      ON DELETE CASCADE
      ON UPDATE CASCADE
);
    ''');

    //Indexes for common search / reports screens
    await db.execute('CREATE INDEX idx_attendance_date ON attendance (date)');
    await db.execute(
      'CREATE INDEX idx_attendance_member ON attendance (member_id)',
    );

    await db.execute(
      'CREATE INDEX idx_attendance_trainer ON attendance (trainer_id)',
    );
    await db.execute(
      'CREATE INDEX idx_payments_date ON payments (payment_date)',
    );
    await db.execute(
      'CREATE INDEX idx_payments_member ON payments (member_id)',
    );
    await db.execute('CREATE INDEX idx_expenses_date ON expenses (date)');
    await db.execute('CREATE INDEX idx_members_status ON members (status)');
    await db.execute(
      'CREATE INDEX idx_diet_meals_plan ON diet_meals (plan_id)',
    );

    //Default Membership Plans

    await db.insert('membership_plans', {
      'name': 'Elite',
      'duration_days': 30,
      'price': 2500.0,
    });
    await db.insert('membership_plans', {
      'name': 'Premium',
      'duration_days': 30,
      'price': 1500.0,
    });
    await db.insert('membership_plans', {
      'name': 'Normal',
      'duration_days': 30,
      'price': 1200.0,
    });
  }

  //USERS (Login / Register screens)
  Future<int> insertUser(AppUser user) async {
    final db = await database;
    final map = user.toMap()
      ..removeWhere((key, value) => key == 'id' && value == null);
    map['email'] = user.email.toLowerCase().trim();
    return await db.insert('users', map);
  }

  Future<AppUser?> loginUser(String email, String password) async {
    final db = await database;
    final normalizedEmail = email.toLowerCase().trim();
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [normalizedEmail, password],
    );
    if (result.isNotEmpty) return AppUser.fromMap(result.first);
    return null;
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final db = await database;
    final normalizedEmail = email.toLowerCase().trim();
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );
    if (result.isNotEmpty) return AppUser.fromMap(result.first);
    return null;
  }

  Future<AppUser?> getUserById(int id) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) return AppUser.fromMap(result.first);
    return null;
  }

  //MEMBERSHIP PLANS

  Future<int> insertPlan(MembershipPlan plan) async {
    final db = await database;
    return await db.insert('membership_plans', plan.toMap()..remove('id'));
  }

  Future<List<MembershipPlan>> getAllPlans() async {
    final db = await database;
    final result = await db.query('membership_plans');
    return result.map((e) => MembershipPlan.fromMap(e)).toList();
  }

  Future<int> updatePlan(MembershipPlan plan) async {
    final db = await database;
    return await db.update(
      'membership_plans',
      plan.toMap(),
      where: 'id = ?',
      whereArgs: [plan.id],
    );
  }

  Future<int> deletePlan(int id) async {
    final db = await database;
    return await db.delete(
      'membership_plans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //MEMBERS (dashboard, members list, add members, edit details)

  Future<int> insertMember(Member member) async {
    final db = await database;
    return await db.insert('members', member.toMap()..remove('id'));
  }

  Future<List<Member>> getAllMembers() async {
    final db = await database;
    final result = await db.query('members', orderBy: 'name ASC');
    return result.map((e) => Member.fromMap(e)).toList();
  }

  Future<Member?> getMemberById(int id) async {
    final db = await database;
    final result = await db.query('members', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) return Member.fromMap(result.first);
    return null;
  }

  Future<List<Member>> searchMembers(String query) async {
    final db = await database;
    final result = await db.query(
      'members',
      where: 'name LIKE ? OR mobile_number LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return result.map((e) => Member.fromMap(e)).toList();
  }

  Future<int> updateMember(Member member) async {
    final db = await database;
    return await db.update(
      'members',
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<int> deleteMember(int id) async {
    final db = await database;
    return await db.delete('members', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countActiveMembers() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM members WHERE status = 'Active'",
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  //TRAINERS (trainers list, add trainer, trainer details)

  Future<int> insertTrainer(Trainer trainer) async {
    final db = await database;
    return await db.insert('trainers', trainer.toMap()..remove('id'));
  }

  Future<List<Trainer>> getAllTrainers() async {
    final db = await database;
    final result = await db.query('trainers', orderBy: 'name ASC');
    return result.map((e) => Trainer.fromMap(e)).toList();
  }

  Future<Trainer?> getTrainerById(int id) async {
    final db = await database;
    final result = await db.query('trainers', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) return Trainer.fromMap(result.first);
    return null;
  }

  Future<int> updateTrainer(Trainer trainer) async {
    final db = await database;
    return await db.update(
      'trainers',
      trainer.toMap(),
      where: 'id = ?',
      whereArgs: [trainer.id],
    );
  }

  Future<int> deleteTrainer(int id) async {
    final db = await database;
    return await db.delete('trainers', where: 'id = ?', whereArgs: [id]);
  }

  //ATTENDANCE (attendance, attendance record/details screens)

  Future<int> markAttendance(Attendance attendance) async {
    final db = await database;
    return await db.insert('attendance', attendance.toMap()..remove('id'));
  }

  Future<List<Attendance>> getAttendanceForMember(int memberId) async {
    final db = await database;
    final result = await db.query(
      'attendance',
      where: 'member_id = ?',
      whereArgs: [memberId],
      orderBy: 'date DESC',
    );
    return result.map((e) => Attendance.fromMap(e)).toList();
  }

  Future<List<Attendance>> getAttendanceForTrainer(int trainerId) async {
    final db = await database;
    final result = await db.query(
      'attendance',
      where: 'trainer_id = ?',
      whereArgs: [trainerId],
      orderBy: 'date DESC',
    );
    return result.map((e) => Attendance.fromMap(e)).toList();
  }

  Future<List<Attendance>> getAttendanceByDate(String date) async {
    final db = await database;
    final result = await db.query(
      'attendance',
      where: 'date = ?',
      whereArgs: [date],
    );
    return result.map((e) => Attendance.fromMap(e)).toList();
  }

  Future<int> updateAttendance(Attendance attendance) async {
    final db = await database;
    return await db.update(
      'attendance',
      attendance.toMap(),
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
  }

  Future<int> deleteAttendance(int id) async {
    final db = await database;
    return await db.delete('attendance', where: 'id = ?', whereArgs: [id]);
  }

  //PAYMENTS (payments, payment details)

  Future<int> insertPayment(Payment payment) async {
    final db = await database;
    return await db.insert('payments', payment.toMap()..remove('id'));
  }

  Future<List<Payment>> getAllPayments() async {
    final db = await database;
    final result = await db.query('payments', orderBy: 'payment_date DESC');
    return result.map((e) => Payment.fromMap(e)).toList();
  }

  Future<List<Payment>> getPaymentsForMember(int memberId) async {
    final db = await database;
    final result = await db.query(
      'payments',
      where: 'member_id = ?',
      whereArgs: [memberId],
      orderBy: 'payment_date DESC',
    );
    return result.map((e) => Payment.fromMap(e)).toList();
  }

  Future<double> getTotalRevenue({String? fromDate, String? toDate}) async {
    final db = await database;
    String where = "status = 'Paid'";
    List<Object?> args = [];
    if (fromDate != null && toDate != null) {
      where += ' AND payment_date BETWEEN ? AND ?';
      args = [fromDate, toDate];
    }
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM payments WHERE $where',
      args,
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> updatePayment(Payment payment) async {
    final db = await database;
    return await db.update(
      'payments',
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  Future<int> deletePayment(int id) async {
    final db = await database;
    return await db.delete('payments', where: 'id = ?', whereArgs: [id]);
  }

  //EXPENSES (expenses report, expense management)

  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap()..remove('id'));
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final result = await db.query('expenses', orderBy: 'date DESC');
    return result.map((e) => Expense.fromMap(e)).toList();
  }

  Future<double> getTotalExpenses({String? fromDate, String? toDate}) async {
    final db = await database;
    String where = '1=1';
    List<Object?> args = [];
    if (fromDate != null && toDate != null) {
      where = 'date BETWEEN ? AND ?';
      args = [fromDate, toDate];
    }
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE $where',
      args,
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  //DIET PLANS (diet screen)

  Future<int> insertDietItem(DietPlan diet) async {
    final db = await database;
    return await db.insert('diet_plans', diet.toMap()..remove('id'));
  }

  Future<List<DietPlan>> getAllDietPlans() async {
    final db = await database;

    final result = await db.query('diet_plans', orderBy: 'name ASC');

    return result.map((e) => DietPlan.fromMap(e)).toList();
  }

  Future<DietPlan?> getDietPlanById(int id) async {
    final db = await database;

    final result = await db.query(
      'diet_plans',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return DietPlan.fromMap(result.first);
    }

    return null;
  }

  Future<int> updateDietItem(DietPlan diet) async {
    final db = await database;
    return await db.update(
      'diet_plans',
      diet.toMap(),
      where: 'id = ?',
      whereArgs: [diet.id],
    );
  }

  Future<int> deleteDietItem(int id) async {
    final db = await database;
    return await db.delete('diet_plans', where: 'id = ?', whereArgs: [id]);
  }

  //Diet meals

  Future<int> insertDietMeal(DietMeal meal) async {
    final db = await database;

    return await db.insert('diet_meals', meal.toMap()..remove('id'));
  }

  Future<List<DietMeal>> getMealsForDietPlan(int planId) async {
    final db = await database;

    final result = await db.query(
      'diet_meals',
      where: 'plan_id = ?',
      whereArgs: [planId],
      orderBy: 'id ASC',
    );

    return result.map((e) => DietMeal.fromMap(e)).toList();
  }

  Future<DietMeal?> getDietMealById(int id) async {
    final db = await database;

    final result = await db.query(
      'diet_meals',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return DietMeal.fromMap(result.first);
    }

    return null;
  }

  Future<int> updateDietMeal(DietMeal meal) async {
    final db = await database;

    return await db.update(
      'diet_meals',
      meal.toMap(),
      where: 'id = ?',
      whereArgs: [meal.id],
    );
  }

  Future<int> deleteDietMeal(int id) async {
    final db = await database;

    return await db.delete('diet_meals', where: 'id = ?', whereArgs: [id]);
  }

  //REPORTS screen

  Future<Map<String, dynamic>> getDashboardSummary() async {
    final db = await database;

    // TOTAL MEMBERS

    final totalMembers =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM members'),
        ) ??
        0;

    // ACTIVE MEMBERS

    final activeMembers =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM members WHERE status = 'Active'",
          ),
        ) ??
        0;

    // TOTAL TRAINERS

    final totalTrainers =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM trainers'),
        ) ??
        0;

    // TOTAL REVENUE

    final revenueResult = await db.rawQuery('''
    SELECT COALESCE(SUM(amount), 0) AS total
    FROM payments
    WHERE status = 'Paid'
    ''');

    final totalRevenue =
        (revenueResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // TOTAL EXPENSES

    final expenseResult = await db.rawQuery('''
    SELECT COALESCE(SUM(amount), 0) AS total
    FROM expenses
    ''');

    final totalExpenses =
        (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // TODAY'S ATTENDANCE

    final today = DateTime.now().toIso8601String().split('T').first;

    final todayAttendance =
        Sqflite.firstIntValue(
          await db.rawQuery(
            '''
          SELECT COUNT(*)
          FROM attendance
          WHERE date = ?
          AND status = 'Present'
          ''',
            [today],
          ),
        ) ??
        0;

    // PENDING FEES

    //
    // Temporarily 0 because your current database does not yet
    // define a reliable unpaid-balance rule.
    //

    const double pendingFees = 0.0;
    const int pendingFeeMembers = 0;

    return {
      'total_members': totalMembers,
      'active_members': activeMembers,
      'today_attendance': todayAttendance,
      'pending_fees': pendingFees,
      'pending_fee_members': pendingFeeMembers,
      'total_revenue': totalRevenue,
      'total_expenses': totalExpenses,
      'total_trainers': totalTrainers,
    };
  }
  //Close DB when app fully exits

  Future close() async {
    final db = await database;
    db.close();
  }
}
