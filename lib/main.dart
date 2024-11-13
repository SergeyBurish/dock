import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

const double itemSize = 48;
const double itemPadding = 8;
const double halfCellSize = itemSize/2 + itemPadding;

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: itemSize),
                height: itemSize,
                margin: const EdgeInsets.all(itemPadding),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

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
        children: _items.map( (e) => 
          DockItem(
            child: widget.builder(e),
            moveOn: () => print("moveOn" ),
          ),
        ).toList(),
      ),
    );
  }
}

class DockItem extends StatefulWidget {
  final Widget child;
  final void Function() moveOn;
  const DockItem({
    super.key, 
    required this.child, 
    required this.moveOn});

  @override
  State<DockItem> createState() => _DockItemState();
}

class _DockItemState extends State<DockItem> {
  double _xOffset = 0;
  double _yOffset = 0;
  double _padding = halfCellSize;

  @override
  Widget build(BuildContext context) {
    return Draggable(
      maxSimultaneousDrags: 1,
      feedback: widget.child,
      childWhenDragging: AnimatedPadding(
        padding: EdgeInsets.symmetric(horizontal: _padding),
        duration: const Duration(milliseconds: 200),
        child: const SizedBox.shrink(),
      ),
      child: widget.child,
      onDragStarted: () => setState(() {
        _padding = halfCellSize;
        _xOffset = 0;
        _yOffset = 0;
      }),
      onDragUpdate: (details) {
        _xOffset += details.delta.dx;
        _yOffset += details.delta.dy;
        // print("_xOffset ${_xOffset} dx ${details.delta.dx}");
        // print("_yOffset ${_yOffset} dy ${details.delta.dy} _padding ${_padding}");

        if (_yOffset.abs() > 2 && _padding > 0) {
            setState(() => _padding = 0);
        } 
        if (_yOffset.abs() < 20 && _padding < 0.1) {
            setState(() => _padding = halfCellSize);
        }
        if (_xOffset > 2) {
          widget.moveOn(); // move back
        }
      },
    );
  }
}
