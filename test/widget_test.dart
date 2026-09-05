import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trackt/main.dart';
import 'package:trackt/providers/auth_provider.dart';
import 'package:trackt/providers/dashboard_provider.dart';
import 'package:trackt/providers/member_provider.dart';
import 'package:trackt/providers/trainer_provider.dart';

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
}
