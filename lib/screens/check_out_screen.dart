import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutPage extends StatefulWidget {
  final String productId;
  final int quantity;
  final String productTitle;
  final double productPrice;

  const CheckoutPage({
    super.key,
    required this.productId,
    required this.quantity,
    required this.productTitle,
    required this.productPrice,
  });

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  Future<void> _submitOrder() async {
    if (_formKey.currentState!.validate()) {
      // Lưu thông tin hóa đơn vào Firestore
      await FirebaseFirestore.instance.collection('bills').add({
        'productId': widget.productId,
        'quantity': widget.quantity,
        'totalPrice': widget.productPrice * widget.quantity,
        'customerInfo': {
          'name': _nameController.text,
          'address': _addressController.text,
        },
        'orderDate': Timestamp.now(),
      });

      // Hiển thị thông báo thành công và quay lại trang trước
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đơn hàng đã được thanh toán thành công!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận thanh toán'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sản phẩm: ${widget.productTitle}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Số lượng: ${widget.quantity}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Tổng tiền: \$${widget.productPrice * widget.quantity}', style: const TextStyle(fontSize: 18, color: Colors.green)),
              const SizedBox(height: 16),
              const Text('Thông tin người mua:', style: TextStyle(fontSize: 18)),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên người mua'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Địa chỉ'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitOrder,
                  child: const Text('Thanh toán'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
