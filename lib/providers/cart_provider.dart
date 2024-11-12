import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/products.dart';

class CartProvider with ChangeNotifier {
  // The private list of cart items
  final List<Item> _items = [];

  // Public getter to access the list of cart items
  List<Item> get items => _items;

  // Calculate the total amount (price) of all items in the cart
  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Get the total count of items in the cart (including quantity)
  int get itemCount {
    return _items.fold(0, (count, item) => count + item.quantity);
  }

  // Add a product to the cart
  void addItem(Product product) {
    // Check if the product is already in the cart
    var index = _items
        .indexWhere((item) => item.product.productId == product.productId);

    if (index >= 0) {
      // If the product is already in the cart, increase the quantity
      _items[index].quantity += 1;
    } else {
      // If the product is not in the cart, add a new item
      _items.add(Item(product: product, quantity: 1));
    }

    // Notify listeners about the change in cart
    notifyListeners();
  }

  // Remove a product from the cart by its productId
  void removeItem(String productId) {
    // Remove the item if it exists
    _items.removeWhere((item) => item.product.productId == productId);

    // Notify listeners about the change
    notifyListeners();
  }

  // Update the quantity of a product in the cart
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      // If quantity is 0 or negative, we remove the item from the cart
      removeItem(productId);
    } else {
      // Otherwise, we find the item and update its quantity
      var index =
          _items.indexWhere((item) => item.product.productId == productId);
      if (index >= 0) {
        _items[index].quantity = quantity;
      }
      // Notify listeners about the change
      notifyListeners();
    }
  }

  // Clear all items from the cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
