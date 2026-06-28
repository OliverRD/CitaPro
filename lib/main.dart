import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'domain/repositories/auth_repository.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/login_with_google_usecase.dart';
import 'presentation/viewmodels/login_viewmodel.dart';
import 'presentation/viewmodels/booking_viewmodel.dart';
import 'presentation/viewmodels/profile_viewmodel.dart'; // Importación añadida
import 'presentation/views/login_view.dart';
import 'presentation/views/main_navigation_screen.dart';
import 'presentation/views/admin_navigationscreen.dart';

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

        // Proveedor del LoginViewModel
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

        // 🔥 PROVEEDOR GLOBAL ASIGNADO: Mantiene los datos del perfil vivos
        ChangeNotifierProvider(create: (context) => ProfileViewModel()),

        // Gestiona las reservas de Barbería El Maestro y Zen Spa Wellness
        ChangeNotifierProvider(create: (context) => BookingViewModel()),
      ],
      child: MaterialApp(
        title: 'CitaPro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
        home: const AuthSessionValidator(),
      ),
    );
  }
}

/// Widget Intermedio para validar la sesión persistente y redirigir según el Rol real
class AuthSessionValidator extends StatelessWidget {
  const AuthSessionValidator({super.key});

  Future<Widget> _determineInitialScreen(SupabaseClient client) async {
    final session = client.auth.currentSession;

    if (session == null) {
      return const LoginView();
    }

    try {
      final data = await client
          .from('usuarios')
          .select('id_rol')
          .eq('auth_id', session.user.id)
          .maybeSingle();

      if (data != null) {
        final int idRol = data['id_rol'] ?? 1;
        if (idRol == 2) {
          return const AdminNavigationScreen();
        }
      }
      return const MainNavigationScreen();
    } catch (e) {
      return const LoginView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final supabaseClient = Supabase.instance.client;

    return FutureBuilder<Widget>(
      future: _determineInitialScreen(supabaseClient),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8FAFC),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4F46E5),
                strokeWidth: 3,
              ),
            ),
          );
        }

        return snapshot.data ?? const LoginView();
      },
    );
  }
}
