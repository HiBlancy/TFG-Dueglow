import 'package:flutter/material.dart';
import '../models/beauty_product.dart';

class ProductCard extends StatelessWidget {
  final BeautyProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final VoidCallback? onMove;

  const ProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.onMove,
  }) : super(key: key);

@override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.surface, // ✅ Usar color del tema
      elevation: isDarkMode ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDarkMode 
            ? BorderSide(color: Colors.grey[800]!)
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
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
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
                              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                              size: 30,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.face_rounded,
                        color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
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
                      style: theme.textTheme.titleMedium, // ✅ Usar tema
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (product.brand != null && product.brand!.isNotEmpty)
                      Text(
                        product.brand!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    if (product.categories != null && product.categories!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        product.categories!.take(2).join(', '),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
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
                        color: theme.colorScheme.primary,
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
                    color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
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