import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/product_category_catalog.dart';
import '../models/beauty_product.dart';
import '../services/product_service.dart';
import 'product_screen.dart';
import '../widgets/main_toolbar.dart';
import '../widgets/vanity_product_card.dart';
import '../l10n/app_localizations.dart';
import '../widgets/tutorial_target.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProductService _productService = ProductService();
  final Map<String, String> _selectedSubcategories = {};
  List<BeautyProduct> _products = [];
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    for (final section in ProductCategoryCatalog.sections) {
      if (section.options.isNotEmpty) {
        _selectedSubcategories[section.id] = section.options.first.id;
      }
    }
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoadingProducts = true);
    final paginated = await _productService.getProducts(
      listType: 'have',
      limit: 200,
    );
    if (!mounted) return;
    setState(() {
      _products = paginated?.products ?? [];
      _isLoadingProducts = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final tabs = ProductCategoryCatalog.sections;

    return DefaultTabController(
      length: tabs.length,
      child: CustomAppBar(
        title: l10n.vanity,
        showDrawer: true,
        showBackButton: false,
        child: Column(
          children: [
            _buildTabBar(theme, tabs, isDark),

            Expanded(
              child: TabBarView(
                children: tabs
                    .map((tab) => _buildTabContent(tab.id, theme, isDark))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(
    ThemeData theme,
    List<CategorySection> tabs,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return TutorialTarget(
      id: 'vanity_tabs',
      child: Container(
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              indicatorColor: theme.colorScheme.primary,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 3,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.5,
              ),
              labelStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tabs: tabs
                  .map(
                    (tab) => Tab(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(tab.localizedName(l10n)),
                      ),
                    ),
                  )
                  .toList(),
            ),
            Divider(
              height: 1,
              color: isDark
                  ? theme.colorScheme.outline.withValues(alpha: 0.1)
                  : theme.colorScheme.outline.withValues(alpha: 0.08),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String categoryName, ThemeData theme, bool isDark) {
    final section = ProductCategoryCatalog.getSection(categoryName);
    final subcategories = section?.options ?? [];
    final selectedSub = _selectedSubcategories[categoryName];
    final filteredProducts = _filterProducts(categoryName, selectedSub);

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSubcategorySelector(
            categoryName,
            subcategories,
            selectedSub,
            theme,
            isDark,
          ),

          if (_isLoadingProducts)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Lottie.asset(
                    Theme.of(context).brightness == Brightness.dark
                        ? 'assets/loadingGray.json'
                        : 'assets/loading.json',
                    width: 80,
                    height: 80,
                    repeat: true,
                  ),
                ),
              ),
            )
          else if (filteredProducts.isEmpty)
            _buildEmptyState(selectedSub, subcategories, theme, isDark)
          else
            _buildProductsList(filteredProducts),
        ],
      ),
    );
  }

  List<BeautyProduct> _filterProducts(String sectionId, String? subcategoryId) {
    if (subcategoryId == null) return const [];
    return _products.where((product) {
      final categories = product.categories;
      if (categories == null || categories.isEmpty) return false;
      return ProductCategoryCatalog.matchesSubcategory(
        categories: categories,
        sectionId: sectionId,
        subcategoryId: subcategoryId,
      );
    }).toList();
  }

  Widget _buildSubcategorySelector(
    String categoryName,
    List<CategoryOption> subcategories,
    String? selectedSub,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 520;

          final cards = subcategories.map((sub) {
            final isSelected = sub.id == selectedSub;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedSubcategories[categoryName] = sub.id);
                },
                child: _buildSubcategoryCard(sub, isSelected, theme, isDark),
              ),
            );
          }).toList();

          if (isSmallScreen) {
            return SizedBox(
              height: 132,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(mainAxisSize: MainAxisSize.min, children: cards),
              ),
            );
          }

          return Center(
            child: Wrap(alignment: WrapAlignment.center, children: cards),
          );
        },
      ),
    );
  }

  Widget _buildSubcategoryCard(
    CategoryOption sub,
    bool isSelected,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : isDark
                ? theme.colorScheme.primary.withValues(alpha: 0.08)
                : theme.colorScheme.primary.withValues(alpha: 0.05),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : isDark
                  ? theme.colorScheme.outline.withValues(alpha: 0.2)
                  : theme.colorScheme.outline.withValues(alpha: 0.15),
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            sub.icon,
            size: 28,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 10),

        SizedBox(
          width: 92,
          child: Text(
            sub.localizedName(AppLocalizations.of(context)!),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    String? selectedSub,
    List<CategoryOption> subcategories,
    ThemeData theme,
    bool isDark,
  ) {
    if (selectedSub == null || subcategories.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedItem = subcategories.firstWhere(
      (s) => s.id == selectedSub,
      orElse: () => subcategories.first,
    );

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark
            ? theme.colorScheme.primary.withValues(alpha: 0.08)
            : theme.colorScheme.primary.withValues(alpha: 0.06),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : theme.colorScheme.primary.withValues(alpha: 0.12),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
            ),
            child: Icon(
              selectedItem.icon,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 28),

          Text(
            AppLocalizations.of(context)!.yourProductsOf(
              selectedItem.localizedName(AppLocalizations.of(context)!),
            ),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            AppLocalizations.of(context)!.noCategorizedProductsSection,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<BeautyProduct> products) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return VanityProductCard(
          product: product,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductScreen(product: product),
              ),
            ).then((_) => _loadProducts());
          },
        );
      },
    );
  }
}
