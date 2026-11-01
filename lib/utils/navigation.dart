import 'package:flutter/material.dart';

import '../models/journey_entry.dart';
import '../models/prompt.dart';
import '../screens/category_screen.dart';
import '../screens/create_screen.dart';
import '../screens/prompt_detail_screen.dart';

void openPrompt(BuildContext context, WhatIfPrompt prompt) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => PromptDetailScreen(prompt: prompt)),
  );
}

void openCreate(
  BuildContext context,
  WhatIfPrompt prompt, {
  JourneyEntry? entry,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => CreateScreen(prompt: prompt, entry: entry),
    ),
  );
}

void openCategory(BuildContext context, PromptCategory category) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => CategoryScreen(category: category),
    ),
  );
}
