enum Options {
  vegan,
  vegetarian,
  glutenFree,
  halal
}

class Food {
  const Food({required this.name, required this.options});

  final String name;
  final List<Options> options;
}