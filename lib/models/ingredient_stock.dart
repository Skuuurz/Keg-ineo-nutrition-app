class IngredientStock {
  final String name; // ex: "Riz"
  final int grams; // ex: 120

  const IngredientStock({required this.name, required this.grams});

  @override
  String toString() => '$grams g de $name';
}
