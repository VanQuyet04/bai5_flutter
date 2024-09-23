import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(product.imageUrl, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Text(product.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('\$${product.price}', style: const TextStyle(fontSize: 20, color: Colors.green)),
            const SizedBox(height: 16),
            const Text('Chi tiết sản phẩm:', style: TextStyle(fontSize: 18)),
            // Thêm mô tả sản phẩm nếu có
          ],
        ),
      ),
    );
  }
}
