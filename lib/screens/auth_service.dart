import 'package:encrypt/encrypt.dart' as encrypt;

class AuthService {
  // Kunci enkripsi (gunakan kunci yang lebih aman di production)
  final String _key = 'my32lengthsupersecretnooneknows!';
  final String _iv = '16characteriv123'; // IV harus sepanjang 16 karakter

  // Fungsi untuk mengenkripsi password
  String encryptPassword(String password) {
    final key = encrypt.Key.fromUtf8(_key);
    final iv = encrypt.IV.fromUtf8(_iv);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(password, iv: iv);
    return encrypted.base64;
  }

  // Fungsi untuk mendekripsi password
  String decryptPassword(String encryptedPassword) {
    final key = encrypt.Key.fromUtf8(_key);
    final iv = encrypt.IV.fromUtf8(_iv);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final decrypted = encrypter.decrypt64(encryptedPassword, iv: iv);
    return decrypted;
  }
}
