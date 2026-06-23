import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([ApiService.loadToken(), ApiService.loadServerUrl()]);
  runApp(const KrutiDevApp());
}

class KrutiDevApp extends StatelessWidget {
  const KrutiDevApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..init(),
      child: MaterialApp(
        title: 'Kruti Dev AI Typing',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1f6feb),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF0d1117),
          cardColor: const Color(0xFF161b22),
          dividerColor: const Color(0xFF30363d),
          useMaterial3: true,
        ),
        home: ApiService.isLoggedIn ? const HomeScreen() : const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _loggedIn = false;

  @override
  Widget build(BuildContext context) {
    if (_loggedIn) return const HomeScreen();
    return LoginScreen(onLogin: () => setState(() => _loggedIn = true));
  }
}
