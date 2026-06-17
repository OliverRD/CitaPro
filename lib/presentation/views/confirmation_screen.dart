import 'package:flutter/material.dart';
import '../../data/models/booking_model.dart'; 
import 'main_navigation_screen.dart'; 
class BookingConfirmationScreen extends StatefulWidget {
  
  final Booking booking;

  const BookingConfirmationScreen({super.key, required this.booking});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    
    final booking = widget.booking;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                '¡Reserva Confirmada!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(height: 8),
              
              const Text(
                'Tu cita ha sido programada con éxito.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    
                    _buildDetailRow(
                      icon: Icons.storefront_outlined,
                      iconColor: const Color(0xFF3B82F6),
                      bgColor: const Color(0xFFEFF6FF),
                      title: 'Establecimiento',
                      value: booking.businessName,
                    ),
                    const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    
                    _buildDetailRow(
                      icon: Icons.business_center_outlined,
                      iconColor: const Color(0xFFA855F7),
                      bgColor: const Color(0xFFFAF5FF),
                      title: 'Servicio',
                      value: booking.serviceName,
                    ),
                    const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailRow(
                            icon: Icons.calendar_today_rounded,
                            iconColor: const Color(0xFF10B981),
                            bgColor: const Color(0xFFECFDF5),
                            title: 'Fecha',
                            value: booking.date, 
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: const Color(0xFFF1F5F9),
                        ),
                        Expanded(
                          child: _buildDetailRow(
                            icon: Icons.access_time_rounded,
                            iconColor: const Color(0xFF3B82F6),
                            bgColor: const Color(0xFFEFF6FF),
                            title: 'Hora',
                            value: booking.time, 
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    // Fila: Estado de Reserva
                    _buildDetailRow(
                      icon: Icons.info_outline_rounded,
                      iconColor: const Color(0xFF10B981),
                      bgColor: const Color(0xFFECFDF5),
                      title: 'Estado de Reserva',
                      value: booking.status, 
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              ElevatedButton(
                onPressed: () {
                  
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home_outlined, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Volver al Inicio',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sincronizando con Google Calendar...'), backgroundColor: Color(0xFF4F46E5)),
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month_outlined, color: Color(0xFF4F46E5)),
                    SizedBox(width: 8),
                    Text(
                      'Añadir al Calendario',
                      style: TextStyle(
                        color: Color(0xFF4F46E5),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Ref: #CITA-9824-MX',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}