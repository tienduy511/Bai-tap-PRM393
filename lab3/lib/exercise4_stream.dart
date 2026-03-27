Future<void> runExercise4() async {
  Stream<int> numberStream =
  Stream.fromIterable([1, 2, 3, 4, 5]);

  var transformed = numberStream
      .map((n) => n * n)
      .where((n) => n.isEven);

  await for (var value in transformed) {
    print("Stream output: $value");
  }
}