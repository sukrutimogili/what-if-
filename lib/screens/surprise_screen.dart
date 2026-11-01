import 'package:flutter/material.dart';

import '../models/prompt.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/navigation.dart';
import '../utils/responsive.dart';
import '../widgets/common.dart';
import '../widgets/decor.dart';
import '../widgets/pill_button.dart';

/// Random prompt generator with the "Surprise me" interaction.
class SurpriseScreen extends StatefulWidget {
  const SurpriseScreen({super.key});

  @override
  State<SurpriseScreen> createState() => _SurpriseScreenState();
}

class _SurpriseScreenState extends State<SurpriseScreen> {
  WhatIfPrompt? _current;
  final List<WhatIfPrompt> _history = <WhatIfPrompt>[];
  String? _categoryId;
  double _turns = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _current ??= AppScope.of(context).repo.randomPrompt();
  }

  void _shuffle() {
    final repo = AppScope.of(context).repo;
    final next = repo.randomPrompt(
      categoryId: _categoryId,
      excludeId: _current?.id,
    );
    if (next == null) return;
    setState(() {
      final current = _current;
      if (current != null) {
        _history.add(current);
        if (_history.length > 50) _history.removeAt(0);
      }
      _current = next;
      _turns += 0.2;
    });
  }

  void _back() {
    if (_history.isEmpty) return;
    setState(() {
      _current = _history.removeLast();
      _turns -= 0.2;
    });
  }

  void _setCategory(String? id) {
    _categoryId = id;
    _shuffle();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final prompt = _current;

    if (prompt == null) {
      return const EmptyState(
        icon: Icons.auto_awesome,
        title: 'No prompts available',
        message: 'The dataset has no prompts to choose from.',
      );
    }

    final color = AppTheme.categoryColor(prompt.categoryId);
    final category = state.repo.categoryById(prompt.categoryId);
    final saved = state.isSaved(prompt.id);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final side = Responsive.sidePadding(width);
        final big = width >= 700;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(side, 28, side, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Headline(
                    bold: 'Surprise me',
                    italic: 'one question at a time',
                    size: big ? 52 : 38,
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterPill(
                        label: 'Anything',
                        selected: _categoryId == null,
                        onTap: () => _setCategory(null),
                      ),
                      for (final c in state.repo.categories)
                        FilterPill(
                          label: '${c.icon} ${c.name}',
                          selected: _categoryId == c.id,
                          onTap: () => _setCategory(c.id),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Material(
                    color: color,
                    borderRadius: BorderRadius.circular(40),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => openPrompt(context, prompt),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: big ? 360 : 300),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -50,
                              top: -50,
                              child: AnimatedRotation(
                                turns: _turns,
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeOutBack,
                                child: DecorShape(
                                  kind: DecorKind.flower,
                                  color: Colors.white.withValues(alpha: 0.35),
                                  size: 210,
                                ),
                              ),
                            ),
                            Positioned(
                              left: -40,
                              bottom: -60,
                              child: AnimatedRotation(
                                turns: -_turns,
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeOutBack,
                                child: DecorShape(
                                  kind: DecorKind.squircle,
                                  color: Colors.white.withValues(alpha: 0.28),
                                  size: 170,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(big ? 36 : 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TagChip(
                                    label: '${category?.icon ?? '✨'}  '
                                        '${category?.name ?? 'Prompt'}',
                                  ),
                                  const SizedBox(height: 22),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 350),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0, 0.08),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Align(
                                      key: ValueKey<String>(prompt.id),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        prompt.text,
                                        style: AppTheme.display(big ? 40 : 28),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      PillButton(
                        label: 'Surprise me',
                        icon: Icons.auto_awesome,
                        onPressed: _shuffle,
                      ),
                      PillButton(
                        label: saved ? 'Saved' : 'Save',
                        icon: saved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        style: PillStyle.light,
                        onPressed: () => state.toggleSaved(prompt.id),
                      ),
                      PillButton(
                        label: 'Write',
                        icon: Icons.edit_outlined,
                        style: PillStyle.outline,
                        onPressed: () => openCreate(
                          context,
                          prompt,
                          entry: state.entryFor(prompt.id),
                        ),
                      ),
                      if (_history.isNotEmpty)
                        RoundIconButton(
                          icon: Icons.undo_rounded,
                          tooltip: 'Previous prompt',
                          onPressed: _back,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
