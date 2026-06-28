import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/booking_viewmodel.dart';

class ReasonCancelView extends StatefulWidget {
  final String businessName;

  const ReasonCancelView({super.key, required this.businessName});

  @override
  State<ReasonCancelView> createState() => _ReasonCancelViewState();
}

class _ReasonCancelViewState extends State<ReasonCancelView> {
  String? _selectedReason = 'Cambio de planes / horario';
  final TextEditingController _otherReasonController = TextEditingController();

  final List<String> _reasons = [
    'Cambio de planes / horario',
    'Emergencia personal / médica',
    'Clima / Problemas de transporte',
    'Encontré otra opción mejor',
    'Error al reservar la cita',
    'Otro motivo',
  ];

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cancelar Cita',
          style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                children: [
                  const Text(
                    'Motivo de la cancelación',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Por favor, selecciona el motivo por el cual deseas cancelar tu cita en "${widget.businessName}".',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  Column(
                    children: _reasons.map((reason) {
                      final isSelected = _selectedReason == reason;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFF8FAFC) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: RadioListTile<String>(
                          title: Text(
                            reason,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF334155),
                            ),
                          ),
                          value: reason,
                          groupValue: _selectedReason,
                          activeColor: const Color(0xFF4F46E5),
                          controlAffinity: ListTileControlAffinity.trailing,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          onChanged: (value) {
                            setState(() {
                              _selectedReason = value;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),

                  if (_selectedReason == 'Otro motivo') ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _otherReasonController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Escribe detalladamente tu motivo aquí...',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        fillColor: const Color(0xFFF8FAFC),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () {

                  final bookingViewModel = Provider.of<BookingViewModel>(context, listen: false);
                  if (bookingViewModel.barberiaSeleccionada == widget.businessName) {
                    bookingViewModel.seleccionarBarberia(''); // Remueve la tarjeta dinámica
                  }
                  Navigator.popUntil(context, (route) => route.isFirst);


                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cita en "${widget.businessName}" cancelada con éxito.'),
                      backgroundColor: const Color(0xFFEF4444),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  minimumSize: const Size(double.infinity, 54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Enviar Motivo',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}