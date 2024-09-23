import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

import '../models/product.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Product> products = [];
  final ImagePicker _picker = ImagePicker(); // khởi tạo instance của imagepicker
  String? _selectedImagePath; // biến lưu đường dẫn ảnh chọn từ thiết bị

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // kéo dữ liệu về
  }

  // Fetch products từ Firestore
  Future<void> _fetchProducts() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('products').get();
      setState(() {
        products.clear();
        for (var doc in querySnapshot.docs) {
          products.add(Product.fromMap(doc.data(), doc.id));
        }
      });
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  // Chọn ảnh từ gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    // nếu đã chọn ảnh thì set đường dẫn cho biến
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path; // Cập nhật đường dẫn hình ảnh
      });
    }
  }

  // Upload ảnh lên Firebase Storage
  Future<String> _uploadImage(File image) async {
    try {
      String fileName = path.basename(image.path); // Lấy tên file
      final storageRef = FirebaseStorage.instance.ref().child('products/$fileName'); // Tạo reference

      // Upload ảnh lên Firebase Storage
      await storageRef.putFile(image);

      // Lấy URL từ Firebase Storage
      String downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }

  // Hiển thị dialog thêm sản phẩm
  void _showAddProductDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thêm Sản Phẩm'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Tiêu đề'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Giá'),
                  keyboardType: TextInputType.number,
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Chọn Hình Ảnh'),
                ),
                if (_selectedImagePath != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.file(
                      File(_selectedImagePath!),
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      height: 100,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Text('Chưa chọn hình ảnh'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    priceController.text.isNotEmpty &&
                    _selectedImagePath != null) {
                  final imageFile = File(_selectedImagePath!);

                  // Upload ảnh lên Firebase Storage
                  String imageUrl = await _uploadImage(imageFile);

                  if (imageUrl.isNotEmpty) {
                    final newProduct = Product(
                      id: '', // ID sẽ được tạo tự động bởi Firestore
                      title: titleController.text,
                      price: double.parse(priceController.text),
                      imageUrl: imageUrl, // Lưu URL ảnh
                    );

                    // Thêm sản phẩm vào Firestore
                    await FirebaseFirestore.instance.collection('products').add(newProduct.toMap()).then((_) {
                      _fetchProducts(); // Tải lại danh sách sản phẩm
                      Navigator.of(context).pop();
                    }).catchError((e) {
                      print("Lỗi khi thêm sản phẩm: $e");
                    });
                  }
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: products.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : StaggeredGridView.countBuilder(
          crossAxisCount: 2,
          itemCount: products.length,
          itemBuilder: (BuildContext context, int index) {
            final product = products[index];
            return Card(
              child: Column(
                children: [
                  Image.network(product.imageUrl, fit: BoxFit.cover, height: 100), // Hiển thị từ URL
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Text('\$${product.price}', style: const TextStyle(color: Colors.green)),
                ],
              ),
            );
          },
          staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
