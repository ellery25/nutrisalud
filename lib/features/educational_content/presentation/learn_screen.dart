import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_paths.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../shared/widgets/section_header.dart';
import '../data/content_repository.dart';
import '../domain/models.dart';

/// Knowledge hub: specialists directory + digestive-health articles.
class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  ArticleTopic? _selectedTopic; // null = All

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final specialists = ref.watch(specialistsProvider);
    final articles = ref.watch(articlesByTopicProvider(_selectedTopic));

    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _HeroCard(theme: theme),
          const SizedBox(height: AppSpacing.md),
          const SectionHeader(title: 'Specialists & sources'),
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: specialists.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) =>
                  _SpecialistMiniCard(specialist: specialists[index]),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const SectionHeader(title: 'Articles'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _selectedTopic == null,
                    onSelected: (_) => setState(() => _selectedTopic = null),
                  ),
                ),
                for (final topic in ArticleTopic.values)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      label: Text(topic.label),
                      selected: _selectedTopic == topic,
                      onSelected: (_) => setState(() => _selectedTopic = topic),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final article in articles)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _ArticleCard(article: article),
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Educational content — not a substitute for professional '
            'medical advice.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primaryContainer, scheme.secondaryContainer],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Digestive Health Center',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Guides and evidence-based tips for a happier gut.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: scheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Icon(Icons.spa, size: 48, color: scheme.onPrimaryContainer),
        ],
      ),
    );
  }
}

class _SpecialistMiniCard extends StatelessWidget {
  const _SpecialistMiniCard({required this.specialist});

  final SpecialistProfile specialist;

  ImageProvider? _imageProvider() {
    if (specialist.photoUrl != null) {
      return CachedNetworkImageProvider(specialist.photoUrl!);
    }
    if (specialist.imageAsset != null) {
      return AssetImage(specialist.imageAsset!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photo = _imageProvider();
    return SizedBox(
      width: 140,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(RoutePaths.specialistFor(specialist.id)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  backgroundImage: photo,
                  child: photo == null
                      ? Icon(
                          Icons.person,
                          color: theme.colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        specialist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    if (specialist.verified) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  specialist.kind.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArticleCard extends ConsumerWidget {
  const _ArticleCard({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final author = article.authorId == null
        ? null
        : ref.watch(specialistByIdProvider(article.authorId!));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(RoutePaths.articleFor(article.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  article.topic.label,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                article.title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                article.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${article.readMinutes} min read',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  if (author != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '· ${author.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
