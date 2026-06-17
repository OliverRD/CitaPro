import 'package:flutter/material.dart';
import '../../data/models/booking_model.dart';
import 'confirmation_screen.dart';

class BookingsView extends StatefulWidget {
  const BookingsView({super.key});

  @override
  State<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<BookingsView> {
  String _activeTab = 'Próximos';

  final List<Booking> _upcomingBookings = [
    Booking(
      businessName: 'Barbería El Maestro',
      serviceName: 'Corte de Cabello Premium',
      date: '24 Oct 2023',
      time: '10:00 AM',
      status: 'Activo',
      imageUrl: '',
    ),
    Booking(
      businessName: 'Zen Spa Wellness',
      serviceName: 'Masaje de Tejido Profundo',
      date: '28 Oct 2023',
      time: '2:30 PM',
      status: 'Activo',
      imageUrl: '',
    ),
  ];

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0),
            child: Text(
              'Mis Trabajos',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
            child: Text(
              'Gestiona tus citas próximas y tu historial de turnos.',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildTabButton('Próximos')),
                  Expanded(child: _buildTabButton('Pasados')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _activeTab == 'Próximos'
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    itemCount: _upcomingBookings.length,
                    itemBuilder: (context, index) {
                      return _buildBookingCard(_upcomingBookings[index]);
                    },
                  )
                : const Center(
                    child: Text('No hay reservas pasadas.', style: TextStyle(color: Color(0xFF64748B))),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabName) {
    final isSelected = _activeTab == tabName;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = tabName),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            tabName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 56,
                  height: 56,
                  color: const Color(0xFFE2E8F0),
                  child: const Icon(Icons.storefront, color: Color(0xFF94A3B8), size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.businessName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.content_cut, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            booking.serviceName,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      booking.status,
                      style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Color(0xFFE0F2FE), shape: BoxShape.circle),
                        child: const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF0369A1)),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fecha', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                          Text(booking.date, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Color(0xFFE0F2FE), shape: BoxShape.circle),
                        child: const Icon(Icons.access_time, size: 16, color: Color(0xFF0369A1)),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hora', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                          Text(booking.time, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingConfirmationScreen(booking: booking),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today, size: 14),
                  label: const Text('Confirmar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0061FF),
                    side: const BorderSide(color: Color(0xFF0061FF)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.close, size: 14),
                  label: const Text('Cancelar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFFEE2E2)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}