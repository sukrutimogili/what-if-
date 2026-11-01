/// A category from the `categories` list in what_if_prompts.json.
class PromptCategory {
  const PromptCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });

  final String id;
  final String name;
  final String icon;
  final String description;

  factory PromptCategory.fromJson(Map<String, dynamic> json) {
    return PromptCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: (json['icon'] as String?) ?? '✨',
      description: (json['description'] as String?) ?? '',
    );
  }
}

/// A single prompt from the `prompts` list in what_if_prompts.json.
class WhatIfPrompt {
  const WhatIfPrompt({
    required this.id,
    required this.categoryId,
    required this.text,
  });

  final String id;
  final String categoryId;
  final String text;

  factory WhatIfPrompt.fromJson(Map<String, dynamic> json) {
    return WhatIfPrompt(
      id: json['id'] as String,
      categoryId: json['category'] as String,
      text: json['text'] as String,
    );
  }
}
