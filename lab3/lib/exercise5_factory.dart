class Settings {
  static final Settings _instance = Settings._internal();

  Settings._internal();

  factory Settings() {
    return _instance;
  }
}

void runExercise5() {
  var a = Settings();
  var b = Settings();

  print("Are both instances identical? ${identical(a, b)}");
}