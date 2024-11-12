import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Import carousel_slider
import '../models/products.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  ProductDetailScreen({required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentPage = 0; // Track the current image page
  static const int _itemsPerPage = 5;
  List<Product> _relatedProducts = [];

  Future<void> fetchRelatedProducts(String brand) async {
    final response = await http
        .get(Uri.parse('https://api.jsonbin.io/v3/b/67314cf0ad19ca34f8c7b830'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _relatedProducts = (data['record'] as List)
            .map((json) => Product.fromJson(json))
            .where((item) =>
                item.brand == widget.product.brand &&
                item.name != widget.product.name)
            .toList();
      });
    } else {
      throw Exception('Failed to load related products');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRelatedProducts(widget.product.brand);
  }

  List<Product> getCurrentPageProducts() {
    int start = _currentPage * _itemsPerPage;
    int end = start + _itemsPerPage;
    return _relatedProducts.sublist(
        start, end < _relatedProducts.length ? end : _relatedProducts.length);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Carousel
            Column(
              children: [
                CarouselSlider.builder(
                  itemCount: widget.product.images.length,
                  itemBuilder: (context, index, realIndex) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/images/loading.gif',
                        image: widget.product.images[index],
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: 250,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: false,
                    initialPage: 0,
                    aspectRatio: 2.0,
                    viewportFraction: 1.0,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                  ),
                ),
                SizedBox(height: 8),

                // Dots indicator for image count
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.product.images.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _currentPage == index ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Product Name and Price
            Text(
              widget.product.name,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Text(
              '\$${widget.product.price.toStringAsFixed(2)} ${widget.product.currency}',
              style: TextStyle(fontSize: 22, color: Colors.green),
            ),
            SizedBox(height: 10),

            // Rating
            Row(
              children: [
                buildStarRating(widget.product.ratingAverage),
                SizedBox(width: 8),
                Text(
                  '${widget.product.ratingAverage} / 5.0 (${widget.product.totalReviews} reviews)',
                  style: TextStyle(fontSize: 16, color: Colors.amber),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Product Details
            Text(
              'Sẵn hàng: ${widget.product.availability}',
              style: TextStyle(
                fontSize: 16,
                color: widget.product.availability == 'Còn hàng'
                    ? Colors.green
                    : widget.product.availability == 'Tạm Hết'
                        ? Colors.red
                        : Colors.blueGrey,
              ),
            ),

            Text(
              'Thương hiệu: ${widget.product.brand}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Description
            Text(
              'Mô tả:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(widget.product.description),
            SizedBox(height: 16),

            // Color Options
            if (widget.product.colorOptions.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Màu sắc:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: widget.product.colorOptions
                        .map((color) => Chip(label: Text(color)))
                        .toList(),
                  ),
                ],
              ),
            SizedBox(height: 16),

            // Size and Material
            Text(
              'Kích Thước (L x W x H): ${widget.product.size['length']} x ${widget.product.size['width']} x ${widget.product.size['height']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Vật liệu: ${widget.product.material}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Features
            if (widget.product.features.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đặc trưng:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...widget.product.features.map(
                    (feature) => Text('- $feature'),
                  ),
                ],
              ),
            SizedBox(height: 20),

            // Add to Cart Button (sticky footer)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    cart.addItem(widget.product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('${widget.product.name} added to cart')),
                    );
                  },
                  icon: Icon(Icons.add_shopping_cart),
                  label: Text('Thêm Vào Giỏ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Button color
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Related Products Section (Carousel)
            if (_relatedProducts.isNotEmpty) ...[
              Text(
                'Sản phẩm liên quan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              // Carousel Slider for related products
              CarouselSlider.builder(
                itemCount: _relatedProducts.length,
                itemBuilder: (context, index, realIndex) {
                  var relatedProduct = _relatedProducts[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailScreen(product: relatedProduct),
                      ),
                    ),
                    child: Container(
                      width: 180,
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/images/loading.gif',
                              image: relatedProduct.images[0],
                              height: 120,
                              width: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            relatedProduct.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            '\$${relatedProduct.price.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 14, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  height: 250,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  initialPage: 0,
                  aspectRatio: 2.0,
                  viewportFraction: 0.6,
                ),
              ),
            ] else
              Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget buildStarRating(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.toInt();
    double halfStar = rating - fullStars;

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(Icon(Icons.star, color: Colors.amber));
      } else if (halfStar > 0 && i == fullStars) {
        stars.add(Icon(Icons.star_half, color: Colors.amber));
      } else {
        stars.add(Icon(Icons.star_border, color: Colors.amber));
      }
    }
    return Row(children: stars);
  }
}
