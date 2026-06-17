import 'package:flutter/material.dart';
import 'bookings_view.dart'; 
import 'profile_screen.dart'; 
import 'home_view.dart'; 

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0; 

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeView(), 
      const BookingsView(),
      const Center(child: Text('Pantalla de Historial', style: TextStyle(color: Color(0xFF64748B)))),
      const ProfileScreen(), 
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens, 
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0061FF), 
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.explore_outlined),
            ),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _currentIndex == 1
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0061FF), // Fondo azul estilizado para el botón activo
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.calendar_month, color: Colors.white, size: 20),
                    )
                  : const Icon(Icons.calendar_month_outlined),
            ),
            label: 'Trabajos',
          ),
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.history),
            ),
            label: 'Historial',
          ),
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.person_outline),
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}