import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
    print(await _storage.read(key: 'auth_token'));
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<void> saveStaffId(String staffId) async {
    await _storage.write(key: 'staff_id', value: staffId);
  }
  Future<String?> getStaffId() async {
    return await _storage.read(key: 'staff_id');
  }
  Future<void> deleteStaffId() async {
    await _storage.delete(key: 'staff_id');
  }

  Future<void> saveShipperType(String type) async {
    await _storage.write(key: 'shipperType', value: type);
  }

  Future<void> deleteShipperType() async {
    await _storage.delete(key: 'shipperType');
  }

  Future<String?> getShipperType() async {
    return await _storage.read(key: 'shipperType');
  }
}
