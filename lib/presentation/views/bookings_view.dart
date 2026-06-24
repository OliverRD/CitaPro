import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importante para escuchar el ViewModel
import '../../data/models/booking_model.dart';
import '../viewmodels/booking_viewmodel.dart'; // Ajusta esta ruta si es necesario
import 'confirmation_screen.dart';
import 'reason_cancel_view.dart'; // Asegúrate de importar tu nueva pantalla de motivos

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
              'Mis Citas',
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
                ? Consumer<BookingViewModel>(
                    builder: (context, bookingViewModel, child) {
                      final nuevaSeleccion = bookingViewModel.barberiaSeleccionada;

                      // Clonamos la lista base estática para no duplicar elementos
                      List<Booking> listaMostrar = List.from(_upcomingBookings);

                      // Si el usuario seleccionó un negocio desde HomeView, lo agregamos arriba
                      if (nuevaSeleccion != null && nuevaSeleccion.isNotEmpty) {
                        bool yaExiste = listaMostrar.any((b) => b.businessName == nuevaSeleccion);
                        if (!yaExiste) {
                          listaMostrar.insert(
                            0,
                            Booking(
                              businessName: nuevaSeleccion,
                              serviceName: nuevaSeleccion.contains('Barbería') 
                                  ? 'Servicio de Barbería Personalizado' 
                                  : 'Servicio de Bienestar & Spa',
                              date: 'Hoy', 
                              time: 'Pendiente',
                              status: 'Activo',
                              imageUrl: '',
                            ),
                          );
                        }
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        itemCount: listaMostrar.length,
                        itemBuilder: (context, index) {
                          return _buildBookingCard(listaMostrar[index], bookingViewModel);
                        },
                      );
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

  Widget _buildBookingCard(Booking booking, BookingViewModel viewModel) {
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
                  // 🔥 SE LLAMA A LA FUNCIÓN DEL BOTTOM SHEET DE CANCELACIÓN
                  onPressed: () => _mostrarModalCancelacion(context, booking, viewModel),
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

  // 🔥 MÉTODOS DEL MODAL INFERIOR (BOTTOM SHEET) TOTALMENTE ESTILIZADO
  void _mostrarModalCancelacion(BuildContext context, Booking booking, BookingViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFEF4444),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '¿Cancelar esta cita?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '¿Estás seguro de que deseas cancelar tu cita en "${booking.businessName}"? Esta acción no se puede deshacer.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context), 
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Atrás',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 1. Limpiamos la selección del ViewModel si corresponde a esta cita
                        if (viewModel.barberiaSeleccionada == booking.businessName) {
                          viewModel.seleccionarBarberia(''); 
                        }
                        
                        // 2. Cerramos el modal inferior
                        Navigator.pop(context);

                        // 3. 🔥 NAVEGAMOS DIRECTAMENTE A LA VENTANA DE MOTIVOS QUE ME ENVIASTE
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReasonCancelView(businessName: booking.businessName),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Sí, Cancelar',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}