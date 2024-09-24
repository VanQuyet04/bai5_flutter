import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BillPage extends StatelessWidget {
  const BillPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách hóa đơn'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bills').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Không có hóa đơn nào.'));
          }

          final billDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: billDocs.length,
            itemBuilder: (context, index) {
              final bill = billDocs[index];
              final productId = bill['productId'];
              final quantity = bill['quantity'];
              final totalPrice = bill['totalPrice'];
              final customerInfo = bill['customerInfo'];
              final orderDate = bill['orderDate'].toDate();

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('products').doc(productId).get(),
                builder: (context, productSnapshot) {
                  if (productSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text('Đang tải sản phẩm...'));
                  }

                  if (!productSnapshot.hasData || !productSnapshot.data!.exists) {
                    return const ListTile(title: Text('Sản phẩm không tồn tại.'));
                  }

                  final productData = productSnapshot.data!;
                  final productTitle = productData['title'];

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('$quantity'),
                    ),
                    title: Text('Sản phẩm: $productTitle'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Số lượng: $quantity'),
                        Text('Tổng tiền: \$${totalPrice.toStringAsFixed(2)}'),
                        Text('Tên khách hàng: ${customerInfo['name']}'),
                        Text('Địa chỉ: ${customerInfo['address']}'),
                        Text('Ngày đặt hàng: ${orderDate.toString()}'),
                      ],
                    ),
                    isThreeLine: true,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
