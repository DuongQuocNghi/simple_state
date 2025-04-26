// Theo dõi và đo lường hiệu suất
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'store.dart';

class StateMetrics {
  final Map<String, _StoreMetric> _storeMetrics = {};
  static final StateMetrics _instance = StateMetrics._internal();

  // Singleton pattern
  factory StateMetrics() => _instance;
  StateMetrics._internal();

  // Bắt đầu theo dõi một store
  void trackStore<T>(Store<T> store, {required String name}) {
    if (_storeMetrics.containsKey(name)) {
      if (kDebugMode) {
        print('Store with name "$name" is already being tracked');
      }
      return;
    }

    final metric = _StoreMetric<T>(store, name);
    _storeMetrics[name] = metric;
    metric.startTracking();
  }

  // Dừng theo dõi store
  void stopTracking(String name) {
    if (!_storeMetrics.containsKey(name)) return;

    _storeMetrics[name]!.stopTracking();
    _storeMetrics.remove(name);
  }

  // Lấy báo cáo hiệu suất
  Map<String, Map<String, dynamic>> getPerformanceReport() {
    final report = <String, Map<String, dynamic>>{};

    for (final entry in _storeMetrics.entries) {
      report[entry.key] = entry.value.getMetrics();
    }

    return report;
  }

  // In báo cáo hiệu suất ra console
  void printPerformanceReport() {
    final report = getPerformanceReport();

    if (kDebugMode) {
      print('\n=== State Management Performance Report ===');

      report.forEach((storeName, metrics) {
        print('\nStore: $storeName');
        metrics.forEach((key, value) {
          print('  $key: $value');
        });
      });

      print('\n=========================================\n');
    }
  }
}

// Lớp nội bộ để theo dõi metric cho mỗi store
class _StoreMetric<T> {
  final Store<T> store;
  final String name;

  int _updateCount = 0;
  int _listenerCount = 0;
  DateTime? _firstUpdateTime;
  DateTime? _lastUpdateTime;
  List<int> _updateDurations = [];

  _StoreMetric(this.store, this.name);

  void _onStateChanged() {
    _updateCount++;
    final now = DateTime.now();
    _lastUpdateTime = now;
    _firstUpdateTime ??= now;

    // Log update
    developer.Timeline.timeSync('StateUpdate_$name', () {
      // Đo thời gian để notify listeners
      final start = DateTime.now().microsecondsSinceEpoch;
      // Không làm gì, chỉ đo thời gian của listener notification
      final end = DateTime.now().microsecondsSinceEpoch;
      _updateDurations.add(end - start);
    });
  }

  void startTracking() {
    store.addListener(_onStateChanged);
  }

  void stopTracking() {
    store.removeListener(_onStateChanged);
  }

  Map<String, dynamic> getMetrics() {
    _listenerCount = store.listeners.length;

    final duration =
        _lastUpdateTime != null && _firstUpdateTime != null
            ? _lastUpdateTime!.difference(_firstUpdateTime!)
            : Duration.zero;

    final avgUpdateDurationMicros =
        _updateDurations.isNotEmpty
            ? _updateDurations.reduce((a, b) => a + b) / _updateDurations.length
            : 0;

    return {
      'update_count': _updateCount,
      'listener_count': _listenerCount,
      'updates_per_second': duration.inSeconds > 0 ? _updateCount / duration.inSeconds : 0,
      'avg_update_duration_micros': avgUpdateDurationMicros,
      'tracking_duration': duration.toString(),
    };
  }
}

// Cung cấp extension cho Store để dễ dàng theo dõi metric
extension MetricTracking<T> on Store<T> {
  void trackPerformance(String name) {
    StateMetrics().trackStore(this, name: name);
  }

  void stopTrackingPerformance(String name) {
    StateMetrics().stopTracking(name);
  }
}
