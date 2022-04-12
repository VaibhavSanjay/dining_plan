enum Options {
  vegan,
  vegetarian,
  gluten,
  halal,
  dairy,
  soy
}

class Food {
  const Food({required this.name, required this.options, this.starred = false});

  final String name;
  final List<Options> options;
  final bool starred;

  static bitsToOptionList(int bits) {
    List<Options> ret = [];
    for (int i = 0; i < Options.values.length; i++) {
      if (bits % 2 == 1) ret.add(Options.values[i]);
      bits >>= 1;
    }
    return ret;
  }
}