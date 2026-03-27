// ===============================
// LAB 2 – DART ESSENTIALS
// Covers:
// 1. Basic Syntax & Data Types
// 2. Collections & Operators
// 3. Control Flow & Functions
// 4. Intro to OOP
// 5. Async, Null Safety & Streams
// ===============================

import 'dart:async';

void main() async {
  print("========== EXERCISE 1 ==========");
  exercise1();

  print("\n========== EXERCISE 2 ==========");
  exercise2();

  print("\n========== EXERCISE 3 ==========");
  exercise3();

  print("\n========== EXERCISE 4 ==========");
  exercise4();

  print("\n========== EXERCISE 5 ==========");
  await exercise5();
}

// ===============================
// EXERCISE 1 – Basic Syntax & Data Types
// ===============================
void exercise1() {
  // Declaring variables
  int age = 20;
  double height = 1.75;
  String name = "Alex";
  bool isStudent = true;

  // Printing with string interpolation
  print("Name: $name");
  print("Age: $age");
  print("Height: ${height}m");
  print("Is Student: $isStudent");
}

// ===============================
// EXERCISE 2 – Collections & Operators
// ===============================
void exercise2() {
  // List
  List<int> numbers = [10, 20, 30];
  numbers.add(40);
  numbers.remove(20);

  print("List: $numbers");
  print("First element: ${numbers[0]}");

  // Operators
  int a = 10;
  int b = 5;
  print("a + b = ${a + b}");
  print("a - b = ${a - b}");
  print("a == b : ${a == b}");
  print("a > b && b > 0 : ${a > b && b > 0}");

  // Ternary
  String result = (a > b) ? "a is bigger" : "b is bigger";
  print(result);

  // Set (unique values)
  Set<int> uniqueNumbers = {1, 2, 3, 3};
  uniqueNumbers.add(4);
  uniqueNumbers.remove(1);
  print("Set: $uniqueNumbers");

  // Map
  Map<String, int> scores = {
    "Math": 90,
    "English": 85
  };

  scores["Science"] = 88;
  print("Map: $scores");
  print("Math score: ${scores["Math"]}");
}

// ===============================
// EXERCISE 3 – Control Flow & Functions
// ===============================
void exercise3() {
  int score = 75;

  // if/else
  if (score >= 80) {
    print("Grade: A");
  } else if (score >= 60) {
    print("Grade: B");
  } else {
    print("Grade: C");
  }

  // switch
  String day = "Mon";
  switch (day) {
    case "Mon":
      print("Start of week");
      break;
    case "Fri":
      print("Almost weekend!");
      break;
    default:
      print("Regular day");
  }

  // Loops
  List<String> fruits = ["Apple", "Banana", "Mango"];

  // for loop
  for (int i = 0; i < fruits.length; i++) {
    print("for loop: ${fruits[i]}");
  }

  // for-in loop
  for (var fruit in fruits) {
    print("for-in: $fruit");
  }

  // forEach
  fruits.forEach((fruit) => print("forEach: $fruit"));

  // Functions
  print("Normal function: ${add(5, 3)}");
  print("Arrow function: ${multiply(4, 2)}");
}

// Normal function
int add(int x, int y) {
  return x + y;
}

// Arrow function
int multiply(int x, int y) => x * y;

// ===============================
// EXERCISE 4 – Intro to OOP
// ===============================

// Base class
class Car {
  String brand;

  // Constructor
  Car(this.brand);

  // Named constructor
  Car.electric(this.brand);

  void drive() {
    print("$brand car is driving");
  }
}

// Subclass
class ElectricCar extends Car {
  ElectricCar(String brand) : super.electric(brand);

  @override
  void drive() {
    print("$brand electric car is driving silently ⚡");
  }
}

void exercise4() {
  Car car = Car("Toyota");
  car.drive();

  ElectricCar tesla = ElectricCar("Tesla");
  tesla.drive();
}

// ===============================
// EXERCISE 5 – Async, Future, Null Safety & Streams
// ===============================
Future<void> exercise5() async {
  await loadData();

  // Null safety
  String? nullableName;
  print(nullableName ?? "Default Name"); // ?? operator

  nullableName = "Dart User";
  print(nullableName!.toUpperCase()); // ! operator

  // Stream
  Stream<int> numberStream = Stream.periodic(
      Duration(seconds: 1), (count) => count).take(5);

  print("Listening to stream...");
  await for (var value in numberStream) {
    print("Stream value: $value");
  }
}

// Async function
Future<void> loadData() async {
  print("Loading data...");
  await Future.delayed(Duration(seconds: 2));
  print("Data loaded!");
}