// product_card.dart
import 'package:flutter/material.dart';
import '../models/beauty_product.dart';

class ProductCard extends StatelessWidget {
  final BeautyProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final VoidCallback? onMove;

  const ProductCard({
    super.key, // Actualizado a sintaxis moderna
    required this.product,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Creamos colores sutiles basados en el texto principal (onSurface)
    // Esto asegura que hereden el tono "ciruela" de fondo automáticamente
    final subtleBg = theme.colorScheme.onSurface.withOpacity(0.05);
    final subtleIcon = theme.colorScheme.onSurface.withOpacity(0.4);
    final subtitleColor = theme.colorScheme.onSurface.withOpacity(0.7);
    final labelColor = theme.colorScheme.onSurface.withOpacity(0.5);
    final borderColor = theme.colorScheme.onSurface.withOpacity(0.1);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.surface, // Ya configurado en themes.dart
      elevation: isDarkMode ? 0 : 2, // En oscuro queda mejor sin sombra, solo con borde
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDarkMode 
            ? BorderSide(color: borderColor)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Imagen del producto
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: subtleBg, // Fondo dinámico que sirve para ambos temas
                ),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              color: subtleIcon,
                              size: 30,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.face_rounded,
                        color: subtleIcon,
                        size: 30,
                      ),
              ),
              const SizedBox(width: 12),
              
              // Información del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleMedium, // Ya usa el color del tema
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (product.brand != null && product.brand!.isNotEmpty)
                      Text(
                        product.brand!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: subtitleColor,
                        ),
                      ),
                    if (product.categories != null && product.categories!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        product.categories!.take(2).join(', '),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: labelColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Acciones
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onMove != null)
                    IconButton(
                      icon: Icon(
                        Icons.swap_horiz,
                        color: theme.colorScheme.primary, // Rosa en oscuro, ciruela en claro
                      ),
                      onPressed: onMove,
                      tooltip: 'Mover a otra lista',
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                      tooltip: 'Eliminar',
                      color: theme.colorScheme.error,
                    ),
                  Icon(
                    Icons.chevron_right,
                    color: subtleIcon,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}