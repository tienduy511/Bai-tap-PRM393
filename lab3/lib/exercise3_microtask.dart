import 'dart:async';

void runExercise3() {
  print("Start");

  scheduleMicrotask(() {
    print("Microtask executed");
  });

  Future(() {
    print("Future event executed");
  });

  print("End");
}