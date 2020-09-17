import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:uuid/uuid.dart';

enum StorageType {
  META_COVER,
  CONTENT_COVER,
  USER_THUMBNAIL
}

class Storage {
  static final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  static Future<String> uploadImageToStorage(StorageType type, String id, File image) async {
    final storagePath = getStoragePath(type, id);

    final StorageReference storageReference = _firebaseStorage.ref().child(storagePath);
    final StorageUploadTask storageUploadTask = storageReference.putFile(image);
    await storageUploadTask.onComplete;
    String downloadUrl = await storageReference.getDownloadURL();

    return downloadUrl;
  }

  static Future<void> deleteImageFromStorage(String imageUrl) async {
    final StorageReference _storageReference = await _firebaseStorage.getReferenceFromUrl(imageUrl);
    await _storageReference.delete();
 }

  static String getStoragePath(type, id){
    if(type == StorageType.META_COVER) return 'cover/$id/${Uuid().v4()}';
    else if(type == StorageType.USER_THUMBNAIL) return 'thumb/$id/${Uuid().v4()}';
    else return 'content/$id/cover/${Uuid().v4()}'; 
  }

  static Future<String> uploadContentImage(String id, Asset asset) async {
    ByteData byteData = await asset.getByteData();
    List<int> imageData = byteData.buffer.asUint8List();
    final StorageReference storageReference = _firebaseStorage.ref().child('content/$id/item/${Uuid().v4()}');
    final StorageUploadTask storageUploadTask = storageReference.putData(imageData);
    await storageUploadTask.onComplete;
    String downloadUrl = await storageReference.getDownloadURL();
    return downloadUrl;
  }
}