import 'package:flutter/material.dart';

import '../models/journey_entry.dart';
import '../models/prompt.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/decor.dart';
import '../widgets/pill_button.dart';

/// Write (or edit) a personal response to a prompt.
class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key, required this.prompt, this.entry});

  final WhatIfPrompt prompt;
  final JourneyEntry? entry;

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  late WhatIfPrompt _prompt;
  late final TextEditingController _controller;
  late String _initialText;
  bool _saving = false;

  bool get _dirty => _controller.text.trim() != _initialText.trim();

  @override
  void initState() {
    super.initState();
    _prompt = widget.prompt;
    _initialText = widget.entry?.response ?? '';
    _controller = TextEditingController(text: _initialText);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _differentPrompt() {
    final next = AppScope.of(context)
        .repo
        .randomPrompt(excludeId: _prompt.id);
    if (next != null) setState(() => _prompt = next);
  }

  Future<void> _save() async {
    final state = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _saving = true);
    final error = await state.saveEntry(
      prompt: _prompt,
      response: _controller.text,
      existing: widget.entry,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() => _initialText = _controller.text);
    messenger.showSnackBar(
      const SnackBar(content: Text('Saved to My Journey')),
    );
    navigator.pop();
  }

  Future<void> _delete() async {
    final entry = widget.entry;
    if (entry == null) return;
    final state = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await confirmDialog(
      context,
      title: 'Delete this response?',
      message: 'This removes your writing from My Journey.',
      confirmLabel: 'Delete',
    );
    if (!confirmed) return;

    final error = await state.deleteEntry(entry);
    if (!mounted) return;
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    messenger.showSnackBar(const SnackBar(content: Text('Response deleted')));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final category = state.repo.categoryById(_prompt.categoryId);
    final color = AppTheme.categoryColor(_prompt.categoryId);
    final words = wordCount(_controller.text);
    final canSave =
        !_saving && state.journalError == null && _controller.text.trim().isNotEmpty;

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final leave = await confirmDialog(
          context,
          title: 'Discard your draft?',
          message: 'You have unsaved writing. If you leave now it will be lost.',
          confirmLabel: 'Discard',
          cancelLabel: 'Keep writing',
        );
        if (leave) navigator.pop();
      },
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final wide = width >= 900;
              final pad = width >= 700 ? 32.0 : 20.0;

              final promptCard = Material(
                color: color,
                borderRadius: BorderRadius.circular(36),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned(
                      right: -36,
                      top: -36,
                      child: DecorShape(
                        kind: decorForCategory(_prompt.categoryId),
                        color: Colors.white.withValues(alpha: 0.35),
                        size: 150,
                        angle: 0.3,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TagChip(
                            label: category?.name ?? 'Prompt',
                            categoryId: _prompt.categoryId,
                          ),
                          const SizedBox(height: 18),
                          Text(_prompt.text, style: AppTheme.display(26)),
                          if (widget.entry == null) ...[
                            const SizedBox(height: 14),
                            TextButton.icon(
                              onPressed: _differentPrompt,
                              icon: const Icon(Icons.shuffle_rounded, size: 18),
                              label: const Text('Try a different prompt'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );

              final editor = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.journalError != null) ...[
                    MessageBanner(
                      message: '${state.journalError!}\n\nOn Linux desktop '
                          'this usually means SQLite is missing: run '
                          '"sudo apt install libsqlite3-dev" and restart.',
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: _controller,
                    autofocus: widget.entry == null && !wide,
                    minLines: wide ? 14 : 9,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    style: AppTheme.body(17),
                    decoration: InputDecoration(
                      hintText: 'Start writing your answer...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(22),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        '$words ${words == 1 ? 'word' : 'words'}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink.withValues(alpha: 0.6),
                        ),
                      ),
                      const Spacer(),
                      PillButton(
                        label: widget.entry == null ? 'Save' : 'Save changes',
                        icon: Icons.check_rounded,
                        onPressed: canSave ? _save : null,
                      ),
                    ],
                  ),
                ],
              );

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(pad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            RoundIconButton(
                              icon: Icons.arrow_back_rounded,
                              tooltip: 'Back',
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                widget.entry == null
                                    ? 'Create'
                                    : 'Edit response',
                                style: AppTheme.display(28),
                              ),
                            ),
                            if (widget.entry != null)
                              RoundIconButton(
                                icon: Icons.delete_outline_rounded,
                                tooltip: 'Delete response',
                                onPressed: _delete,
                              ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        if (wide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 380, child: promptCard),
                              const SizedBox(width: 32),
                              Expanded(child: editor),
                            ],
                          )
                        else ...[
                          promptCard,
                          const SizedBox(height: 20),
                          editor,
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
