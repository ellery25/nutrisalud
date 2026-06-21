import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/routing/route_paths.dart';
import '../../../core/services/remote_config_service.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/state_views.dart';
import '../data/content_repository.dart';

/// Specialist / source profile with bio, topics and authored articles.
class SpecialistScreen extends ConsumerWidget {
  const SpecialistScreen({super.key, required this.specialistId});

  final String specialistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final specialist = ref.watch(specialistByIdProvider(specialistId));

    if (specialist == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.person_off_outlined,
          title: 'Profile not found',
        ),
      );
    }

    final authoredArticles = ref
        .watch(articlesProvider)
        .where((a) => a.authorId == specialist.id)
        .toList();
    final bookingEnabled = ref
        .watch(remoteConfigProvider)
        .getBool(ConfigFlags.specialistsBookingEnabled);

    ImageProvider? photoProvider;
    if (specialist.photoUrl != null) {
      photoProvider = CachedNetworkImageProvider(specialist.photoUrl!);
    } else if (specialist.imageAsset != null) {
      photoProvider = AssetImage(specialist.imageAsset!);
    }

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                backgroundImage: photoProvider,
                child: photoProvider == null
                    ? Icon(
                        Icons.person,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      specialist.name,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (specialist.verified) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(Icons.verified, color: theme.colorScheme.primary),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
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
                  specialist.kind.label,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                specialist.headline,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const SectionHeader(title: 'About'),
          Text(
            specialist.bio,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: AppSpacing.md),
          const SectionHeader(title: 'Topics'),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final topic in specialist.topics) Chip(label: Text(topic)),
            ],
          ),
          if (specialist.websiteUrl != null) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => launchUrl(
                Uri.parse(specialist.websiteUrl!),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Visit website'),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          const SectionHeader(title: 'Articles'),
          if (authoredArticles.isEmpty)
            Text(
              'No articles yet',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            )
          else
            for (final article in authoredArticles)
              Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  title: Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('${article.readMinutes} min read'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      context.push(RoutePaths.articleFor(article.id)),
                ),
              ),
          if (!bookingEnabled) ...[
            const SizedBox(height: AppSpacing.md),
            Card(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_available,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Consultations coming soon',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Booking with verified professionals is on our '
                            'roadmap.',
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
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
