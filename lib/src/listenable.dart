// định nghĩa interface cho đối tượng lắng nghe
abstract class SimpleListenable {
  void addListener(void Function() listener);
  void removeListener(void Function() listener);
  void notifyListeners();
}
