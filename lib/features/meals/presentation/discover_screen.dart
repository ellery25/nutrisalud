import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/remote_image.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/state_views.dart';
import '../domain/meal.dart';
import 'providers.dart';
import 'widgets/meal_card.dart';

/// Meal discovery: search by name/ingredient, browse categories and
/// featured meals.
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(searchQueryProvider);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Rebuild immediately so the clear button appears/disappears.
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(AppConstants.searchDebounce, () {
      if (!mounted) return;
      ref.read(searchQueryProvider.notifier).state = value.trim();
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final mode = ref.watch(searchModeProvider);
    final searching = query.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            tooltip: 'Favorites',
            icon: const Icon(Icons.favorite_border),
            onPressed: () => context.push(RoutePaths.favorites),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSearchField(),
                  const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
                  SegmentedButton<SearchMode>(
                    segments: const [
                      ButtonSegment(
                        value: SearchMode.name,
                        label: Text('By name'),
                        icon: Icon(Icons.restaurant_menu),
                      ),
                      ButtonSegment(
                        value: SearchMode.ingredient,
                        label: Text('By ingredient'),
                        icon: Icon(Icons.egg_alt_outlined),
                      ),
                    ],
                    selected: {mode},
                    onSelectionChanged: (selection) => ref
                        .read(searchModeProvider.notifier)
                        .state = selection.first,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
          if (searching)
            _buildSearchResults()
          else ...[
            _buildBrowseHeader(),
            _buildBrowseGrid(),
          ],
          const SliverPadding(
            padding: EdgeInsets.only(bottom: AppSpacing.lg),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    final mode = ref.watch(searchModeProvider);
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: mode == SearchMode.name
            ? 'Search meals by name...'
            : 'Search meals by ingredient...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close),
                onPressed: _clearSearch,
              ),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverToBoxAdapter(
        child: AsyncView<List<MealSummary>>(
          value: ref.watch(searchResultsProvider),
          onRetry: () => ref.invalidate(searchResultsProvider),
          builder: (meals) {
            if (meals.isEmpty) {
              return const EmptyState(
                icon: Icons.search_off,
                title: 'No meals found',
                message: 'Try a different search term.',
              );
            }
            return _mealGrid(meals);
          },
        ),
      ),
    );
  }

  Widget _buildBrowseHeader() {
    final categories = ref.watch(categoriesProvider);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(title: 'Categories'),
            SizedBox(
              height: 110,
              child: AsyncView<List<MealCategory>>(
                value: categories,
                onRetry: () => ref.invalidate(categoriesProvider),
                builder: (items) => ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final category = items[index];
                    return _CategoryCard(
                      category: category,
                      selected: category.name == _selectedCategory,
                      onTap: () => setState(() {
                        _selectedCategory =
                            category.name == _selectedCategory
                                ? null
                                : category.name;
                      }),
                    );
                  },
                ),
              ),
            ),
            SectionHeader(
              title: _selectedCategory ?? 'Featured meals',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseGrid() {
    final category = _selectedCategory;
    final value = category == null
        ? ref.watch(featuredMealsProvider)
        : ref.watch(categoryMealsProvider(category));
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverToBoxAdapter(
        child: AsyncView<List<MealSummary>>(
          value: value,
          onRetry: () => category == null
              ? ref.invalidate(featuredMealsProvider)
              : ref.invalidate(categoryMealsProvider(category)),
          builder: (meals) {
            if (meals.isEmpty) {
              return const EmptyState(
                icon: Icons.restaurant,
                title: 'No meals here yet',
                message: 'Try another category.',
              );
            }
            return _mealGrid(meals);
          },
        ),
      ),
    );
  }

  Widget _mealGrid(List<MealSummary> meals) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.72,
      ),
      itemCount: meals.length,
      itemBuilder: (context, index) => MealCard(meal: meals[index]),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final MealCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          width: 96,
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RemoteImage(
                url: category.thumbnailUrl,
                width: 52,
                height: 52,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selected
                          ? scheme.onPrimaryContainer
                          : scheme.onSurfaceVariant,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
