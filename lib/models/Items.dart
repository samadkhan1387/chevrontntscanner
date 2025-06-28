import 'dart:ui';

class Item {
  final String name;       // e.g., "Stock In"
  final String type;       // e.g., "Product"
  final Color color;       // Tile background color
  final String imagePath;  // Asset path for image/icon

  Item({
    required this.name,
    required this.type,
    required this.color,
    required this.imagePath,
  });
}
