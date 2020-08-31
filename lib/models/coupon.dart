class Coupon {
  String id;
  String orderNo;
  String pinNo;
  String couponImgUrl;

  Coupon({
    this.id,
    this.orderNo,
    this.pinNo,
    this.couponImgUrl
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
  }
}