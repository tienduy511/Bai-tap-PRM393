import 'exercise1_product.dart';
import 'exercise2_user_json.dart';
import 'exercise3_microtask.dart';
import 'exercise4_stream.dart';
import 'exercise5_factory.dart';

Future<void> main() async {
  print("========== EXERCISE 1 ==========");
  await runExercise1();

  print("\n========== EXERCISE 2 ==========");
  await runExercise2();

  print("\n========== EXERCISE 3 ==========");
  runExercise3();

  await Future.delayed(Duration(seconds: 1));

  print("\n========== EXERCISE 4 ==========");
  await runExercise4();

  print("\n========== EXERCISE 5 ==========");
  runExercise5();
}