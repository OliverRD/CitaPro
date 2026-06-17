import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
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

  final List<Map<String, String>> _recommendedServices = [
    {
      'businessName': 'Barbería El Maestro',
      'category': 'Barbería', 
      'rating': '4.9',
      'reviews': '124 reseñas', 
      'price': '\$25',
      'imageUrl': 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
    },
    {
      'businessName': 'Zen Spa Wellness',
      'category': 'Spa', 
      'rating': '4.8',
      'reviews': '98 reseñas', 
      'price': '\$60',
      'imageUrl': 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=400',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredServices {
    return _recommendedServices.where((service) {
      final matchesCategory = _selectedCategory == 'Todos' || 
          service['category']!.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesSearch = service['businessName']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          service['category']!.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final servicesToShow = _filteredServices;

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
      body: SingleChildScrollView(
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

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
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

            servicesToShow.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Column(
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'No se encontraron servicios',
                            style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                        ],
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
                              color: Colors.black.withValues(alpha: 0.02),
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
                                    service['imageUrl']!,
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 14,
                                  right: 14,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white.withValues(alpha: 0.9),
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
                                        child: Text(
                                          '${service['category']}', 
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                          const SizedBox(width: 2),
                                          Text(
                                            service['rating']!,
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    service['businessName']!,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    service['reviews']!,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                  ),
                                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Desde', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))), 
                                          Text(
                                            service['price']!,
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0061FF)),
                                          ),
                                        ],
                                      ),
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF0061FF),
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: const Text('Reservar Ya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)), // Traducido
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
      ),
    );
  }
}