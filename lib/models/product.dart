class Product {
  final String id;
  final String title;
  final double price;
  final String imageUrl; // URL của hình ảnh

  Product({required this.id, required this.title, required this.price, required this.imageUrl});

  factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      title: data['title'] ?? '',
      price: (data['price'] as num).toDouble(),
      imageUrl: data['imageUrl'] ?? '', // Lấy URL ảnh từ Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'imageUrl': imageUrl, // Lưu URL ảnh vào Firestore
    };
  }
}
