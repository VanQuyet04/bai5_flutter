import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
            // Hiển thị hình ảnh sản phẩm
            Image.network(product.imageUrl, fit: BoxFit.cover),
            const SizedBox(height: 16),

            // Hiển thị tiêu đề sản phẩm
            Text(
              product.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Hiển thị giá sản phẩm
            Text(
              '\$${product.price}',
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
            const SizedBox(height: 16),

            // Thông tin chi tiết sản phẩm
            const Text(
              'Chi tiết sản phẩm:',
              style: TextStyle(fontSize: 18),
            ),
            const Text(
              "Không có mô tả chi tiết cho sản phẩm này.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Button Thêm vào giỏ hàng
            Center(
              child: ElevatedButton(
                onPressed: () => _addToCart(context, product),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm xử lý thêm sản phẩm vào giỏ hàng
  Future<void> _addToCart(BuildContext context, Product product) async {
    try {
      final cartCollection = FirebaseFirestore.instance.collection('cart');

      // Tìm xem sản phẩm đã tồn tại trong giỏ hàng hay chưa
      final querySnapshot = await cartCollection
          .where('productId', isEqualTo: product.id)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Nếu sản phẩm đã có trong giỏ hàng, cập nhật số lượng
        final cartItem = querySnapshot.docs.first;
        final currentQuantity = cartItem['quantity'];

        // Cập nhật số lượng
        await cartCollection.doc(cartItem.id).update({
          'quantity': currentQuantity + 1,
        });

        // Thông báo cập nhật thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm vào giỏ')),
        );
      } else {
        // Nếu sản phẩm chưa có trong giỏ hàng, thêm mới sản phẩm với quantity = 1
        await cartCollection.add({
          'productId': product.id, // Lưu productId
          'quantity': 1,           // Mặc định là 1
        });

        // Thông báo thêm thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm sản phẩm vào giỏ hàng thành công!')),
        );
      }
    } catch (e) {
      // Thông báo lỗi
      print("Lỗi khi thêm vào giỏ hàng: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm vào giỏ hàng thất bại!')),
      );
    }
  }
}
