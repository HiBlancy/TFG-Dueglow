import 'package:flutter/material.dart';
import '../widgets/main_toolbar.dart';
import '../models/beauty_product.dart';

class ProductScreen extends StatelessWidget {
  final BeautyProduct product;

  const ProductScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: 'Producto',
      showDrawer: false,
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        height: 220,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => _PlaceholderImage(),
                      )
                    : _PlaceholderImage(),
              ),
            ),

            const SizedBox(height: 24),

            // Marca
            if (product.brand.isNotEmpty)
              Text(
                product.brand.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),

            const SizedBox(height: 6),

            // Nombre
            Text(
              product.name.isNotEmpty ? product.name : 'Sin nombre',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Código de barras
            _InfoRow(
              icon: Icons.qr_code,
              label: 'Código de barras',
              value: product.barcode.isNotEmpty ? product.barcode : '—',
            ),

            const Divider(height: 32),

            // Categorías
            if (product.categories.isNotEmpty) ...[
              Text(
                'Categorías',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: product.categories
                    .take(6) // máximo 6 para no saturar
                    .map((cat) => Chip(
                          label: Text(cat, style: const TextStyle(fontSize: 12)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.spa_outlined,
        size: 72,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}