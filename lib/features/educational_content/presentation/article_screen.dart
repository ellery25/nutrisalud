import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_paths.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../shared/widgets/state_views.dart';
import '../data/content_repository.dart';

/// Full article reader with author attribution and a closing disclaimer.
class ArticleScreen extends ConsumerWidget {
  const ArticleScreen({super.key, required this.articleId});

  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final article = ref.watch(articleByIdProvider(articleId));

    if (article == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.article_outlined,
          title: 'Article not found',
        ),
      );
    }

    final author = article.authorId == null
        ? null
        : ref.watch(specialistByIdProvider(article.authorId!));
    final paragraphs = article.paragraphs;

    ImageProvider? authorPhoto;
    if (author != null) {
      if (author.photoUrl != null) {
        authorPhoto = CachedNetworkImageProvider(author.photoUrl!);
      } else if (author.imageAsset != null) {
        authorPhoto = AssetImage(author.imageAsset!);
      }
    }

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
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
              const SizedBox(width: AppSpacing.sm),
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
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            article.title,
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (author != null) ...[
            const SizedBox(height: AppSpacing.md),
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () => context.push(RoutePaths.specialistFor(author.id)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      backgroundImage: authorPhoto,
                      child: authorPhoto == null
                          ? Icon(
                              Icons.person,
                              size: 18,
                              color: theme.colorScheme.onSurfaceVariant,
                            )
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'By ${author.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            author.kind.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < paragraphs.length; i++)
            if (i == paragraphs.length - 1)
              // Closing disclaimer rendered as a tonal callout.
              Card(
                color: theme.colorScheme.surfaceContainerHighest,
                margin: const EdgeInsets.only(top: AppSpacing.sm),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          paragraphs[i],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(
                  paragraphs[i],
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
              ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
