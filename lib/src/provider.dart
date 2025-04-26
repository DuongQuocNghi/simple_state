// Triển khai Provider Pattern
import 'package:flutter/widgets.dart';
import 'store.dart';

/// Cung cấp một Store cho widget tree
class StoreProvider<T> extends InheritedWidget {
  final Store<T> store;  // Đây là instance field tên "store"

  const StoreProvider({
    Key? key,
    required this.store,
    required Widget child,
  }) : super(key: key, child: child);

  /// Lấy StoreProvider từ context
  static StoreProvider<T> of<T>(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<StoreProvider<T>>();
    assert(provider != null, 'No StoreProvider<$T> found in context');
    return provider!;
  }

  /// Lấy Store trực tiếp từ context
  // Đổi tên từ "store" thành "getStore" để tránh xung đột với field "store"
  static Store<T> getStore<T>(BuildContext context) {
    return of<T>(context).store;
  }

  @override
  bool updateShouldNotify(StoreProvider<T> oldWidget) {
    return store != oldWidget.store;
  }
}

/// Widget để cung cấp nhiều Store cùng lúc
class MultiStoreProvider extends StatelessWidget {
  final List<Widget Function(BuildContext, Widget)> providers;
  final Widget child;

  const MultiStoreProvider({
    Key? key,
    required this.providers,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget result = child;

    // Áp dụng các providers từ trong ra ngoài
    for (final provider in providers.reversed) {
      result = provider(context, result);
    }

    return result;
  }
}

// Tiện ích để tìm store trong widget tree
class StoreLocator {
  static Store<T> locate<T>(BuildContext context) {
    return StoreProvider.getStore<T>(context);
  }
}
