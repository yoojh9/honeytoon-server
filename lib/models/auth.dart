class Auth {
  String uid;
  String displayName;
  String email;
  String password;
  String provider;
  String thumbnail;
  int honey = 0;
  int rank = -1;
  var works = [];

  Auth(
      {this.uid,
      this.displayName,
      this.email,
      this.password,
      this.provider,
      this.thumbnail,
      this.honey,
      this.rank,
      this.works});

  Auth.fromMap(String documentId, Map snapshot) {
    this.uid = documentId;
    if (snapshot['displayName'] != null) {
      this.displayName = snapshot['displayName'];
    }
    if (snapshot['email'] !=null) {
      this.email = snapshot['email'];
    }
    if (snapshot['provider'] != null) {
      this.provider = snapshot['provider'];
    }
    if (snapshot['thumbnail'] != null) {
      this.thumbnail = snapshot['thumbnail'];
    }
    if (snapshot['honey'] != null) {
      this.honey = snapshot['honey'];
    }
    if(snapshot['works']!=null){
      this.works = snapshot['works'];
    }
  }

  @override
  String toString() {
    return "uid: ${this.uid}, user.displayName: ${this.displayName}";
  }
}
