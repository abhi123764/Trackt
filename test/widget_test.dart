import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trackt/main.dart';
import 'package:trackt/models/member.dart';
import 'package:trackt/providers/auth_provider.dart';
import 'package:trackt/providers/dashboard_provider.dart';
import 'package:trackt/providers/member_provider.dart';
import 'package:trackt/providers/trainer_provider.dart';
import 'package:trackt/screens/members/member_details_screen.dart';
import 'package:trackt/screens/members/members_screen.dart';
import 'package:trackt/screens/trainers/trainers_screen.dart';

void main() {
  testWidgets('App smoke test - renders SplashScreen with app name', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => DashboardProvider()),
          ChangeNotifierProvider(create: (_) => MemberProvider()),
          ChangeNotifierProvider(create: (_) => TrainerProvider()),
        ],
        child: const TracktApp(),
      ),
    );

    // Verify that the splash screen shows Trackt brand name and tagline
    expect(find.text('Trackt'), findsOneWidget);
    expect(find.text('TRACK. MANAGE. GROW.'), findsOneWidget);
  });

  testWidgets('MemberDetailsScreen renders member profile details', (WidgetTester tester) async {
    final testMember = Member(
      id: 99,
      name: 'Bruce Wayne',
      mobileNumber: '9876543210',
      email: 'bruce@wayne.com',
      gender: 'Male',
      bloodGroup: 'O+',
      dob: '19/02/1985',
      address: 'Wayne Manor, Gotham',
      height: 188,
      weight: 95,
      targetWeight: 92,
      bmi: 26.9,
      fitnessGoal: 'Endurance',
      activityLevel: 'Very Active',
      status: 'Active',
      joinDate: '2026-01-01',
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MemberProvider()),
        ],
        child: MaterialApp(
          home: MemberDetailsScreen(member: testMember),
        ),
      ),
    );

    expect(find.text('Member Profile'), findsOneWidget);
    expect(find.text('Bruce Wayne'), findsOneWidget);
    expect(find.text('Membership & Trainer'), findsOneWidget);
    expect(find.text('Health & Fitness Profile'), findsOneWidget);
    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('Uploaded Documents'), findsOneWidget);
    expect(find.text('9876543210'), findsOneWidget);
    expect(find.text('bruce@wayne.com'), findsOneWidget);
    expect(find.text('Wayne Manor, Gotham'), findsOneWidget);
    expect(find.text('188 cm'), findsOneWidget);
    expect(find.text('95.0 kg'), findsOneWidget);
  });

  testWidgets('MembersScreen back button switches dashboard tab to 0', (WidgetTester tester) async {
    final dashboardProvider = DashboardProvider();
    dashboardProvider.setTab(1);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: dashboardProvider),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => MemberProvider()),
        ],
        child: const MaterialApp(
          home: MembersScreen(),
        ),
      ),
    );

    expect(find.text('Members'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);

    // Tap back button
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    expect(dashboardProvider.currentTab, 0);
  });

  testWidgets('TrainersScreen back button navigates back', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => TrainerProvider()),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TrainersScreen()),
                  );
                },
                child: const Text('Open Trainers'),
              ),
            ),
          ),
        ),
      ),
    );

    // Push TrainersScreen
    await tester.tap(find.text('Open Trainers'));
    await tester.pumpAndSettle();

    expect(find.text('Trainers'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);

    // Tap back button
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    // Verify we are back to previous screen
    expect(find.text('Open Trainers'), findsOneWidget);
    expect(find.text('Trainers'), findsNothing);
  });
}

