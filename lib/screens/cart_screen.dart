import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/utils.dart';
import 'check_out_screen.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng của bạn'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cart').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Giỏ hàng của bạn đang trống.'));
          }

          final cartItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = cartItems[index];
              final productId = cartItem['productId'];
              final quantity = cartItem['quantity'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('products')
                    .doc(productId)
                    .get(),
                builder: (context, productSnapshot) {
                  if (productSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ListTile(title: Text('Đang tải sản phẩm...'));
                  }

                  if (!productSnapshot.hasData ||
                      !productSnapshot.data!.exists) {
                    return const ListTile(
                        title: Text('Không tìm thấy sản phẩm.'));
                  }

                  final productData = productSnapshot.data!;
                  final productTitle = productData['title'];
                  final productPrice = productData['price'];
                  final productImageUrl = productData['imageUrl'];

                  return ListTile(
                    leading: Image.network(productImageUrl,
                        width: 50, fit: BoxFit.cover),
                    title: Text(productTitle),
                    subtitle: Text(
                        'Số lượng: $quantity\nGiá: \$${productPrice * quantity}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Hiện hộp thoại xác nhận xóa
                        _showDeleteConfirmationDialog(context, cartItem.id);
                      },
                    ),
                    onTap: () {
                      // Điều hướng sang màn hình thanh toán và truyền thông tin sản phẩm
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutPage(
                            productId: productId,
                            quantity: quantity,
                            productTitle: productTitle,
                            productPrice: productPrice,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Hàm hiển thị hộp thoại xác nhận xóa
  void _showDeleteConfirmationDialog(BuildContext context, String cartItemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text(
              'Bạn có chắc chắn muốn xóa sản phẩm này khỏi giỏ hàng?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
            ),
            TextButton(
              child: const Text('Xóa'),
              onPressed: () async {
                // Xóa sản phẩm khỏi giỏ hàng
                await FirebaseFirestore.instance
                    .collection('cart')
                    .doc(cartItemId)
                    .delete();
                Navigator.of(context).pop(); // Đóng hộp thoại
                showCustomSnackBar(
                    context, 'Đã xóa sản phẩm khỏi giỏ hàng!', Colors.green);
              },
            ),
          ],
        );
      },
    );
  }
}
