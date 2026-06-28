import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart'; 
import '../viewmodels/booking_viewmodel.dart'; 
import 'bookings_view.dart'; 

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _supabase = Supabase.instance.client; 
  String _selectedCategory = 'Todos'; 
  String _searchQuery = ''; 
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Todos', 'icon': Icons.grid_view_rounded},
    {'name': 'Barbería', 'icon': Icons.content_cut_rounded},
    {'name': 'Spa', 'icon': Icons.spa_rounded},
    {'name': 'Salón', 'icon': Icons.face_rounded},
    {'name': 'Masajes', 'icon': Icons.dry_cleaning_rounded},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 🔥 FUNCIÓN QUE LE LLEEA DIRECTO A TU TABLA 'negocio' DE SUPABASE
  Future<List<Map<String, dynamic>>> _fetchNegociosFromSupabase() async {
    try {
      final response = await _supabase.from('negocio').select('*');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error conectando a Supabase: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'), 
            ),
            const SizedBox(width: 12),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(text: 'Cita', style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal, color: Color(0xFF1E293B))),
                  TextSpan(text: 'Pro', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Color(0xFF64748B), size: 26),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchNegociosFromSupabase(),
        builder: (context, snapshot) {
          // 1. Estado de carga con indicador circular elegante
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
            );
          }

          // 2. Control de errores si Supabase falla
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los negocios reales.'));
          }

          final listadoNegocios = snapshot.data ?? [];

          // 3. Filtrado dinámico basado en los datos de tu BD
          final servicesToShow = listadoNegocios.where((service) {
            final matchesCategory = _selectedCategory == 'Todos' || 
                (service['descripcion'] ?? '').toString().toLowerCase().contains(_selectedCategory.toLowerCase());

            final matchesSearch = (service['nombre'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase());

            return matchesCategory && matchesSearch;
          }).toList();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Encuentra y Reserva',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: -0.5),
                ),
                const Text(
                  'Los Mejores Servicios',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0061FF), letterSpacing: -0.5),
                ),
                const SizedBox(height: 20),

                // Buscador estilizado original
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar servicios, barberías, salones...', 
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: Color(0xFF64748B)),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.tune_rounded, color: Color(0xFF0061FF), size: 20),
                            ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Categorías horizontales
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat['name'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat['name']; 
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF0061FF) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                cat['icon'],
                                size: 16,
                                color: isSelected ? Colors.white : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                cat['name'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recomendado para ti', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Ver todos', style: TextStyle(color: Color(0xFF0061FF), fontWeight: FontWeight.bold)), 
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Lista Reactiva conectada a tu BD
                servicesToShow.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40.0),
                          child: Text(
                            'No se encontraron servicios en la base de datos',
                            style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: servicesToShow.length,
                        itemBuilder: (context, index) {
                          final service = servicesToShow[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(24),
                                        topRight: Radius.circular(24),
                                      ), 
                                      child: Image.network(
                                        // Mapeo directo de tu columna 'imagen'
                                        service['imagen'] ?? 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
                                        height: 160,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          height: 160,
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 14,
                                      right: 14,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white.withOpacity(0.9),
                                        radius: 18,
                                        child: const Icon(Icons.favorite_border_rounded, color: Color(0xFFEF4444), size: 20),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Disponible', 
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                            ),
                                          ),
                                          const Row(
                                            children: [
                                              Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                              SizedBox(width: 2),
                                              Text(
                                                '4.9',
                                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      // Mapeo directo de tu columna 'nombre'
                                      Text(
                                        service['nombre'] ?? 'Establecimiento CitaPro',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                      ),
                                      const SizedBox(height: 4),
                                      // Mapeo directo de tu columna 'descripcion'
                                      Text(
                                        service['descripcion'] ?? 'Servicios profesionales garantizados.',
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                      ),
                                      const Divider(height: 24, color: Color(0xFFF1F5F9)),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Desde', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))), 
                                              Text(
                                                '\$25',
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0061FF)),
                                              ),
                                            ],
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              final nombreNegocio = service['nombre'] ?? 'Establecimiento';
                                              
                                              Provider.of<BookingViewModel>(context, listen: false)
                                                  .seleccionarBarberia(nombreNegocio);

                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Seleccionaste: $nombreNegocio. Redirigiendo...'),
                                                  backgroundColor: const Color(0xFF0061FF),
                                                  duration: const Duration(seconds: 1),
                                                ),
                                              );

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const BookingsView(),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF0061FF),
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            child: const Text(
                                              'Reservar Ya', 
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                            ), 
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}