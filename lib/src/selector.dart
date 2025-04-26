// Công cụ để lọc các thay đổi state
import 'package:flutter/widgets.dart';
import 'store.dart';

class SimpleSelector<T, R> extends StatefulWidget {
  final Store<T> store;
  final R Function(T state) selector;
  final Widget Function(BuildContext context, R selectedState) builder;
  final bool Function(R previous, R current)? shouldRebuild;

  const SimpleSelector({
    Key? key,
    required this.store,
    required this.selector,
    required this.builder,
    this.shouldRebuild,
  }) : super(key: key);

  @override
  State<SimpleSelector<T, R>> createState() => _SimpleSelectorState<T, R>();
}

class _SimpleSelectorState<T, R> extends State<SimpleSelector<T, R>> {
  late R _selectedState;

  @override
  void initState() {
    super.initState();
    _selectedState = widget.selector(widget.store.state);
    widget.store.addListener(_onStateChanged);
  }

  @override
  void didUpdateWidget(SimpleSelector<T, R> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.store != widget.store) {
      oldWidget.store.removeListener(_onStateChanged);
      _selectedState = widget.selector(widget.store.state);
      widget.store.addListener(_onStateChanged);
    }
  }

  void _onStateChanged() {
    final newSelectedState = widget.selector(widget.store.state);

    final shouldRebuild =
        widget.shouldRebuild != null
            ? widget.shouldRebuild!(_selectedState, newSelectedState)
            : _selectedState != newSelectedState;

    if (shouldRebuild) {
      setState(() {
        _selectedState = newSelectedState;
      });
    }
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _selectedState);
  }
}
