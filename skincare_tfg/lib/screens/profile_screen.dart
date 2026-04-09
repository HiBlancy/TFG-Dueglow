import 'package:flutter/material.dart';
import '../widgets/main_toolbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Map<String, List<Map<String, dynamic>>> _stashData = {
    'Facial': [
      {'name': 'Limpiador', 'icon': Icons.water_drop_outlined},
      {'name': 'Tónico', 'icon': Icons.opacity},
      {'name': 'Sérum', 'icon': Icons.science_outlined},
      {'name': 'Hidratante', 'icon': Icons.spa_outlined},
      {'name': 'Contorno', 'icon': Icons.visibility_outlined},
      {'name': 'Solar', 'icon': Icons.wb_sunny_outlined},
    ],
    'Corporal': [
      {'name': 'Gel', 'icon': Icons.shower_outlined},
      {'name': 'Exfoliante', 'icon': Icons.grain},
      {'name': 'Crema', 'icon': Icons.clean_hands_outlined},
      {'name': 'Manos', 'icon': Icons.front_hand_outlined},
      {'name': 'Desodorante', 'icon': Icons.air},
    ],
    'Capilar': [
      {'name': 'Champú', 'icon': Icons.wash_outlined},
      {'name': 'Acondicionador', 'icon': Icons.water_outlined},
      {'name': 'Mascarilla', 'icon': Icons.face_retouching_natural},
      {'name': 'Aceite', 'icon': Icons.liquor_outlined},
    ],
    'Maquillaje': [
      {'name': 'Base', 'icon': Icons.brush_outlined},
      {'name': 'Corrector', 'icon': Icons.edit_outlined},
      {'name': 'Ojos', 'icon': Icons.remove_red_eye_outlined},
      {'name': 'Labios', 'icon': Icons.face_4_outlined},
    ],
  };

  final Map<String, String> _selectedSubcategories = {};

  @override
  void initState() {
    super.initState();
    _stashData.forEach((key, value) {
      if (value.isNotEmpty) {
        _selectedSubcategories[key] = value.first['name'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tabs = _stashData.keys.toList();

    return DefaultTabController(
      length: tabs.length,
      child: CustomAppBar(
        title: 'Mi Tocador',
        showDrawer: true,
        showBackButton: false,
        child: Column(
          children: [
            // 1. BARRA DE PESTAÑAS (Centrada y limpia)
            Container(
              color: theme.colorScheme.surface,
              child: TabBar(
                isScrollable: true,
                indicatorColor: theme.colorScheme.primary,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                labelStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                tabs: tabs.map((tab) => Tab(text: tab)).toList(),
              ),
            ),
            
            Expanded(
              child: TabBarView(
                children: tabs.map((tab) => _buildTabContent(tab, theme)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String categoryName, ThemeData theme) {
    final subcategories = _stashData[categoryName] ?? [];
    final selectedSub = _selectedSubcategories[categoryName];

    return Column(
      children: [
        // 2. SCROLL DE PELOTITAS (Con el estilo suave de la Home)
        Container(
          height: 120,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: subcategories.length,
            itemBuilder: (context, index) {
              final sub = subcategories[index];
              final isSelected = sub['name'] == selectedSub;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSubcategories[categoryName] = sub['name']),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // Si está seleccionado, usamos el primaryContainer suave
                          color: isSelected 
                              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.6)
                              : theme.colorScheme.surfaceContainerLow,
                          border: Border.all(
                            color: isSelected 
                                ? theme.colorScheme.primary 
                                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          sub['icon'] as IconData,
                          size: 26,
                          color: isSelected 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sub['name'] as String,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // 3. ZONA CENTRAL (Estructura de tarjeta suave y centrada)
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            width: double.infinity,
            decoration: BoxDecoration(
              // Usamos el fondo suave que nos gustó en la Home
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono grande centrado con opacidad
                Icon(
                  subcategories.firstWhere((s) => s['name'] == selectedSub)['icon'] as IconData,
                  size: 80,
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tus productos de $selectedSub',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Aún no has categorizado ningún producto en esta sección.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 32),
                // Botón centrado para invitar a la acción
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Añadir ahora'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}