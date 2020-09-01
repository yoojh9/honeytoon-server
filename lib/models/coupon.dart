class Coupon {
  String id;
  String orderNo;
  String pinNo;
  String goodsCode;
  String goodsName;
  String goodsImage;
  String couponImgUrl;
  String use;
  String validDate;

  Coupon({
    this.id,
    this.orderNo,
    this.pinNo,
    this.goodsCode,
    this.goodsName,
    this.goodsImage,
    this.couponImgUrl,
    this.use,
    this.validDate
  });

  Coupon.fromMap(String documentId, Map data){
    this.id = documentId;

    if(data['orderNo']!=null){
      this.orderNo = data['orderNo'];
    }
    if(data['pinNo']!=null){
      this.pinNo = data['pinNo'];
    }
    if(data['couponImgUrl']!=null){
      this.couponImgUrl = data['couponImgUrl'];
    }
    if(data['goods_code']!=null){
      this.goodsCode = data['goods_code'];
    }
    if(data['goods_name']!=null){
      this.goodsName = data['goods_name'];
    }
    if(data['goods_image']!=null){
      this.goodsImage = data['goods_image'];
    }
    if(data['use']!=null){
      this.use = data['use'];
    }
    if(data['validDate']!=null){
      this.validDate = data['validDate'];
    }
  }
}