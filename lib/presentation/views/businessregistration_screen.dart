import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/views/captcha_screen.dart';
import 'package:flutter_application_1/presentation/views/category_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'captcha_screen.dart';
import 'category_screen.dart';

class BusinessIntroView extends StatelessWidget {
  const BusinessIntroView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      body: SafeArea(
        child: Column(
          children: [
            // Sección superior con fondo azul y imagen
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                children: [
                  SvgPicture.asset(
                    'assets/images/undraw_mobile-application_uc2q.svg',
                    width: 240,
                    height: 200,
                    fit: BoxFit.contain,
                  ),

                  //seccion de texto
                  const SizedBox(height: 20),
                  Text(
                    "Lleva tu negocio al\nsiguiente nivel",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Únete a CitaPro y transforma la manera en que gestionas tus citas y clientes.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),

            // Sección inferior con cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  padding: const EdgeInsets.only(top: 24, bottom: 16),
                  children: const [
                    FeatureCard(
                      title: "Visibilidad total",
                      description:
                          "Llega a miles de clientes potenciales en tu zona.",
                      icon: Icons.people_outline,
                      iconColor: Color(0xFF2563EB),
                      iconBg: Color(0xFFDBEAFE),
                    ),
                    FeatureCard(
                      title: "Gestión Inteligente",
                      description:
                          "Organiza tu agenda 24/7 sin interrupciones.",
                      icon: Icons.calendar_month_outlined,
                      iconColor: Color(0xFF1D4ED8),
                      iconBg: Color(0xFFBFDBFE),
                    ),
                    FeatureCard(
                      title: "Sello de Calidad",
                      description:
                          "Construye confianza con reseñas y perfil profesional.",
                      icon: Icons.verified_outlined,
                      iconColor: Color(0xFF1E40AF),
                      iconBg: Color(0xFFDBEAFE),
                    ),
                  ],
                ),
              ),
            ),

            // Botones
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF2563EB),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "Atrás",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF2563EB),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CategoryScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
                      ),
                      child: Text(
                        "Comenzar registro →",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const FeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}
