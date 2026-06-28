import 'package:flutter/material.dart';
import 'package:flutter_application_1/domain/repositories/auth_repository.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/auth/login_usecase.dart';
import 'presentation/viewmodels/login_viewmodel.dart';
import 'presentation/views/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://guhnpoxdtgdriqihpsfl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd1aG5wb3hkdGdkcmlxaWhwc2ZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE0ODI2ODYsImV4cCI6MjA5NzA1ODY4Nn0.T82orVzjDTAGJYbF6KkXMlm__nBf0xGJMv7pNo7zZ_U',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseClient = Supabase.instance.client;

    return MultiProvider(
      providers: [
        Provider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(supabaseClient),
        ),
        // Registro del ViewModel de inicio de sesión
        ChangeNotifierProvider(
          create: (context) => LoginViewModel(
            LoginUseCase(Provider.of<AuthRepository>(context, listen: false)),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'CitaPro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: const LoginView(),
      ),
    );
  }
}
