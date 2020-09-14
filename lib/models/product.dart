class Product {
  String code;
  String name;
  String brandCode;
  String brandName;
  String content;
  String contentAddDesc;
  int honey;
  String image;
  String validPrdDay;

  Product(
      {this.code,
      this.name,
      this.brandCode,
      this.brandName,
      this.content,
      this.contentAddDesc,
      this.honey,
      this.image,
      this.validPrdDay});

  Product.fromMap(String documentId, Map snapshot) {
    this.code = documentId;

    if (snapshot['goodsName'] != null) {
      this.name = snapshot['goodsName'];
    }
    if (snapshot['brandCode'] != null) {
      this.brandCode = snapshot['brandCode'];
    }
    if (snapshot['brandName'] != null) {
      this.brandName = snapshot['brandName'];
    }
    if (snapshot['content'] != null) {
      this.content = snapshot['content'];
    }
    if (snapshot['contentAddDesc'] != null) {
      this.contentAddDesc = snapshot['contentAddDesc'];
    }
    if (snapshot['honey'] != null) {
      this.honey = snapshot['honey'];
    }
    if (snapshot['goodsImgS'] != null) {
      this.image = snapshot['goodsImgS'];
    }
    if (snapshot['validPrdDay'] != null){
      this.validPrdDay = snapshot['validPrdDay'];
    }
  }
}
