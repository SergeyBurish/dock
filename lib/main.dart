import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

const double itemSize = 48;
const double itemGap = 8;
const int maxInt = -1 >>> 1;

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
                height: itemSize,
                width: itemSize,
                margin: const EdgeInsets.all(itemGap),
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
  late List<T> _items = widget.items.toList();
  int _outInd = maxInt;
  int _newInd = maxInt;
  bool _animated = true;

  double _itemPadding (int index) {
    // boundary case
    if (_newInd == _items.length && index == _outInd) {
      return (itemSize + itemGap) * (_items.length - 1);
    }

    // commom cases
    if (_outInd > _newInd && _newInd > -2) {
      return (itemSize + itemGap) * ((index >= _newInd && index < _outInd) ? index + 1 : index);
    }
    return   (itemSize + itemGap) * ((index > _outInd && index <= _newInd) ? index - 1 : index);
  }

  List<T> changedList (int index, int newInd) {
    T current = _items[index];
    _items.removeAt(index);
    _items.insert(newInd, current);
    return _items;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Stack(
        children: [
          for (final (index, item) in _items.indexed)
            AnimatedPadding(
              duration: Duration(milliseconds: _animated ? 200 : 0),
              padding: EdgeInsets.only(left: _itemPadding(index)),
              child: SizedBox(
                child: DockItem(
                  goOut: () {
                    setState(() {
                      _animated = true;
                      _outInd = index;
                      _newInd = maxInt;
                    });
                  },
                  goIn: (delta, animated) {
                    setState(() {
                      _animated = animated;
                      _outInd = delta == 0 ? maxInt : index;

                      if (delta != 0 && index + delta > -2) {
                        _newInd = index + delta;
                      } else {
                        _newInd = maxInt;
                      }
                    });
                  },
                  onCompleted: (delta) { 
                    int newInd = index + delta;
                    if (delta == 0 || newInd < 0 || newInd > _items.length) {
                      setState(() {
                        _animated = false;
                        _outInd = maxInt;
                        _newInd = maxInt;
                      });
                      return;
                    }

                    // boundary case correction
                    if (newInd == _items.length) {
                      newInd = _items.length - 1;
                    }

                    setState(() {
                      _animated = false;
                      _outInd = maxInt;
                      _newInd = maxInt;
                      _items = changedList(index, newInd);
                    });
                  },
                  child: widget.builder(item),
                )
              ),
            )
        ]
      ),
    );
  }
}

class DockItem extends StatefulWidget {
  final Widget child;
  final void Function() goOut;
  final void Function(int delta, bool animated) goIn;
  final void Function(int delta) onCompleted;
  const DockItem({
    super.key, 
    required this.child, 
    required this.goOut, 
    required this.goIn, 
    required this.onCompleted
  });

  @override
  State<DockItem> createState() => _DockItemState();
}

class _DockItemState extends State<DockItem> {
  double _xOffset = 0;
  double _yOffset = 0;

  bool _inDock = true;

  @override
  Widget build(BuildContext context) {
    return Draggable(
      maxSimultaneousDrags: 1,
      feedback: widget.child,
      childWhenDragging: const Padding(
        padding: EdgeInsets.symmetric(horizontal: itemSize/2 + itemGap),
        child: SizedBox.shrink(),
      ),
      child: widget.child,
      onDragStarted: () => setState(() {
        _xOffset = 0;
        _yOffset = 0;
      }),
      onDragUpdate: (details) {
        _xOffset += details.delta.dx;
        _yOffset += details.delta.dy;
        // print("_xOffset ${_xOffset} dx ${details.delta.dx}");
        // print("_yOffset ${_yOffset} dy ${details.delta.dy} _inDock ${_inDock}");

        if (_yOffset.abs() > itemSize && _inDock) {
          widget.goOut();
          setState(() => _inDock = false);
        } 

        if (_yOffset.abs() < itemSize && !_inDock) {
          widget.goIn((_xOffset / itemSize).round(), true);
          setState(() => _inDock = true);
        }

        if (_xOffset.abs() > itemSize && _inDock) {
          widget.goIn((_xOffset / itemSize).round(), true);
        }
      },
      onDraggableCanceled: (velocity, offset) {
        if (!_inDock) {
          widget.goIn(0, false);
          setState(() => _inDock = true);
        } else {
          widget.onCompleted((_xOffset / itemSize).round());
        }
      },
    );
  }
}
