
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../helpers/database.dart';
import '../models/product.dart';
import '../models/brand.dart';

class ProductProvider extends ChangeNotifier {
  static const GIFTISHOW_CUSTOM_AUTH_CODE='REAL78856b57de224f218d645fdc5d8a81eb';
  static const GIFTISHOW_CUSTOM_AUTH_TOKEN='qJL+ZRqaawDtRI4zY8Frvg==';

  Future<List<Brand>> getBrands() async {
    List<Brand> _brands;
    QuerySnapshot snapshot = await Database.brandRef.getDocuments();
    _brands = snapshot.documents.map((document) => Brand.fromMap(document.documentID, document.data))
      .toList();
    return _brands;
  }

  Future<List<Product>> getProducts(brandCode) async {
    List<Product> _products;
    if(brandCode!=null && brandCode!=""){
      QuerySnapshot snapshot = await Database.productRef.document(brandCode).collection('product').getDocuments();
      _products = snapshot.documents
          .map((document) => Product.fromMap(document.documentID, document.data))
          .toList();
    }
    return _products;
  }

  Future<Product> getProductById(id, brandCode) async {
    Product _product;
    DocumentSnapshot snapshot = await Database.productRef.document(brandCode).collection('product').document(id).get();
    _product = Product.fromMap(snapshot.documentID, snapshot.data);
    return _product;
  }

  
}
