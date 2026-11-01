import 'package:flutter/material.dart';

import '../models/prompt.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/navigation.dart';
import 'decor.dart';

/// Coloured category card. Needs a bounded height (fixed by its parent).
class CategoryTile extends StatelessWidget {
  const CategoryTile({super.key, required this.category});

  final PromptCategory category;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final color = AppTheme.categoryColor(category.id);
    final count = state.repo.countFor(category.id);

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(32),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openCategory(context, category),
        child: Stack(
          children: [
            Positioned(
              right: -34,
              bottom: -34,
              child: DecorShape(
                kind: decorForCategory(category.id),
                color: Colors.white.withValues(alpha: 0.35),
                size: 130,
                angle: 0.4,
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            category.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward, size: 22),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.display(20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.body(13.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$count prompts',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
