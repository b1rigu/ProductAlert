import 'package:feedback/feedback.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:productalert/firebase_options.dart';
import 'package:productalert/pages/alert_list_page.dart';
import 'package:productalert/pages/login_page.dart';
import 'package:productalert/supabase_creds.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: SupabaseCreds.supabaseUrl,
    anonKey: SupabaseCreds.supabaseKey,
  );

  runApp(
    const BetterFeedback(
      child: MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;
final firebaseMessaging = FirebaseMessaging.instance;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product Alert',
      home: Scaffold(
        body: StreamBuilder<AuthState>(
          stream: supabase.auth.onAuthStateChange,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final session = snapshot.data!.session;
            if (session != null) {
              return const AlertListPage();
            }

            // if (snapshot.data!.event == AuthChangeEvent.passwordRecovery) {}

            return const LoginPage();
          },
        ),
      ),
    );
  }
}

extension ContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Theme.of(this).snackBarTheme.backgroundColor,
      ),
    );
  }
}
