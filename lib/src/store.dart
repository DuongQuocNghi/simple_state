// triển khai Store quản lý state
import 'package:flutter/foundation.dart';
import 'listenable.dart';

class Store<T> implements Listenable, SimpleListenable {
  Store(T initialState) : _state = initialState;

  T _state;
  final List<VoidCallback> _listeners = [];

  // Getter để truy cập state hiện tại
  T get state => _state;

  // Getter để truy cập listeners
  List<VoidCallback> get listeners => _listeners;

  // Phương thức để cập nhật state
  void setState(T newState) {
    if (_state == newState) return;
    _state = newState;
    notifyListeners();
  }

  // Phương thức để cập nhật state một cách từng phần
  void updateState(T Function(T currentState) updater) {
    final newState = updater(_state);
    setState(newState);
  }

  // Phương thức để cập nhật state bất đồng bộ
  Future<void> setStateAsync(
    Future<T> Function(T currentState) asyncUpdater,
  ) async {
    final newState = await asyncUpdater(_state);
    setState(newState);
  }

  // Phương thức để reset state về giá trị ban đầu
  void resetState(T initialState) {
    setState(initialState);
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  @override
  void notifyListeners() {
    for (final listener in List.of(_listeners)) {
      if (_listeners.contains(listener)) {
        listener();
      }
    }
  }

  // Đảm bảo giải phóng bộ nhớ khi không cần nữa
  void dispose() {
    _listeners.clear();
  }
}
