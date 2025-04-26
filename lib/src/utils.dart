// Cung cấp các tiện ích hữu ích
import 'package:flutter/widgets.dart';
import 'store.dart';
import 'provider.dart';

// Tiện ích để tạo builders sử dụng store dễ dàng hơn
class StoreBuilder<T> extends StatelessWidget {
  final Widget Function(BuildContext context, T state) builder;
  final Store<T>? store;

  const StoreBuilder({Key? key, required this.builder, this.store})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storeToUse = store ?? StoreProvider.getStore<T>(context);

    return ListenableBuilder(
      listenable: storeToUse,
      builder: (context, _) {
        return builder(context, storeToUse.state);
      },
    );
  }
}

// Widget tự động lắng nghe nhiều store cùng lúc
class MultiStoreBuilder extends StatefulWidget {
  final List<Store> stores;
  final Widget Function(BuildContext context) builder;

  const MultiStoreBuilder({
    Key? key,
    required this.stores,
    required this.builder,
  }) : super(key: key);

  @override
  State<MultiStoreBuilder> createState() => _MultiStoreBuilderState();
}

class _MultiStoreBuilderState extends State<MultiStoreBuilder> {
  void _listener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    for (final store in widget.stores) {
      store.addListener(_listener);
    }
  }

  @override
  void didUpdateWidget(MultiStoreBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Xử lý thay đổi danh sách stores
    for (final oldStore in oldWidget.stores) {
      if (!widget.stores.contains(oldStore)) {
        oldStore.removeListener(_listener);
      }
    }

    for (final newStore in widget.stores) {
      if (!oldWidget.stores.contains(newStore)) {
        newStore.addListener(_listener);
      }
    }
  }

  @override
  void dispose() {
    for (final store in widget.stores) {
      store.removeListener(_listener);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}

// Gói debounce để giảm số lần cập nhật
class Debouncer {
  final Duration delay;
  Function? _action;
  bool _isPending = false;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  void call(Function action) {
    _action = action;

    if (!_isPending) {
      _isPending = true;

      Future.delayed(delay, () {
        _isPending = false;
        final currentAction = _action;
        _action = null;
        if (currentAction != null) {
          currentAction();
        }
      });
    }
  }
}

// Extension cho Store để thêm các tính năng debounce và throttle
extension StoreExtensions<T> on Store<T> {
  // Cập nhật state với debounce
  void setStateDebounced(
    T newState, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    final debouncer = Debouncer(delay: delay);
    debouncer(() => setState(newState));
  }

  // Áp dụng transform function để tự động tạo computed state
  R select<R>(R Function(T state) selector) {
    return selector(state);
  }
}
