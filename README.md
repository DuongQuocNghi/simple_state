# Simple State

Package quản lý state đơn giản, hiệu quả và dễ sử dụng cho Flutter, không phụ thuộc vào bất kỳ package quản lý state bên ngoài nào.

## Ghi chú

**Store**: Lớp cơ bản để lưu trữ và quản lý state
**ListStore**: Quản lý state dạng danh sách
**MapStore**: Quản lý state dạng map
**NestedStore**: Quản lý state phức tạp, lồng nhau
**SimpleConsumer**: Widget để rebuild UI khi state thay đổi
**SimpleSelector**: Tối ưu việc render bằng cách chỉ lắng nghe thay đổi của một phần state
**StoreProvider/MultiStoreProvider**: Cung cấp store xuống widget tree

1. **Tách biệt các store theo chức năng**: Mỗi tính năng/module nên có store riêng để dễ quản lý
2. **Sử dụng Selector khi có thể**: Tránh rebuild toàn bộ UI khi chỉ một phần nhỏ state thay đổi
3. **Quản lý vòng đời của store**: Đảm bảo dispose store khi không còn cần thiết để tránh rò rỉ bộ nhớ
4. **Tổ chức gọn gàng**: Tách business logic ra khỏi UI bằng cách đặt logic xử lý trong store
5. **Theo dõi hiệu suất trong quá trình phát triển**: Sử dụng StateMetrics để phát hiện các vấn đề hiệu suất sớm

## Cài đặt

Thêm package vào pubspec.yaml:

```yaml
dependencies:
  simple_state:
    path: ../simple_state  # hoặc git URL khi publish lên GitHub
```

## Cách sử dụng

### 1. Store cơ bản

```dart
import 'package:simple_state/simple_state.dart';

// Tạo một store đơn giản
final counterStore = Store<int>(0);

// Cập nhật giá trị
counterStore.setState(1);

// Cập nhật state thông qua hàm updater
counterStore.updateState((currentValue) => currentValue + 1);

// Cập nhật state bất đồng bộ
counterStore.setStateAsync((currentValue) async {
  await Future.delayed(Duration(seconds: 1));
  return currentValue + 1;
});
```

### 2. Sử dụng Store với Consumer

```dart
import 'package:flutter/material.dart';
import 'package:simple_state/simple_state.dart';

class CounterWidget extends StatelessWidget {
  final Store<int> counterStore;
  
  CounterWidget({required this.counterStore});
  
  @override
  Widget build(BuildContext context) {
    return SimpleConsumer<Store<int>>(
      listenable: counterStore,
      builder: (context, store) {
        return Text('Counter: ${store.state}');
      },
    );
  }
}
```

### 3. Sử dụng Selector để tối ưu render

```dart
import 'package:flutter/material.dart';
import 'package:simple_state/simple_state.dart';

class UserProfile {
  final String name;
  final int age;
  
  UserProfile({required this.name, required this.age});
}

final userStore = Store<UserProfile>(UserProfile(name: 'John', age: 25));

class NameWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SimpleSelector<UserProfile, String>(
      store: userStore,
      selector: (state) => state.name,
      builder: (context, name) {
        return Text('Name: $name');
      },
    );
  }
}
```

### 4. Sử dụng Store phức tạp

```dart
// List Store
final todoListStore = ListStore<String>(['Task 1', 'Task 2']);
todoListStore.add('Task 3');
todoListStore.removeAt(0);
todoListStore.update(0, 'Updated Task');

// Map Store
final userMapStore = MapStore<String, String>({
  'name': 'John',
  'email': 'john@example.com'
});
userMapStore.put('phone', '123-456-7890');
userMapStore.remove('email');

// Nested Store
final appStateStore = NestedStore<Map<String, dynamic>>({
  'user': {
    'profile': {
      'name': 'John',
      'age': 25
    },
    'settings': {
      'darkMode': true,
      'notifications': ['email', 'push']
    }
  },
  'todos': [
    {'title': 'Buy milk', 'completed': false},
    {'title': 'Call mom', 'completed': true}
  ]
});

// Cập nhật nested field
appStateStore.updateField('user.profile.name', 'Jane');
appStateStore.updateField('todos.0.completed', true);

// Lấy giá trị từ nested field
String name = appStateStore.getField('user.profile.name');
```

### 5. Sử dụng StoreProvider

```dart
import 'package:flutter/material.dart';
import 'package:simple_state/simple_state.dart';

void main() {
  final counterStore = Store<int>(0);
  final themeModeStore = Store<ThemeMode>(ThemeMode.light);
  
  runApp(
    MultiStoreProvider(
      providers: [
        (context, child) => StoreProvider<int>(
          store: counterStore,
          child: child,
        ),
        (context, child) => StoreProvider<ThemeMode>(
          store: themeModeStore,
          child: child,
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreBuilder<ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          themeMode: themeMode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Lấy store từ context
    final counterStore = StoreLocator.locate<int>(context);
    
    return Scaffold(
      appBar: AppBar(title: Text('Simple State Demo')),
      body: Center(
        child: StoreBuilder<int>(
          builder: (context, count) {
            return Text('Count: $count');
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => counterStore.updateState((state) => state + 1),
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### 6. Theo dõi hiệu suất

```dart
import 'package:simple_state/simple_state.dart';

void main() {
  final counterStore = Store<int>(0);
  
  // Bắt đầu theo dõi hiệu suất
  counterStore.trackPerformance('counter');
  
  // Sau khi hoàn thành các tác vụ muốn đo
  Future.delayed(Duration(seconds: 10), () {
    // In báo cáo hiệu suất
    StateMetrics().printPerformanceReport();
    
    // Hoặc lấy báo cáo dưới dạng Map
    final report = StateMetrics().getPerformanceReport();
    print(report['counter']?['update_count']);
    
    // Dừng theo dõi
    counterStore.stopTrackingPerformance('counter');
  });
}
```

## Các tình huống sử dụng phổ biến

### Form quản lý với state phức tạp

```dart
import 'package:flutter/material.dart';
import 'package:simple_state/simple_state.dart';

class UserForm extends StatelessWidget {
  final formStore = NestedStore<Map<String, dynamic>>({
    'name': '',
    'email': '',
    'address': {
      'street': '',
      'city': '',
      'zipCode': ''
    },
    'contactPreferences': []
  });
  
  @override
  Widget build(BuildContext context) {
    return SimpleConsumer<NestedStore>(
      listenable: formStore,
      builder: (context, store) {
        return Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Name'),
              value: store.getField('name'),
              onChanged: (value) => store.updateField('name', value),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Email'),
              value: store.getField('email'),
              onChanged: (value) => store.updateField('email', value),
            ),
            // Các field khác tương tự
            ElevatedButton(
              onPressed: () {
                // Xử lý submit form với tất cả giá trị
                final formData = store.state;
                // Gửi formData đến API...
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
```

### Ứng dụng ToDo List

```dart
import 'package:flutter/material.dart';
import 'package:simple_state/simple_state.dart';

class TodoItem {
  final String id;
  final String title;
  bool completed;
  
  TodoItem({
    required this.id,
    required this.title,
    this.completed = false,
  });
}

class TodoApp extends StatelessWidget {
  final todoListStore = ListStore<TodoItem>([]);
  final newTodoStore = Store<String>('');
  
  TodoApp() {
    // Khởi tạo với một số task mẫu
    todoListStore.addAll([
      TodoItem(id: '1', title: 'Learn Flutter'),
      TodoItem(id: '2', title: 'Create a simple state package'),
    ]);
  }
  
  void _addTodo() {
    if (newTodoStore.state.isNotEmpty) {
      final newTodo = TodoItem(
        id: DateTime.now().toString(),
        title: newTodoStore.state,
      );
      todoListStore.add(newTodo);
      newTodoStore.setState('');
    }
  }
  
  void _toggleTodo(int index) {
    todoListStore.updateState((currentList) {
      final newList = List<TodoItem>.from(currentList);
      newList[index] = TodoItem(
        id: newList[index].id,
        title: newList[index].title,
        completed: !newList[index].completed,
      );
      return newList;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo App')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SimpleConsumer<Store<String>>(
                    listenable: newTodoStore,
                    builder: (context, store) {
                      return TextField(
                        decoration: InputDecoration(
                          labelText: 'New Todo',
                        ),
                        value: store.state,
                        onChanged: (value) => store.setState(value),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addTodo,
                ),
              ],
            ),
          ),
          Expanded(
            child: SimpleConsumer<ListStore<TodoItem>>(
              listenable: todoListStore,
              builder: (context, store) {
                return ListView.builder(
                  itemCount: store.state.length,
                  itemBuilder: (context, index) {
                    final todo = store.state[index];
                    return ListTile(
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          decoration: todo.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      leading: Checkbox(
                        value: todo.completed,
                        onChanged: (_) => _toggleTodo(index),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => store.removeAt(index),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```