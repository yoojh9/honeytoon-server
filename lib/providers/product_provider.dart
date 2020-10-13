
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
    QuerySnapshot snapshot = await Database.brandRef.get();
    _brands = snapshot.docs.map((document) => Brand.fromMap(document.id, document.data())).toList();
    return _brands;
  }

  Future<List<Product>> getProducts(brandCode) async {
    List<Product> _products;
    if(brandCode!=null && brandCode!=""){
      QuerySnapshot snapshot = await Database.productRef.doc(brandCode).collection('product').get();
      _products = snapshot.docs.map((document) => Product.fromMap(document.id, document.data())).toList();
    }
    return _products;
  }

  Future<Product> getProductById(id, brandCode) async {
    Product _product;
    DocumentSnapshot snapshot = await Database.productRef.doc(brandCode).collection('product').doc(id).get();
    _product = Product.fromMap(snapshot.id, snapshot.data());
    return _product;
  }
  
}
