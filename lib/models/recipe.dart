// lib/models/recipe.dart

class Recipe {
  final String title;
  final List<String> ingredients;
  final List<String> steps;
  final String? nutritionalInfo;
  final String? preparationTime;

  Recipe({
    required this.title,
    required this.ingredients,
    required this.steps,
    this.nutritionalInfo,
    this.preparationTime,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['title'] as String? ?? 'Recette sans titre',
      ingredients: (json['ingredients'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      steps: (json['steps'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      nutritionalInfo: json['nutritional_info'] as String?,
      preparationTime: json['preparation_time'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'ingredients': ingredients,
    'steps': steps,
    if (nutritionalInfo != null) 'nutritional_info': nutritionalInfo,
    if (preparationTime != null) 'preparation_time': preparationTime,
  };
}
