// Widget để rebuild UI khi state thay đổi
import 'package:flutter/widgets.dart';
import 'listenable.dart';

class SimpleConsumer<T extends SimpleListenable> extends StatefulWidget {
  final T listenable;
  final Widget Function(BuildContext context, T listenable) builder;

  const SimpleConsumer({
    Key? key,
    required this.listenable,
    required this.builder,
  }) : super(key: key);

  @override
  State<SimpleConsumer<T>> createState() => _SimpleConsumerState<T>();
}

class _SimpleConsumerState<T extends SimpleListenable>
    extends State<SimpleConsumer<T>> {
  void _listener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_listener);
  }

  @override
  void didUpdateWidget(SimpleConsumer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_listener);
      widget.listenable.addListener(_listener);
    }
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.listenable);
  }
}
