import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/themes/app_spacing.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/state_views.dart';
import '../../auth/data/auth_repository.dart';
import '../data/community_repository.dart';
import '../domain/post.dart';

/// Compact relative timestamp: now / 5m / 3h / Feb 21.
String _relativeTime(DateTime? time) {
  if (time == null) return '';
  final diff = DateTime.now().difference(time.toLocal());
  if (diff.inMinutes < 1) return 'now';
  if (diff.inHours < 1) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  return DateFormat('MMM d').format(time.toLocal());
}

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  Future<void> _openComposer(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _PostComposer(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(communityFeedProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openComposer(context),
        icon: const Icon(Icons.edit),
        label: const Text('Share'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(communityFeedProvider),
        child: AsyncView<List<CommunityPost>>(
          value: feed,
          onRetry: () => ref.invalidate(communityFeedProvider),
          builder: (posts) {
            if (posts.isEmpty) {
              // Single-child scrollable so pull-to-refresh keeps working.
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: AppSpacing.xxl),
                  EmptyState(
                    icon: Icons.forum_outlined,
                    title: 'No posts yet',
                    message:
                        'Be the first to share something with the community.',
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xxl * 2,
              ),
              itemCount: posts.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, index) => _PostCard(post: posts[index]),
            );
          },
        ),
      ),
    );
  }
}

class _PostCard extends ConsumerWidget {
  const _PostCard({required this.post});

  final CommunityPost post;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final result =
        await ref.read(communityRepositoryProvider).deletePost(post.id);
    result.when(
      ok: (_) {
        ref.invalidate(communityFeedProvider);
        messenger.showSnackBar(const SnackBar(content: Text('Post deleted')));
      },
      err: (message) =>
          messenger.showSnackBar(SnackBar(content: Text(message))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = ref.watch(sessionProvider);
    final isMine = post.authorId == session?.userId;
    final initial =
        post.authorName.isEmpty ? '?' : post.authorName[0].toUpperCase();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(initial)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '@${post.authorUsername}',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _relativeTime(post.createdAt),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                if (isMine)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') _confirmDelete(context, ref);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(post.content, style: theme.textTheme.bodyMedium),
            if (post.photoBytes != null) ...[
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: Image.memory(
                    post.photoBytes!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PostComposer extends ConsumerStatefulWidget {
  const _PostComposer();

  @override
  ConsumerState<_PostComposer> createState() => _PostComposerState();
}

class _PostComposerState extends ConsumerState<_PostComposer> {
  final _controller = TextEditingController();
  Uint8List? _photoBytes;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 1280);
    if (picked == null || !mounted) return;

    final compressed = await FlutterImageCompress.compressWithFile(
      picked.path,
      quality: 70,
      minWidth: 1024,
      minHeight: 1024,
    );
    final bytes = compressed ?? await picked.readAsBytes();
    if (!mounted) return;
    setState(() => _photoBytes = bytes);
  }

  Future<void> _submit() async {
    final session = ref.read(sessionProvider);
    final messenger = ScaffoldMessenger.of(context);
    if (session == null) {
      messenger
          .showSnackBar(const SnackBar(content: Text('You need to sign in.')));
      return;
    }

    setState(() => _sending = true);
    final result = await ref.read(communityRepositoryProvider).createPost(
          content: _controller.text.trim(),
          photoBytes: _photoBytes,
        );
    if (!mounted) return;
    setState(() => _sending = false);

    result.when(
      ok: (_) {
        Navigator.of(context).pop();
        ref.invalidate(communityFeedProvider);
        messenger.showSnackBar(const SnackBar(content: Text('Posted!')));
      },
      err: (message) =>
          messenger.showSnackBar(SnackBar(content: Text(message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSend = _controller.text.trim().isNotEmpty && !_sending;

    return Padding(
      // Keep the sheet above the keyboard.
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share with the community',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 5,
            minLines: 3,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Share a win, a meal, a question…',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_photoBytes != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Image.memory(
                    _photoBytes!,
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: AppSpacing.xs,
                  left: 120 - 32 - AppSpacing.xs,
                  child: IconButton.filledTonal(
                    iconSize: 16,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close),
                    tooltip: 'Remove photo',
                    onPressed: () => setState(() => _photoBytes = null),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image_outlined),
                tooltip: 'Attach a photo',
                onPressed: _sending ? null : _pickImage,
              ),
              const Spacer(),
              FilledButton(
                onPressed: canSend ? _submit : null,
                child: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Post'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
