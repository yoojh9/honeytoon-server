import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../helpers/database.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  
  Future<List<Product>> getProducts() async {
    List<Product> _products;
    QuerySnapshot snapshot = await Database.productRef.getDocuments();
    _products = snapshot.documents.map((document) => 
      Product.fromMap(document.documentID, document.data))
      .toList();
    return _products;
  }
}