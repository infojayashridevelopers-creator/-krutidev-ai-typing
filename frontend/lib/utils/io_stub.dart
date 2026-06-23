// Stub for dart:io types on web — keeps AudioService from crashing at compile time.
class File {
  File(String path);
  Future<bool> exists() async => false;
  Future<void> delete() async {}
}
