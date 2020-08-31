class Brand {
  String code;
  String name;
  String brandIconImg;

  Brand({
    this.code,
    this.name,
    this.brandIconImg
  });

  Brand.fromMap(String documentId, Map snapshot){
    this.code = documentId;

    if(snapshot['brandName'] != null){
      this.name = snapshot['brandName'];
    }
    if(snapshot['brandIConImg'] != null){
      this.brandIconImg = snapshot['brandIConImg'];
    }
  }
}