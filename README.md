# Movable Dock App

The given Flutter code creates a dock app with draggable and interactive icons. It uses Draggable for drag-and-drop functionality, MouseRegion to detect hover states, and DragTarget to reorder dock items. Icons animate when hovered (AnimatedScale), and tooltips show the name of the icons. The dock adjusts to different screen sizes, using a responsive layout (Row or Column).

---

## main.dart

1. Code:
   ```bash
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
                        color: Colors.black,
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
                          scale: isHovered ? 1.2 : 1.0, 
                          duration: const Duration(milliseconds: 200),
                          child: Tooltip(
                            message: item['name']!, 
                            child: Draggable<int>(
                              data: item['icon']!.hashCode, 
                              feedback: Material(
                                color: const Color.fromARGB(0, 252, 251, 251),
                                child: buildIconContainer(item, isHovered, color, isFirst),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.5, 
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

        class Dock extends StatefulWidget {
          const Dock({
            super.key,
            required this.items,
            required this.builder,
            required this.colors,  
          });

          final List<Map<String, dynamic>> items;
          final Widget Function(Map<String, dynamic>, bool isHovered, Color color, bool isFirst) builder;
          final List<Color> colors;

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

          List<Widget> buildDockItems() {
            return _items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item['name']} clicked!')),
                  );
                },
                child: MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      _hoveredIndex = index; 
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      _hoveredIndex = null; 
                    });
                  },
                  child: DragTarget<int>(
                    onWillAccept: (data) => true, 
                    onAccept: (data) {
                      setState(() {
                        final draggedItem = _items.firstWhere((e) => e['icon']!.hashCode == data);
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
        
---

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Video Demo
You can download or view the video directly:
[Download Video](assets/images%20new/2025-01-09.webm)


---

<a><img src="assets/images new/1.png" width="200" height= "300"/></a>
<a><img src="assets/images new/2.png" width="200" height= "300"/></a>
<a><img src="assets/images new/3.png" width="200" height= "300"/></a>
<a><img src="assets/images new/4.png" width="200" height= "300"/></a>
<a><img src="assets/images new/5.png" width="200" height= "300"/></a>

---

## Connect

<a href="https://dev-aryanbhimani.pantheonsite.io/" target="_blank"><img src="assets/portfolio.png" width="50" ></a>
<a href="https://www.linkedin.com/in/aryanbhimani/" target="_blank"><img src="assets/linkedin.png" width="50"></a>
<a href="https://x.com/aryan46022" target="_blank"><img src="assets/twitter.png" width="50"></a> 

For queries or support, feel free to reach out:  
📞 **+91 9408962204**  
📧 **aryan.bhimani.93@email.com**

---