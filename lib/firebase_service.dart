
import 'dart:io' as io;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  static Future<String> uploadImage(String path, String folderName) async {

    Reference storageReference =
    FirebaseStorage.instance.ref().child('$folderName/${DateTime.now().millisecondsSinceEpoch}');
    UploadTask uploadTask = storageReference.putFile(io.File(path));
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
  }
}
