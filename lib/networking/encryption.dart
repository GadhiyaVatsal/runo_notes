import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionDecryption {
  static final key = encrypt.Key.fromLength(32);
  static final iv = encrypt.IV.fromLength(16);
  static final encrypter = encrypt.Encrypter(encrypt.AES(key));

  static encryption(String text) {
    final encrypted = encrypter.encrypt(text, iv: iv);

    // print(encrypted.bytes);
    // print(encrypted.base16);
    // print(encrypted.base64);
    return encrypted;
  }

  static decryption(text) {
    final dec = encrypter.decrypt(encrypt.Encrypted.fromBase64(text), iv: iv);
    return dec;
  }
}
