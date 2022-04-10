enum Options {
  vegan,
  vegetarian,
  gluten,
  halal,
  dairy,
  soy
}

class Food {
  const Food({required this.name, required this.options});

  final String name;
  final List<Options> options;
}