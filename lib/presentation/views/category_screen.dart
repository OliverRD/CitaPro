import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/presentation/viewmodels/categoria_viewmodel.dart';
import 'package:flutter_application_1/domain/usecases/categoria_entity.dart';
import 'package:flutter_application_1/presentation/views/business_form_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late CategoriaViewModel _viewModel;

  // Íconos y colores por categoría
  IconData _getIcon(String nombre) {
    switch (nombre.toLowerCase()) {
      case 'belleza y spa':
        return Icons.spa_outlined;
      case 'salud':
        return Icons.health_and_safety_outlined;
      case 'fitness':
        return Icons.fitness_center_outlined;
      default:
        return Icons.more_horiz;
    }
  }

  Color _getIconColor(String nombre) {
    switch (nombre.toLowerCase()) {
      case 'belleza y spa':
        return const Color(0xFF7C3AED);
      case 'salud':
        return const Color(0xFF16A34A);
      case 'fitness':
        return const Color(0xFFEA580C);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _getIconBg(String nombre) {
    switch (nombre.toLowerCase()) {
      case 'belleza y spa':
        return const Color(0xFFEDE9FE);
      case 'salud':
        return const Color(0xFFDCFCE7);
      case 'fitness':
        return const Color(0xFFFFEDD5);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  @override
  void initState() {
    super.initState();
    _viewModel = CategoriaViewModel();
    _viewModel.loadCategorias();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFEFF6FF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Color(0xFF1E3A8A),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == 1 ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index == 1
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
        body: Consumer<CategoriaViewModel>(
          builder: (context, vm, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cuéntanos sobre tu negocio',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Selecciona tu categoría para que podamos personalizar tu panel de control, servicios y herramientas.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Lista de categorías
                Expanded(
                  child: vm.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2563EB),
                          ),
                        )
                      : vm.error != null
                      ? Center(
                          child: Text(
                            vm.error!,
                            style: GoogleFonts.poppins(color: Colors.redAccent),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: vm.categorias.length,
                          itemBuilder: (context, index) {
                            final cat = vm.categorias[index];
                            final isSelected =
                                vm.selectedCategoria?.idCategoria ==
                                cat.idCategoria;

                            return GestureDetector(
                              onTap: () => vm.selectCategoria(cat),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFFE2E8F0),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF2563EB,
                                      ).withOpacity(0.06),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: _getIconBg(cat.nombreCateg),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Icon(
                                          _getIcon(cat.nombreCateg),
                                          color: _getIconColor(cat.nombreCateg),
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cat.nombreCateg,
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF1E3A8A),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              cat.descripcionCateg,
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: const Color(0xFF64748B),
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFF2563EB),
                                          size: 22,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Banner inferior
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          height: 36,
                          child: Stack(
                            children: List.generate(3, (i) {
                              return Positioned(
                                left: i * 20.0,
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: [
                                      const Color(0xFF7C3AED),
                                      const Color(0xFF2563EB),
                                      const Color(0xFF16A34A),
                                    ][i],
                                    child: Icon(
                                      [Icons.store, Icons.spa, Icons.build][i],
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'UNIDOS POR LA GESTIÓN INTELIGENTE',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF7C3AED),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Más de 5,000 negocios ya han personalizado su experiencia.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Botón Continuar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Consumer<CategoriaViewModel>(
                    builder: (context, vm, _) => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: vm.selectedCategoria != null
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BusinessFormScreen(
                                      idCategoria:
                                          vm.selectedCategoria!.idCategoria,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          disabledBackgroundColor: const Color(0xFFCBD5E1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
                        ),
                        child: Text(
                          'Continuar →',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
