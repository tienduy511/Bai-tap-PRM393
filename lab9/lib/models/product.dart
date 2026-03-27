// Package: dart:convert (có sẵn, không cần cài)
// Mục đích: Đại diện cho 1 sản phẩm, chuyển đổi qua lại với JSON

class Product {
  int id;
  String name;
  double price;

  Product({
    required this.id,
    required this.name,
    required this.price,
  });

  // Chuyển JSON Map → Product object
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id:    json['id']    as int,
      name:  json['name']  as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  // Chuyển Product object → JSON Map (để ghi file)
  Map<String, dynamic> toJson() {
    return {
      'id':    id,
      'name':  name,
      'price': price,
    };
  }
}