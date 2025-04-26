// Hỗ trợ state phức tạp
import 'store.dart';

// Store cho các State dạng Map
class MapStore<K, V> extends Store<Map<K, V>> {
  MapStore([Map<K, V>? initialState]) : super(initialState ?? {});

  // Thêm một entry vào map
  void put(K key, V value) {
    updateState((currentState) {
      final newState = Map<K, V>.from(currentState);
      newState[key] = value;
      return newState;
    });
  }

  // Lấy giá trị từ key
  V? get(K key) => state[key];

  // Xóa một entry từ map
  void remove(K key) {
    updateState((currentState) {
      final newState = Map<K, V>.from(currentState);
      newState.remove(key);
      return newState;
    });
  }

  // Cập nhật nhiều entries cùng lúc
  void putAll(Map<K, V> entries) {
    updateState((currentState) {
      final newState = Map<K, V>.from(currentState);
      newState.addAll(entries);
      return newState;
    });
  }

  // Xóa tất cả entries
  void clear() {
    updateState((_) => {});
  }
}

// Store cho các State dạng List
class ListStore<E> extends Store<List<E>> {
  ListStore([List<E>? initialState]) : super(initialState ?? []);

  // Thêm phần tử vào list
  void add(E item) {
    updateState((currentState) {
      return List<E>.from(currentState)..add(item);
    });
  }

  // Thêm nhiều phần tử vào list
  void addAll(Iterable<E> items) {
    updateState((currentState) {
      return List<E>.from(currentState)..addAll(items);
    });
  }

  // Xóa phần tử từ list
  void remove(E item) {
    updateState((currentState) {
      return List<E>.from(currentState)..remove(item);
    });
  }

  // Xóa phần tử tại vị trí cụ thể
  void removeAt(int index) {
    updateState((currentState) {
      final newState = List<E>.from(currentState);
      if (index >= 0 && index < newState.length) {
        newState.removeAt(index);
      }
      return newState;
    });
  }

  // Cập nhật phần tử tại vị trí cụ thể
  void update(int index, E item) {
    updateState((currentState) {
      final newState = List<E>.from(currentState);
      if (index >= 0 && index < newState.length) {
        newState[index] = item;
      }
      return newState;
    });
  }

  // Xóa tất cả phần tử
  void clear() {
    updateState((_) => []);
  }
}

// Store cho các state nested complexe (ví dụ: Map lồng Map, Map lồng List, etc.)
class NestedStore<T> extends Store<T> {
  NestedStore(T initialState) : super(initialState);

  // Cập nhật nested field với path dạng chuỗi (ví dụ: 'user.address.city')
  void updateField(String fieldPath, dynamic value) {
    final pathParts = fieldPath.split('.');

    updateState((currentState) {
      final result = _deepCopy(currentState);
      _setNestedValue(result, pathParts, value);
      return result as T;
    });
  }

  // Lấy giá trị của nested field với path dạng chuỗi
  dynamic getField(String fieldPath) {
    final pathParts = fieldPath.split('.');
    return _getNestedValue(state, pathParts);
  }

  // Hàm hỗ trợ để tạo deep copy của một object phức tạp
  dynamic _deepCopy(dynamic object) {
    if (object == null) {
      return null;
    }
    if (object is Map) {
      return Map.fromEntries(
        object.entries.map(
          (entry) => MapEntry(entry.key, _deepCopy(entry.value)),
        ),
      );
    }
    if (object is List) {
      return List.from(object.map((item) => _deepCopy(item)));
    }
    // Với các loại dữ liệu nguyên thủy (int, String, bool, etc.), trả về trực tiếp
    return object;
  }

  // Hàm hỗ trợ để set giá trị cho nested field
  void _setNestedValue(dynamic object, List<String> pathParts, dynamic value) {
    if (pathParts.isEmpty) return;

    final key = pathParts.first;

    if (pathParts.length == 1) {
      // Trường hợp cơ bản: Cập nhật trực tiếp
      if (object is Map) {
        object[key] = value;
      } else if (object is List && int.tryParse(key) != null) {
        final index = int.parse(key);
        if (index >= 0 && index < object.length) {
          object[index] = value;
        }
      }
    } else {
      // Trường hợp nested: Đệ quy xuống level tiếp theo
      final remainingPath = pathParts.sublist(1);

      if (object is Map) {
        if (!object.containsKey(key) || object[key] == null) {
          // Nếu key chưa tồn tại hoặc giá trị là null, khởi tạo một container mới
          if (int.tryParse(remainingPath.first) != null) {
            object[key] = [];
          } else {
            object[key] = {};
          }
        }
        _setNestedValue(object[key], remainingPath, value);
      } else if (object is List && int.tryParse(key) != null) {
        final index = int.parse(key);
        if (index >= 0 && index < object.length) {
          // Nếu index hợp lệ
          if (object[index] == null) {
            // Nếu giá trị tại index là null, khởi tạo container mới
            if (int.tryParse(remainingPath.first) != null) {
              object[index] = [];
            } else {
              object[index] = {};
            }
          }
          _setNestedValue(object[index], remainingPath, value);
        }
      }
    }
  }

  // Hàm hỗ trợ để lấy giá trị từ nested field
  dynamic _getNestedValue(dynamic object, List<String> pathParts) {
    if (pathParts.isEmpty || object == null) return object;

    final key = pathParts.first;
    final remainingPath = pathParts.sublist(1);

    if (object is Map) {
      if (!object.containsKey(key)) return null;
      if (remainingPath.isEmpty) return object[key];
      return _getNestedValue(object[key], remainingPath);
    } else if (object is List && int.tryParse(key) != null) {
      final index = int.parse(key);
      if (index < 0 || index >= object.length) return null;
      if (remainingPath.isEmpty) return object[index];
      return _getNestedValue(object[index], remainingPath);
    }

    return null;
  }
}
