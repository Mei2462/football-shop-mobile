import 'package:flutter/material.dart';
import 'package:football_shop/models/product_entry.dart';
import 'package:football_shop/widgets/left_drawer.dart';
import 'package:football_shop/widgets/product_entry_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:football_shop/screens/product_detail.dart';

class ProductEntryListPage extends StatefulWidget {
  final bool showOnlyMine;

  const ProductEntryListPage({super.key, this.showOnlyMine = false});

  @override
  State<ProductEntryListPage> createState() => _ProductEntryListPageState();
}

class _ProductEntryListPageState extends State<ProductEntryListPage> {
  late bool _showOnlyMine;

  @override
  void initState() {
    super.initState();
    _showOnlyMine = widget.showOnlyMine;
  }

  Future<List<ProductEntry>> fetchProducts(CookieRequest request) async {
    final response = await request.get("http://localhost:8000/api/products/");

    List<ProductEntry> products = [];
    for (var d in response) {
      if (d != null) {
        products.add(ProductEntry.fromJson(d));
      }
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final loggedInUserId = request.jsonData?['id'];

    return Scaffold(
      appBar: AppBar(
        title: Text(_showOnlyMine ? "My Products" : "All Products"),
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          // Toggle switch
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Show My Products Only"),
                Switch(
                  value: _showOnlyMine,
                  onChanged: (val) {
                    setState(() {
                      _showOnlyMine = val;
                    });
                  },
                ),
              ],
            ),
          ),

          // FutureBuilder for list
          Expanded(
            child: FutureBuilder(
              future: fetchProducts(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                  return const Center(child: Text("No products found."));
                } else {
                  List<ProductEntry> allProducts = snapshot.data;

                  // filter jika toggle aktif
                  List<ProductEntry> filteredProducts = _showOnlyMine
                      ? allProducts
                          .where((p) => p.userId == loggedInUserId)
                          .toList()
                      : allProducts;

                  return ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (_, index) {
                      final product = filteredProducts[index];
                      return ProductEntryCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailPage(product: product),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
