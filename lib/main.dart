import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] that builds the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // The Dock widget contains a list of draggable icons.
              Dock(
                items: const [
                  Icons.person,
                  Icons.message,
                  Icons.call,
                  Icons.camera,
                  Icons.photo,
                ],
                builder: (e, isHovered) {
                  // AnimatedScale used to scale the icon when hovered
                  return AnimatedScale(
                    scale: isHovered ? 1.2 : 1.0, // Scale the icon on hover
                    duration: const Duration(milliseconds: 200),
                    child: Draggable<int>(
                      // Unique identifier for each draggable item using its hashCode
                      data: e.hashCode,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Icon(e, size: 40, color: Colors.blue),
                      ),
                      // Placeholder widget when the icon is being dragged
                      childWhenDragging: Container(),
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 48),
                        height: 48,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          // Color is dynamically set based on the item's hashCode
                          color: Colors.primaries[e.hashCode % Colors.primaries.length],
                        ),
                        child: Center(child: Icon(e, color: Colors.white)),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A widget representing a dock that displays and allows interaction with a list of items.
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  // List of [T] items to be displayed in the dock
  final List<T> items;

  // A builder function to create the UI for each item, accepting an item and a hover state
  final Widget Function(T, bool isHovered) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// The state for the [Dock] widget, which manages the items and hover states.
class _DockState<T> extends State<Dock<T>> {
  // List of [T] items, copied from the widget's input
  late List<T> _items = widget.items.toList();

  // Variable to track the index of the currently hovered item
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.asMap().entries.map((entry) {
          final index = entry.key; // Index of the current item
          final item = entry.value; // The item itself

          // Return a GestureDetector for each item that detects hover and tap events
          return GestureDetector(
            onTap: () {
              // Optional: Add any action when an item is tapped
            },
            child: MouseRegion(
              // Detect hover events for scaling effect
              onEnter: (_) {
                setState(() {
                  _hoveredIndex = index; // Set the hovered index when the mouse enters
                });
              },
              onExit: (_) {
                setState(() {
                  _hoveredIndex = null; // Reset the hovered index when the mouse exits
                });
              },
              child: DragTarget<int>(
                // onAccept is triggered when a draggable item is dropped on this target
                onAccept: (data) {
                  setState(() {
                    // Find the dragged item by matching its hashCode
                    final draggedItem = _items.firstWhere((e) => e.hashCode == data);
                    final draggedIndex = _items.indexOf(draggedItem);

                    // Remove the dragged item and insert it at the new position (index)
                    _items.removeAt(draggedIndex);
                    _items.insert(index, draggedItem);
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  // Build the UI for each item with the hover state applied
                  return widget.builder(item, _hoveredIndex == index);
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
