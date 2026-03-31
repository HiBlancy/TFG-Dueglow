import 'package:flutter/material.dart';
import '../widgets/main_toolbar.dart';
import '../services/beauty_api_service.dart';
import '../models/beauty_product.dart';
import 'product_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<BeautyProduct> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;

  // Debounce para no llamar en cada tecla
  Future<void> _onSearch(String query) async {
    if (query.trim().length < 2) {
      setState(() { _results = []; _hasSearched = false; });
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final results = await BeautyApiService.searchProducts(query.trim());
      setState(() {
        _results = results;
        _hasSearched = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al buscar. Revisa tu conexión.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() { _results = []; _hasSearched = false; _errorMessage = null; });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: 'Buscar',
      showDrawer: true,
      showBackButton: false,
      child: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onSubmitted: _onSearch, // busca al pulsar Enter/OK
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Marca o nombre del producto...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              onChanged: (v) => setState(() {}), // para que aparezca/desaparezca la X
            ),
          ),

          // Contenido principal
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.outline)),
          ],
        ),
      );
    }

    if (_hasSearched && _results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text('Sin resultados', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.spa_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'Busca por marca o producto',
              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(height: 8),
            Text(
              'Ej: "L\'Oréal", "hidratante", "champú"',
              style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) => _ProductTile(product: _results[index]),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final BeautyProduct product;
  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: product.imageUrl != null
            ? Image.network(
                product.imageUrl!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _PlaceholderImage(),
              )
            : _PlaceholderImage(),
      ),
      title: Text(
        product.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: product.brand.isNotEmpty
          ? Text(
              product.brand,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            )
          : null,
      onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProductScreen(product: product),
    ),
  );
},
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.spa_outlined, color: Theme.of(context).colorScheme.outline),
    );
  }
}