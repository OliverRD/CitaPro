// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/login_with_google_usecase.dart';
import 'presentation/viewmodels/login_viewmodel.dart';
import 'presentation/viewmodels/booking_viewmodel.dart'; // Tu nuevo ViewModel para las reservas
import 'presentation/views/login_view.dart';
import 'presentation/views/main_navigation_screen.dart'; // Tu pantalla principal tras iniciar sesión

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
        // Proveedor del Repositorio de Autenticación
        Provider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(supabaseClient),
        ),

        // Proveedor del LoginViewModel (Inyección de dependencias)
        ChangeNotifierProvider(
          create: (context) {
            final repository = Provider.of<AuthRepository>(
              context,
              listen: false,
            );
            return LoginViewModel(
              LoginUseCase(repository),
              LoginWithGoogleUseCase(repository),
            );
          },
        ),

        // PROVEEDOR AÑADIDO: Gestiona las reservas de Barbería El Maestro y Zen Spa Wellness
        ChangeNotifierProvider(create: (_) => BookingViewModel()),
      ],
      child: MaterialApp(
        title: 'CitaPro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),

        // El StreamBuilder gestiona de forma inteligente si el usuario ya está logueado
        home: StreamBuilder<AuthState>(
          stream: supabaseClient.auth.onAuthStateChange,
          builder: (context, snapshot) {
            // Si la sesión existe y es válida, saltamos directo al menú principal
            if (snapshot.hasData && snapshot.data?.session != null) {
              return const MainNavigationScreen();
            }
            // Si no está logueado, lo mandamos a la pantalla de login
            return const LoginView();
          },
        ),
      ),
    );
  }
}
