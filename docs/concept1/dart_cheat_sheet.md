# Dart Cheat Sheet

## Variables & Data Types
```dart
int age = 25;
double price = 10.99;
String name = "Dart";
bool isTrue = true;

// Type inference
var city = "London"; // Inferred as String
final country = "UK"; // Cannot be reassigned
const pi = 3.14;     // Compile-time constant
```

## Functions
```dart
// Standard
int add(int a, int b) {
  return a + b;
}

// Arrow function
int multiply(int a, int b) => a * b;

// Named parameters
void greet({String name = "Guest", int? age}) {
  print("Hello $name, age $age");
}
// Usage: greet(name: "Alice", age: 30);
```

## Control Flow
```dart
// If-else
if (age >= 18) {
  print("Adult");
} else {
  print("Minor");
}

// Loop
for (int i = 0; i < 5; i++) {
  print(i);
}

// Map loop
var list = [1, 2, 3];
for (var item in list) {
  print(item);
}
```

## Null Safety
```dart
String? nullableString; // Can be null
// nullableString = null; // Valid

// Null-aware operators
print(nullableString?.length); // Prints null instead of throwing error
String result = nullableString ?? "Fallback value"; // If null, use fallback
```

## Classes & Objects
```dart
class Person {
  String name;
  int age;

  // Constructor
  Person(this.name, this.age);

  // Named constructor
  Person.guest() : name = "Guest", age = 0;

  void show() => print("$name, $age");
}
```

## Asynchronous Programming
```dart
Future<void> fetchData() async {
  try {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));
    print("Data fetched");
  } catch (e) {
    print("Error: $e");
  }
}
```
