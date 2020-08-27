
class Product {
  String code;
  String name;
  String brandCode;
  String brandName;
  String content;
  String contentAddDesc;
  String image;

  Product(
    {this.code,
    this.name,
    this.brandCode,
    this.brandName,
    this.content,
    this.contentAddDesc,
    this.image}
  );

  Product.fromMap(String documentId, Map snapshot){
    this.code = documentId;
    if(snapshot['goodsName'] != null){
      this.name = snapshot['goodsName'];
    }
    if(snapshot['brandCode'] != null) {
      this.brandCode = snapshot['brandCode'];
    }
    if(snapshot['brandName'] != null){
      this.brandName = snapshot['brandName'];
    }
    if(snapshot['content'] != null){
      this.content = snapshot['content'];
    }
    if(snapshot['contentAddDesc'] != null){
      this.contentAddDesc = snapshot['contentAddDesc'];
    }
    if(snapshot['goodsImgS'] != null){
      this.image = snapshot['goodsImgS'];
    }
  }

}