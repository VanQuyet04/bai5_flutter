import 'dart:io';
import 'package:bai5_flutter/screens/product_detail_screen.dart';
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
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

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

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    try {
      String fileName = path.basename(image.path);
      final storageRef = FirebaseStorage.instance.ref().child('products/$fileName');
      await storageRef.putFile(image);
      String downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }

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
                  String imageUrl = await _uploadImage(imageFile);

                  if (imageUrl.isNotEmpty) {
                    final newProduct = Product(
                      id: '', // ID sẽ được tạo tự động
                      title: titleController.text,
                      price: double.parse(priceController.text),
                      imageUrl: imageUrl, // Lưu URL hình ảnh
                    );

                    await FirebaseFirestore.instance.collection('products').add(newProduct.toMap()).then((_) {
                      _fetchProducts();
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

  void _showEditProductDialog(Product product) {
    final TextEditingController titleController = TextEditingController(text: product.title);
    final TextEditingController priceController = TextEditingController(text: product.price.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chỉnh Sửa Sản Phẩm'),
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
                    child: Image.network(
                      product.imageUrl,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && priceController.text.isNotEmpty) {
                  String imageUrl;

                  if (_selectedImagePath != null) {
                    final imageFile = File(_selectedImagePath!);
                    imageUrl = await _uploadImage(imageFile);
                  } else {
                    imageUrl = product.imageUrl; // Giữ nguyên URL nếu không chọn ảnh mới
                  }

                  final updatedProduct = Product(
                    id: product.id,
                    title: titleController.text,
                    price: double.parse(priceController.text),
                    imageUrl: imageUrl,
                  );

                  await FirebaseFirestore.instance.collection('products').doc(product.id).update(updatedProduct.toMap()).then((_) {
                    _fetchProducts();
                    Navigator.of(context).pop();
                  }).catchError((e) {
                    print("Lỗi khi sửa sản phẩm: $e");
                  });
                }
              },
              child: const Text('Cập Nhật'),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(String productId) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa Sản Phẩm'),
          content: const Text('Bạn có chắc chắn muốn xóa sản phẩm này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      await FirebaseFirestore.instance.collection('products').doc(productId).delete().then((_) {
        _fetchProducts();
      }).catchError((e) {
        print("Lỗi khi xóa sản phẩm: $e");
      });
    }
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
            :
        StaggeredGridView.countBuilder(
          crossAxisCount: 2,
          itemCount: products.length,
          itemBuilder: (BuildContext context, int index) {
            final product = products[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailPage(product: product),
                  ),
                );
              },
              child: Card(
                child: Column(
                  children: [
                    Image.network(product.imageUrl, fit: BoxFit.cover, height: 100),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Text('\$${product.price}', style: const TextStyle(color: Colors.green)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => _showEditProductDialog(product),
                          child: const Text('Sửa'),
                        ),
                        TextButton(
                          onPressed: () => _deleteProduct(product.id),
                          child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ],
                ),
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
