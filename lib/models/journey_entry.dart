import 'prompt.dart';

/// A personal response to a prompt, stored in SQLite.
class JourneyEntry {
  const JourneyEntry({
    this.id,
    required this.promptId,
    required this.promptText,
    required this.categoryId,
    required this.response,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String promptId;
  final String promptText;
  final String categoryId;
  final String response;
  final DateTime createdAt;
  final DateTime updatedAt;

  JourneyEntry withId(int newId) {
    return JourneyEntry(
      id: newId,
      promptId: promptId,
      promptText: promptText,
      categoryId: categoryId,
      response: response,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Rebuilds a prompt from the stored copy, so old entries still open even if
  /// the dataset changes later.
  WhatIfPrompt toPrompt() {
    return WhatIfPrompt(id: promptId, categoryId: categoryId, text: promptText);
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'prompt_id': promptId,
      'prompt_text': promptText,
      'category_id': categoryId,
      'response': response,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory JourneyEntry.fromMap(Map<String, Object?> map) {
    return JourneyEntry(
      id: map['id'] as int?,
      promptId: map['prompt_id'] as String,
      promptText: map['prompt_text'] as String,
      categoryId: map['category_id'] as String,
      response: map['response'] as String,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}
