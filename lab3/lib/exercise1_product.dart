import 'dart:async';

class Product {
  final int id;
  final String name;
  final double price;

  Product(this.id, this.name, this.price);

  @override
  String toString() => "Product(id: $id, name: $name, price: $price)";
}

class ProductRepository {
  final List<Product> _products = [
    Product(1, "Laptop", 1200),
    Product(2, "Phone", 800),
  ];

  final _controller = StreamController<Product>.broadcast();

  Future<List<Product>> getAll() async {
    await Future.delayed(Duration(milliseconds: 500));
    return _products;
  }

  Stream<Product> liveAdded() => _controller.stream;

  void addProduct(Product product) {
    _products.add(product);
    _controller.add(product);
  }
}

Future<void> runExercise1() async {
  final repo = ProductRepository();

  repo.liveAdded().listen((p) {
    print("Live added: $p");
  });

  final products = await repo.getAll();
  print("Initial products: $products");

  repo.addProduct(Product(3, "Tablet", 600));
}