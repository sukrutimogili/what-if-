import 'package:flutter/material.dart';

import '../models/journey_entry.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/navigation.dart';
import 'common.dart';

/// A saved response in My Journey. Tap to edit, menu to delete.
class JourneyEntryCard extends StatelessWidget {
  const JourneyEntryCard({super.key, required this.entry});

  final JourneyEntry entry;

  Future<void> _delete(BuildContext context) async {
    final state = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await confirmDialog(
      context,
      title: 'Delete this response?',
      message: 'This removes your writing from My Journey. '
          'The prompt itself stays available.',
      confirmLabel: 'Delete',
    );
    if (!confirmed) return;
    final error = await state.deleteEntry(entry);
    messenger.showSnackBar(
      SnackBar(content: Text(error ?? 'Response deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final category = state.repo.categoryById(entry.categoryId);
    final color = AppTheme.categoryColor(entry.categoryId);
    final words = wordCount(entry.response);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openCreate(context, entry.toPrompt(), entry: entry),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: color,
              padding: const EdgeInsets.fromLTRB(18, 6, 6, 6),
              child: Row(
                children: [
                  Text(
                    category?.icon ?? '✨',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${category?.name ?? 'Prompt'} · '
                      '${formatDate(entry.updatedAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'More options',
                    icon: const Icon(Icons.more_horiz),
                    onSelected: (value) {
                      if (value == 'edit') {
                        openCreate(context, entry.toPrompt(), entry: entry);
                      } else if (value == 'delete') {
                        _delete(context);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.promptText,
                    style: AppTheme.body(16).copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    entry.response,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.body(15),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$words ${words == 1 ? 'word' : 'words'}',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
