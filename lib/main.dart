import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: DockScreen(),
      ),
    );
  }
}

class DockScreen extends StatelessWidget {
  const DockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Color> iconColors = [
      Colors.blueAccent,
      Colors.pinkAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.yellowAccent,
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 255, 255, 255),
            Color(0xFF23232E), 
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Movable Dock App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            Dock(
              items: const [
                {'icon': Icons.home, 'name': 'Home'},
                {'icon': Icons.person, 'name': 'Profile'},
                {'icon': Icons.message, 'name': 'Messages'},
                {'icon': Icons.call, 'name': 'Calls'},
                {'icon': Icons.camera, 'name': 'Camera'},
                {'icon': Icons.photo, 'name': 'Gallery'},
              ],
              colors: iconColors,
              builder: (item, isHovered, color, isFirst) {
                return AnimatedScale(
                  scale: isHovered ? 1.2 : 1.0, // Scale the icon on hover
                  duration: const Duration(milliseconds: 200),
                  child: Tooltip(
                    message: item['name']!, // Show the name in a tooltip
                    child: Draggable<int>(
                      data: item['icon']!.hashCode, // Unique identifier for drag
                      feedback: Material(
                        color: const Color.fromARGB(0, 252, 251, 251),
                        child: buildIconContainer(item, isHovered, color, isFirst),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5, // Semi-transparent while dragging
                        child: buildIconContainer(item, isHovered, color, isFirst),
                      ),
                      child: buildIconContainer(item, isHovered, color, isFirst),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Widget to build each icon in the Dock
  Widget buildIconContainer(Map<String, dynamic> item, bool isHovered, Color color, bool isFirst) {
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isHovered
              ? [color.withOpacity(0.8), color.withOpacity(0.6)]
              : [Colors.grey[800]!, Colors.grey[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: isHovered
            ? [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
              ]
            : [],
      ),
      child: Center(
        child: Icon(
          item['icon'],
          size: 28,
          color: color,
        ),
      ),
    );
  }
}

/// Dock widget to display and reorder draggable icons responsively
class Dock extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
    required this.builder,
    required this.colors,  // Colors parameter
  });

  final List<Map<String, dynamic>> items;
  final Widget Function(Map<String, dynamic>, bool isHovered, Color color, bool isFirst) builder;
  final List<Color> colors;  // List of colors to assign to each icon

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late final List<Map<String, dynamic>> _items = widget.items.toList();
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine the dock layout based on available width
        final isHorizontal = constraints.maxWidth > 600;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black.withOpacity(0.8),
          ),
          padding: const EdgeInsets.all(8),
          child: isHorizontal
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: buildDockItems(),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: buildDockItems(),
                ),
        );
      },
    );
  }

  /// Build the dock items with dynamic icon colors
  List<Widget> buildDockItems() {
    return _items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return GestureDetector(
        onTap: () {
          // Optional: Action when an item is tapped
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${item['name']} clicked!')),
          );
        },
        child: MouseRegion(
          onEnter: (_) {
            setState(() {
              _hoveredIndex = index; // Set hover state
            });
          },
          onExit: (_) {
            setState(() {
              _hoveredIndex = null; // Reset hover state
            });
          },
          child: DragTarget<int>(
            onWillAccept: (data) => true, // Always accept the drag
            onAccept: (data) {
              setState(() {
                // Reorder items on drag-and-drop
                final draggedItem =
                    _items.firstWhere((e) => e['icon']!.hashCode == data);
                final draggedIndex = _items.indexOf(draggedItem);

                _items.removeAt(draggedIndex);
                _items.insert(index, draggedItem);
              });
            },
            builder: (context, candidateData, rejectedData) {
              return widget.builder(item, _hoveredIndex == index, widget.colors[index % widget.colors.length], index == 0);
            },
          ),
        ),
      );
    }).toList();
  }
}